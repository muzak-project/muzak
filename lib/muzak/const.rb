module Muzak
  CONFIG_DIR = File.expand_path("~/.config/muzak").freeze
  CONFIG_FILE = File.join(CONFIG_DIR, "muzak.yml").freeze
  INDEX_FILE = File.join(CONFIG_DIR, "index.yml").freeze
  PLAYLIST_DIR = File.join(CONFIG_DIR, "playlists").freeze

  PLUGIN_EVENTS = [
    :player_activated,
    :player_deactivated,
    :song_loaded
  ]
end
