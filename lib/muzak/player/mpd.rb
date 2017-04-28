require "ruby-mpd"

module Muzak
  module Player
    # Exposes a MPD connection to muzak for playback control.
    class MPD < StubPlayer
      def running?
        !!@mpd&.connected?
      end

      # Activates the MPD connection.
      # @return [void]
      def activate!
        return if running?

        debug "activating #{self.class}"

        host = Config.mpd_host || "localhost"
        port = Config.mpd_port || 6600

        @mpd = ::MPD.new host, port
        @mpd.connect
        @mpd.clear

        instance.event :player_activated
      end

      # Deactivates the MPD connection.
      # @return [void]
      def deactivate!
        @mpd.clear
        sleep 0.1 # give mpd a little bit of time to process
        @mpd.disconnect

        debug "deactivating #{self.class}"

        instance.event :player_deactivated
      end

      # Tell MPD to begin playback.
      # @return [void]
      # @note Does nothing is playback is already in progress.
      def play
        @mpd.play
      end

      # Tell MPD to pause playback.
      # @return [void]
      # @note Does nothing is playback is already paused.
      def pause
        @mpd.pause
      end

      # @return [Boolean] whether or not MPD is currently playing.
      def playing?
        return false unless running?

        @mpd.playing?
      end

      # Tell MPD to play the next song in its queue.
      # @return [void]
      # @note Does nothing if the current song is the last.
      def next_song
        @mpd.next
      end

      # Tell MPD to play the previous song in its queue.
      # @return [void]
      # @note Restarts the song if the current song is the first.
      def previous_song
        @mpd.previous
      end

      # Tell MPD to add the given song to its queue.
      # @param song [Song] the song to add
      # @return [void]
      # @note Activates MPD if not already activated.
      def enqueue_song(song)
        activate! unless running?

        load_song song
      end

      # Tell MPD to add the given album to its queue.
      # @param album [Album] the album to add
      # @return [void]
      # @note Activates MPD if not already activated.
      def enqueue_album(album)
        activate! unless running?

        album.songs.each do |song|
          load_song song
        end
      end

      # Tell MPD to add the given playlist to its queue.
      # @param playlist [Playlist] the playlist to add
      # @return [void]
      # @note Activates MPD if not already activated.
      def enqueue_playlist(playlist)
        activate! unless running?

        playlist.songs.each do |song|
          load_song song
        end
      end

      # Get MPD's internal queue.
      # @return [Array<Song>] all songs in MPD's queue
      # @note This includes songs already played.
      # @todo Implement this.
      def list_queue
        debug @mpd.playlist.to_s
        danger "this player doesn't support list_queue"
        []
      end

      # Shuffle MPD's internal queue.
      # @return [void]
      # @todo Implement this.
      def shuffle
        danger "this player doesn't support shuffling (?)"
      end

      # Clear MPD's internal queue.
      # @return [void]
      def clear_queue
        return unless running?
        @mpd.clear
      end

      # Get MPD's currently loaded song.
      # @return [Song, nil] the currently loaded song
      def now_playing
        return unless playing?

        path = "#{Config.music}/#{@mpd.current_song.file}"
        Song.new(path)
      end

      # Load a song into MPD.
      # @param song [Song] the song to load
      # @return [void]
      # @api private
      def load_song(song)
        path = song.path.sub("#{Config.music}/", "")
        @mpd.add(path)
        @mpd.play if Config.autoplay
      end
    end
  end
end
