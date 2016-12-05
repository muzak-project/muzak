require "tempfile"
require "socket"
require "json"
require "thread"

module Muzak
  module Player
    class MPV
      include Utils

      attr_accessor :instance

      def initialize(instance)
        @instance = instance
      end

      def running?
        begin
          !!@pid && Process.waitpid(@pid, Process::WNOHANG).nil?
        rescue Errno::ECHILD
          false
        end
      end

      def activate!
        return if running?

        debug "activating #{self.class}"

        @sock_path = Dir::Tmpname.make_tmpname("/tmp/mpv", ".sock")
        mpv_args = [
          "--idle",
          "--no-osc",
          "--no-osd-bar",
          "--no-input-default-bindings",
          "--no-input-cursor",
          "--no-terminal",
          "--input-ipc-server=%{socket}" % { socket: @sock_path }
        ]

        mpv_args << "--geometry=#{instance.config["art-geometry"]}" if instance.config["art-geometry"]

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

      def play
        return unless running?

        set_property "pause", false
      end

      def pause
        return unless running?

        set_property "pause", true
      end

      def playing?
        return false unless running?

        !get_property "pause"
      end

      def next_song
        command "playlist-next"
      end

      def previous_song
        command "playlist-prev"
      end

      def enqueue_song(song)
        activate! unless running?

        cmds = ["loadfile", song.path, "append-play"]
        cmds << "external-file=#{album.cover_art}" if song.best_guess_album_art
        command *cmds
      end

      def enqueue_album(album)
        activate! unless running?

        album.songs.each do |song|
          cmds = ["loadfile", song.path, "append-play"]
          cmds << "external-file=#{album.cover_art}" if album.cover_art
          command *cmds
        end
      end

      def enqueue_playlist(playlist)
        activate! unless running?

        playlist.songs.each do |song|
          cmds = ["loadfile", song.path, "append-play"]
          cmds << "external-file=#{song.best_guess_album_art}" if song.best_guess_album_art
          command *cmds
        end
      end

      def list_queue
        entries = get_property "playlist/count"

        playlist = []

        entries.times do |i|
          playlist << Song.new(get_property("playlist/#{i}/filename"))
        end

        playlist
      end

      def shuffle_queue
        command "playlist-shuffle"
      end

      def clear_queue
        command "playlist-clear"
      end

      def now_playing
        Song.new(get_property "path")
      end

      private

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
              # this really isn't ideal, since we already have access
              # to Song objects earlier in the object's lifetime.
              # the "correct" way to do this would be to sync an external
              # playlist with mpv's internal one and access that instead
              # of re-creating the Song from mpv properties.
              # another idea: serialize Song objects into mpv's properties
              # somehow.
              song = Song.new(get_property "path")
              instance.event :song_loaded, song
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
