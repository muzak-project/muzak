module Muzak
  VERSION = "0.0.9".freeze

  CONFIG_DIR = File.expand_path("~/.config/muzak").freeze
  CONFIG_FILE = File.join(CONFIG_DIR, "muzak.yml").freeze
  INDEX_FILE = File.join(CONFIG_DIR, "index.yml").freeze
  PLAYLIST_DIR = File.join(CONFIG_DIR, "playlists").freeze
  USER_PLUGIN_DIR = File.join(CONFIG_DIR, "plugins").freeze
  USER_COMMAND_DIR = File.join(CONFIG_DIR, "commands").freeze

  PLUGIN_EVENTS = [
    :player_activated,
    :player_deactivated,
    :song_loaded,
    :playlists_loaded,
    :playlist_enqueued
  ]
end
