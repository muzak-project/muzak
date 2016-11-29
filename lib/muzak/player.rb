Dir.glob(File.join(__dir__, "player/*")) { |file| require_relative file }

module Muzak
  module Player
    PLAYER_MAP = {
      "mpv" => Player::MPV
    }
  end
end
