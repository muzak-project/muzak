# frozen_string_literal: true

module Muzak
  module Player
    # Wraps multiple players into a single class.
    # This can be useful for controlling a local and remote player
    # simultaneously, e.g. one {MPD} and one {MPV} via the same Muzak instance.
    class MultiPlayer < StubPlayer
      # @return [Array<StubPlayer>] the players associated with this multiplayer
      attr_reader :players

      # @return [Boolean] whether or not all of the players are available
      def self.available?
        klasses = Config.multiplayer_players.map { |p| Player::PLAYER_MAP[p] }
        klasses.all?(&:available?)
      end

      # @param instance [Instance] the instance associated with the player
      def initialize(instance)
        super(instance)

        klasses = Config.multiplayer_players.map { |p| Player::PLAYER_MAP[p] }
        @players = klasses.map { |pk| pk.new(instance) }
      end

      # @return [Boolean] whether or not any of the players are currently running.
      def running?
        @players.any?(&:running?)
      end

      # Activates each player under the multiplayer.
      # @return [void]
      def activate!
        debug "activating #{self.class}"
        @players.each(&:activate!)
      end

      # Deactivates each player under the multiplayer.
      # @return [void]
      def deactivate!
        debug "deactivating #{self.class}"
        @players.each(&:deactivate!)
      end

      # Tell all players to begin playback.
      # @return [void]
      # @note Does nothing is playback is already in progress.
      def play
        return unless running?
        @players.each(&:play)
      end

      # Tell all players to pause playback.
      # @return [void]
      # @note Does nothing is playback is already paused.
      def pause
        return unless running?
        @players.each(&:pause)
      end

      # @return [Boolean] Whether or not any of the players are currently playing.
      def playing?
        return false unless running?
        @players.any?(&:playing?)
      end

      # Tell all players to play the next song in its queue.
      # @return [void]
      # @note Does nothing if the current song is the last.
      def next_song
        @players.each(&:next_song)
      end

      # Tell all players to play the previous song in its queue.
      # @return [void]
      # @note Does nothing if the current song is the first.
      def previous_song
        @players.each(&:previous_song)
      end

      # Tell all players to add the given song to its queue.
      # @param song [Song] the song to add
      # @return [void]
      # @note Activates all players if not already activated.
      def enqueue_song(song)
        activate! unless running?
        @players.each { |p| p.enqueue_song(song) }
      end

      # Tell all players to add the given album to its queue.
      # @param album [Album] the album to add
      # @return [void]
      # @note Activates all players if not already activated.
      def enqueue_album(album)
        activate! unless running?
        @players.each { |p| p.enqueue_album(album) }
      end

      # Tell all players to add the given playlist to its queue.
      # @param playlist [Playlist] the playlist to add
      # @return [void]
      # @note Activates all players if not already activated.
      def enqueue_playlist(playlist)
        activate! unless running?
        @players.each { |p| p.enqueue_playlist(playlist) }
      end

      # Get the internal queue of the first player.
      # @return [Array<Song>] all songs in all players's queue
      # @note This includes songs already played.
      def list_queue
        @players.first.list_queue
      end

      # Shuffle the internal queue.
      # @return [void]
      def shuffle_queue
        return unless running?
        # XXX: shuffling is currently done internally within each player,
        # meaning that shuffling within multiplayer would leave each
        # player in an inconsistent queue state.
        # the solution to this is probably to list the queue, shuffle that
        # list, clear the player's queue, and then load the single shuffled
        # list back into each player.
        danger "shuffling doesn't currently make any sense in multiplayer!"
      end

      # Clears the internal queue.
      # @return [void]
      def clear_queue
        return unless running?
        @players.each(&:clear_queue)
      end

      # Get the currently loaded song.
      # @return [Song, nil] the currently loaded song
      def now_playing
        @players[1].now_playing
        @players.first.now_playing
      end
    end
  end
end
