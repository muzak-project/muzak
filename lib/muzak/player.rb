# frozen_string_literal: true

# we have to require StubPlayer first because ruby's module resolution is bad
require_relative "player/stub_player"

Dir.glob(File.join(__dir__, "player/*")) { |file| require_relative file }

module Muzak
  # The namespace for muzak players.
  module Player
    extend Utils

    # All classes (player implementations) under the {Player} namespace.
    # @api private
    PLAYER_CLASSES = constants.map(&Player.method(:const_get)).grep(Class).freeze

    # All human-friendly player names.
    # @see Player::StubPlayer.player_name
    # @api private
    PLAYER_NAMES = PLAYER_CLASSES.map(&:player_name).freeze

    # An association of human-friendly player names to implementation classes.
    # @api private
    PLAYER_MAP = PLAYER_NAMES.zip(PLAYER_CLASSES).to_h.freeze

    # Returns an instantiated player as specified in `Config.player`.
    # @return [StubPlayer] the player instance
    def self.load_player!(instance)
      klass = PLAYER_MAP[Config.player]

      error! "#{Config.player} isn't a known player" unless klass

      if klass.available?
        klass.new(instance)
      else
        error! "#{Config.player} isn't available, do you need to install it?"
      end
    end
  end
end
