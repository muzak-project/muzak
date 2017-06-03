# frozen_string_literal: true

module Muzak
  module Player
    # A no-op player that all players inherit from.
    # @abstract Subclass and implement all public methods to implement
    #  a player.
    class StubPlayer
      include Utils

      # @return [Instance] the instance associated with this player
      attr_reader :instance

      # The player's human friendly name.
      # @return [String] the name
      def self.player_name
        name.split("::").last.downcase
      end

      # @return [true] whether or not this type of player is available
      def self.available?
        true
      end

      # @param instance [Instance] the instance associated with the player
      def initialize(instance)
        @instance = instance
      end

      # @return [false] whether or not the player is running
      # @note NO-OP
      def running?
        debug "#running?"
        false
      end

      # Activates the player.
      # @return [void]
      # @note NO-OP
      def activate!
        debug "#activate!"
      end

      # Deactivates the player.
      # @return [void]
      # @note NO-OP
      def deactivate!
        debug "#deactivate!"
      end

      # Starts playback.
      # @return [void]
      # @note NO-OP
      def play
        debug "#play"
      end

      # Ends playback.
      # @return [void]
      # @note NO-OP
      def pause
        debug "#pause"
      end

      # @return [false] whether or not the player is currently playing
      # @note NO-OP
      def playing?
        debug "#playing?"
        false
      end

      # Moves to the next song.
      # @return [void]
      # @note NO-OP
      def next_song
        debug "#next_song"
      end

      # Moves to the previous song.
      # @return [void]
      # @note NO-OP
      def previous_song
        debug "#previous_song"
      end

      # Enqueues the given song.
      # @param song [Song] the song to enqueue
      # @return [void]
      # @note NO-OP
      def enqueue_song(_song)
        debug "#enqueue_song"
      end

      # Enqueues the given album.
      # @param album [Album] the album to enqueue
      # @return [void]
      # @note NO-OP
      def enqueue_album(_album)
        debug "#enqueue_album"
      end

      # Enqueues the given playlist.
      # @param playlist [Playlist] the playlist to enqueue
      # @return [void]
      # @note NO-OP
      def enqueue_playlist(_playlist)
        debug "#enqueue_playlist"
      end

      # List the player's queue.
      # @return [void]
      # @note NO-OP
      def list_queue
        debug "#list_queue"
      end

      # Shuffle the player's queue.
      # @return [void]
      # @note NO-OP
      def shuffle_queue
        debug "#shuffle_queue"
      end

      # Clear the player's queue.
      # @return [void]
      # @note NO-OP
      def clear_queue
        debug "#clear_queue"
      end

      # Get the currently playing song.
      # @return [void]
      # @note NO-OP
      def now_playing
        debug "#now_playing"
      end
    end
  end
end
