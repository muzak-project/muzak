# frozen_string_literal: true

require "vlc-client"

module Muzak
  module Player
    # Exposes a VLC process to muzak for playback control.
    class VLC < StubPlayer
      # @return [Boolean] whether or not VLC is available
      def self.available?
        Utils.which?("vlc") && Utils.which?("cvlc")
      end

      # @return [Boolean] whether or not the current instance is running.
      def running?
        !!@vlc&.connected?
      end

      # Activates a VLC process.
      # @return [void]
      def activate!
        return if running?

        debug "activating #{self.class}"

        @vlc = ::VLC::System.new

        instance.event :player_activated
      end

      # Deactivates the VLC process, if one is running.
      # @return [void]
      def deactivate!
        return unless running?

        debug "deactivating #{self.class}"

        @vlc.client.disconnect
        @vlc.server.stop

        instance.event :player_deactivated
      end

      # Tell VLC to begin playback.
      # @return [void]
      # @note Does nothing is playback is already in progress.
      def play
        return unless running?

        @vlc.play
      end

      # Tell VLC to pause playback.
      # @return [void]
      # @note Does nothing is playback is already paused.
      def pause
        return unless running?

        @vlc.pause
      end

      # @return [Boolean] whether or not VLC is currently playing.
      def playing?
        return false unless running?

        @vlc.playing?
      end

      # Tell VLC to play the next song in its queue.
      # @return [void]
      # @note Does nothing if the current song is the last.
      def next_song
        @vlc.next
      end

      # Tell VLC to play the previous song in its queue.
      # @return [void]
      # @note Restarts the song if the current song is the first.
      def previous_song
        @vlc.previous
      end

      # Tell VLC to add the given song to its queue.
      # @param song [Song] the song to add
      # @return [void]
      # @note Activates VLC if not already activated.
      def enqueue_song(song)
        activate! unless running?

        load_song song
      end

      # Tell VLC to add the given album to its queue.
      # @param album [Album] the album to add
      # @return [void]
      # @note Activates VLC if not already activated.
      def enqueue_album(album)
        activate! unless running?

        album.songs.each do |song|
          load_song song
        end
      end

      # Tell VLC to add the given playlist to its queue.
      # @param playlist [Playlist] the playlist to add
      # @return [void]
      # @note Activates VLC if not already activated.
      def enqueue_playlist(playlist)
        activate! unless running?

        playlist.songs.each do |song|
          load_song song
        end
      end

      # Get VLC's internal queue.
      # @return [Array<Song>] all songs in VLC's queue
      # @note This includes songs already played.
      # @todo Implement this.
      def list_queue
        debug @vlc.playlist.to_s
        danger "this player doesn't support list_queue"
        # TODO: figure out how to get VLC::Client#playlist to return filenames
        []
      end

      # Shuffle VLC's internal queue.
      # @return [void]
      # @todo Implement this.
      def shuffle
        danger "this player doesn't support shuffling (?)"
      end

      # Clear VLC's internal queue.
      # @return [void]
      def clear_queue
        return unless running?
        @vlc.clear
      end

      # Get VLC's currently loaded song.
      # @return [Song, nil] the currently loaded song
      def now_playing
        return unless playing?

        Song.new(@vlc.status[:file])
      end

      # Load a song into VLC.
      # @param song [Song] the song to load
      # @return [void]
      # @api private
      def load_song(song)
        @vlc.add_to_playlist song.path
        @vlc.play if Config.autoplay
      end
    end
  end
end
