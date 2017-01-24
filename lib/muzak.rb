require_relative "muzak/config"
require_relative "muzak/utils"
require_relative "muzak/plugin"
require_relative "muzak/song"
require_relative "muzak/album"
require_relative "muzak/playlist"
require_relative "muzak/index"
require_relative "muzak/cmd"
require_relative "muzak/player"
require_relative "muzak/instance"

# The primary namespace for muzak.
module Muzak
  # Muzak's current version
  VERSION = "0.3.4".freeze
end
