module Muzak
  CONFIG_DIR = File.expand_path("~/.config/muzak")

  PLUGIN_EVENTS = [
    :player_activated,
    :player_deactivated,
    :song_loaded
  ]
end
