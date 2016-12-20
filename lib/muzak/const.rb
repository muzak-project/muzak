module Muzak
  # Muzak's current version
  VERSION = "0.0.11".freeze

  # The root directory for all user configuration, data, etc
  CONFIG_DIR = File.expand_path("~/.config/muzak").freeze

  # Muzak's primary configuration file
  # @see Muzak::Config
  CONFIG_FILE = File.join(CONFIG_DIR, "muzak.yml").freeze

  # Muzak's music index
  INDEX_FILE = File.join(CONFIG_DIR, "index.dat").freeze

  # The directory for all user playlists
  PLAYLIST_DIR = File.join(CONFIG_DIR, "playlists").freeze

  # The directory for all user plugins
  USER_PLUGIN_DIR = File.join(CONFIG_DIR, "plugins").freeze

  # The directory for all user commands
  USER_COMMAND_DIR = File.join(CONFIG_DIR, "commands").freeze

  # All events currently propagated by {Muzak::Instance#event}
  PLUGIN_EVENTS = [
    :player_activated,
    :player_deactivated,
    :song_loaded,
    :song_unloaded,
    :playlist_enqueued
  ]
end
