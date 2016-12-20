# we have to require StubPlayer first because ruby's module resolution is bad
require_relative "player/stub_player"

Dir.glob(File.join(__dir__, "player/*")) { |file| require_relative file }

module Muzak
  module Player
    PLAYER_MAP = {
      "stub" => Player::StubPlayer,
      "mpv" => Player::MPV
    }.freeze

    def self.load_player!(instance)
      PLAYER_MAP[Config.player].new(instance)
    end
  end
end
