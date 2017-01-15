require "tempfile"
require "socket"
require "json"
require "thread"
require "mpv"

module Muzak
  module Player
    # Exposes MPV's IPC to muzak for playback control.
    class MPV < StubPlayer
      # @return [Boolean] Whether or not MPV is available for execution
      def self.available?
        Utils.which?("mpv")
      end

      # @return [Boolean] Whether or not the current instance is running.
      def running?
        @mpv&.running?
      end

      # Activate mpv by executing it and preparing for event processing.
      # @return [void]
      def activate!
        return if running?

        debug "activating #{self.class}"

        mpv_args = [
          # if i get around to separating album art from playback,
          # these two flags disable mpv's video output entirely
          # "--no-force-window",
          # "--no-video",
          # there's also this, which (might) also work
          # "--audio-display=no",
          "--no-osc",
          "--no-osd-bar",
          "--no-input-default-bindings",
          "--no-input-cursor",
          "--load-scripts=no", # autoload and other scripts with clobber our mpv management
        ]

        mpv_args << "--geometry=#{Config.art_geometry}" if Config.art_geometry

        @mpv = ::MPV::Session.new(user_args: mpv_args)
        @mpv.callbacks << ::MPV::Callback.new(self, :dispatch_event!)

        instance.event :player_activated
      end

      # Deactivate mpv by killing it and cleaning up.
      # @return [void]
      def deactivate!
        return unless running?

        debug "deactivating #{self.class}"

        @mpv.quit!
      ensure
        @_now_playing = nil
        instance.event :player_deactivated
      end

      # Tell mpv to begin playback.
      # @return [void]
      # @note Does nothing is playback is already in progress.
      def play
        return unless running?

        @mpv.set_property "pause", false
      end

      # Tell mpv to pause playback.
      # @return [void]
      # @note Does nothing is playback is already paused.
      def pause
        return unless running?

        @mpv.set_property "pause", true
      end

      # @return [Boolean] Whether or not mpv is currently playing.
      def playing?
        return false unless running?

        !@mpv.get_property "pause"
      end

      # Tell mpv to play the next song in its queue.
      # @return [void]
      # @note Does nothing if the current song is the last.
      def next_song
        @mpv.command "playlist-next"
      end

      # Tell mpv to play the previous song in its queue.
      # @return [void]
      # @note Does nothing if the current song is the first.
      def previous_song
        @mpv.command "playlist-prev"
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
        entries = @mpv.get_property "playlist/count"

        playlist = []

        entries.times do |i|
          # TODO: this is slow and should be avoided at all costs,
          # since we have access to these Song instances earlier
          # in the object's lifecycle.
          playlist << Song.new(@mpv.get_property("playlist/#{i}/filename"))
        end

        playlist
      end

      # Shuffle mpv's internal queue.
      # @return [void]
      def shuffle_queue
        return unless running?

        @mpv.command "playlist-shuffle"
      end

      # Clears mpv's internal queue.
      # @return [void]
      def clear_queue
        return unless running?

        @mpv.command "playlist-clear"
      end

      # Get mpv's currently loaded song.
      # @return [Song, nil] the currently loaded song
      def now_playing
        @_now_playing ||= Song.new(@mpv.get_property "path")
      end

      # Load a song and optional album art into mpv.
      # @param song [Song] the song to load
      # @param art [String] the art file to load
      # @return [void]
      # @api private
      def load_song(song, art)
        cmds = ["loadfile", song.path, "append-play"]
        cmds << "external-file=\"#{art}\"" if art
        @mpv.command *cmds
      end

      # Dispatch the given event to the active {Muzak::Instance}.
      # @param event [String] the event
      # @return [void]
      # @api private
      def dispatch_event!(event)
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
end
