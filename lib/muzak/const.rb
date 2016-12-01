module Muzak
  CONFIG_DIR = File.expand_path("~/.config/muzak")

  PLUGIN_EVENTS = [
    :song_loaded
  ]
end
