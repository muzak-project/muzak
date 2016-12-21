# we have to require StubPlayer first because ruby's module resolution is bad
require_relative "player/stub_player"

Dir.glob(File.join(__dir__, "player/*")) { |file| require_relative file }

module Muzak
  # The namespace for muzak players.
  module Player
    # An association of shorthand player "names" to Class objects.
    PLAYER_MAP = {
      "stub" => Player::StubPlayer,
      "mpv" => Player::MPV
    }.freeze

    # Returns an instantiated player as specified in `Config.player`.
    # @return [StubPlayer] the player instance
    def self.load_player!(instance)
      PLAYER_MAP[Config.player].new(instance)
    end
  end
end
