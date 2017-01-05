require "tempfile"
require "socket"
require "json"
require "thread"

module Muzak
  module Player
    # Exposes MPV's IPC to muzak for playback control.
    class MPV < StubPlayer
      # @return [Boolean] Whether or not the current instance is running.
      def running?
        begin
          !!@pid && Process.waitpid(@pid, Process::WNOHANG).nil?
        rescue Errno::ECHILD
          false
        end
      end

      # Activate mpv by executing it and preparing for event processing.
      # @return [void]
      def activate!
        return if running?

        debug "activating #{self.class}"

        @sock_path = Dir::Tmpname.make_tmpname("/tmp/mpv", ".sock")
        mpv_args = [
          "--idle",
          # if i get around to separating album art from playback,
          # these two flags disable mpv's video output entirely
          # "--no-force-window",
          # "--no-video",
          "--no-osc",
          "--no-osd-bar",
          "--no-input-default-bindings",
          "--no-input-cursor",
          "--no-terminal",
          "--load-scripts=no", # autoload and other scripts with clobber our mpv management
          "--input-ipc-server=%{socket}" % { socket: @sock_path }
        ]

        mpv_args << "--geometry=#{Config.art_geometry}" if Config.art_geometry

        @pid = Process.spawn("mpv", *mpv_args)

        until File.exists?(@sock_path)
          sleep 0.1
        end

        @socket = UNIXSocket.new(@sock_path)

        @command_queue = Queue.new
        @result_queue = Queue.new
        @event_queue = Queue.new

        @command_thread = Thread.new { pump_commands! }
        @results_thread = Thread.new { pump_results! }
        @events_thread = Thread.new { dispatch_events! }

        instance.event :player_activated
      end

      # Deactivate mpv by killing it and cleaning up.
      # @return [void]
      def deactivate!
        return unless running?

        debug "deactivating #{self.class}"

        command "quit"

        Process.kill :TERM, @pid
        Process.wait @pid
        @pid = nil

        @socket.close
      ensure
        instance.event :player_deactivated
        File.delete(@sock_path) if @sock_path && File.exists?(@sock_path)
      end

      # Tell mpv to begin playback.
      # @return [void]
      # @note Does nothing is playback is already in progress.
      def play
        return unless running?

        set_property "pause", false
      end

      # Tell mpv to pause playback.
      # @return [void]
      # @note Does nothing is playback is already paused.
      def pause
        return unless running?

        set_property "pause", true
      end

      # @return [Boolean] Whether or not mpv is currently playing.
      def playing?
        return false unless running?

        !get_property "pause"
      end

      # Tell mpv to play the next song in its queue.
      # @return [void]
      # @note Does nothing if the current song is the last.
      def next_song
        command "playlist-next"
      end

      # Tell mpv to play the previous song in its queue.
      # @return [void]
      # @note Does nothing if the current song is the first.
      def previous_song
        command "playlist-prev"
      end

      # Tell mpv to add the given song to its queue.
      # @param song [Song] the song to add
      # @return [void]
      # @note Activates mpv if not already activated.
      def enqueue_song(song)
        activate! unless running?

        load_song song, song.best_guess_album_art
      end

      # Tell mpv to add the given album to its queue.
      # @param album [Album] the album to add
      # @return [void]
      # @note Activates mpv if not already activated.
      def enqueue_album(album)
        activate! unless running?

        album.songs.each do |song|
          load_song song, album.cover_art
        end
      end

      # Tell mpv to add the given playlist to its queue.
      # @param playlist [Playlist] the playlist to add
      # @return [void]
      # @note Activates mpv if not already activated.
      def enqueue_playlist(playlist)
        activate! unless running?

        playlist.songs.each do |song|
          load_song song, song.best_guess_album_art
        end
      end

      # Get mpv's internal queue.
      # @return [Array<Song>] all songs in mpv's queue
      # @note This includes songs already played.
      def list_queue
        entries = get_property "playlist/count"

        playlist = []

        entries.times do |i|
          # TODO: this is slow and should be avoided at all costs,
          # since we have access to these Song instances earlier
          # in the object's lifecycle.
          playlist << Song.new(get_property("playlist/#{i}/filename"))
        end

        playlist
      end

      # Shuffle mpv's internal queue.
      # @return [void]
      def shuffle_queue
        return unless running?

        command "playlist-shuffle"
      end

      # Clears mpv's internal queue.
      # @return [void]
      def clear_queue
        return unless running?

        command "playlist-clear"
      end

      # Get mpv's currently loaded song.
      # @return [Song, nil] the currently loaded song
      def now_playing
        path = get_property "path"
        return if path&.empty?
        @_now_playing ||= Song.new(get_property "path")
      end

      private

      def load_song(song, art)
        cmds = ["loadfile", song.path, "append-play"]
        cmds << "external-file=\"#{art}\"" if art
        command *cmds
      end

      def pump_commands!
        loop do
          begin
            @socket.puts(@command_queue.pop)
          rescue EOFError # the player is deactivating
            Thread.exit
          end
        end
      end

      def pump_results!
        loop do
          begin
            response = JSON.parse(@socket.readline)

            if response["event"]
              @event_queue << response["event"]
            else
              @result_queue << response
            end
          rescue EOFError # the player is deactivating
            Thread.exit
          end
        end
      end

      def dispatch_events!
        loop do
          event = @event_queue.pop

          Thread.new do
            case event
            when "file-loaded"
              instance.event :song_loaded, now_playing
            when "end-file"
              instance.event :song_unloaded
              @_now_playing = nil
            end
          end
        end
      end

      def command(*args)
        return unless running?

        payload = {
          "command" => args
        }

        debug "mpv payload: #{payload.to_s}"

        @command_queue << JSON.generate(payload)

        @result_queue.pop
      end

      def set_property(*args)
        command "set_property", *args
      end

      def get_property(*args)
        command("get_property", *args)["data"]
      end
    end
  end
end
