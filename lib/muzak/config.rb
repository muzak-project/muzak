# frozen_string_literal: true

require "yaml"
require "fileutils"

module Muzak
  # Muzak's static configuration dumping ground.
  # Key-value pairs are loaded from {CONFIG_FILE} and translated from
  # kebab-case to snake_case methods.
  # @example
  #   # corresponds to `art-geometry: 300x300` in configuration
  #   Config.art_geometry # => "300x300"
  # @see file:CONFIGURATION.md User Configuration
  class Config
    # The root directory for all user configuration, data, etc
    CONFIG_DIR = File.expand_path("~/.config/muzak").freeze

    # Muzak's primary configuration file
    # @see Muzak::Config
    CONFIG_FILE = File.join(CONFIG_DIR, "muzak.yml").freeze

    # Muzak's music index
    INDEX_FILE = File.join(CONFIG_DIR, "index.dat").freeze

    # The directory for all user playlists
    PLAYLIST_DIR = File.join(CONFIG_DIR, "playlists").freeze

    # The glob pattern for all user playlists
    PLAYLIST_GLOB = File.join(PLAYLIST_DIR, "*.yml").freeze

    # The directory for all user plugins
    USER_PLUGIN_DIR = File.join(CONFIG_DIR, "plugins").freeze

    # The directory for all user commands
    USER_COMMAND_DIR = File.join(CONFIG_DIR, "commands").freeze

    # All filename suffixes that muzak recognizes as music.
    MUSIC_SUFFIXES = [
      ".mp3",
      ".flac",
      ".m4a",
      ".wav",
      ".ogg",
      ".oga",
      ".opus",
    ].freeze

    # The regular expression that muzak uses to find album art.
    ALBUM_ART_REGEX = /(cover)|(folder).(jpg)|(png)/i

    # All events currently propagated by {Muzak::Instance#event}
    PLUGIN_EVENTS = %i[
      instance_started
      instance_quitting
      player_activated
      player_deactivated
      song_loaded
      song_unloaded
      playlist_enqueued
    ].freeze

    # The default configuration keys and values.
    DEFAULT_CONFIG = {
      # core defaults
      "events" => true,
      "debug" => false,
      "verbose" => true,
      "music" => File.expand_path("~/music"),
      "player" => "mpv",
      "jukebox-size" => 100,
      "autoplay" => false,

      # client/daemon defaults
      "daemon-port" => 2669,
      "daemon-host" => "localhost",
    }.freeze

    # Convert the given command into a method (kebab to camel case).
    # @param cmd [String] the command to convert
    # @return [String] the method corresponding to the command
    # @example
    #   resolve_command "do-something" # => "do_something"
    def self.resolve_command(cmd)
      cmd.tr "-", "_"
    end

    # Convert the given method into a command (camel to kebab case).
    # @param meth [String, Symbol] the method to convert
    # @return [String] the command corresponding to the method
    # @example
    #   resolve_method "do_something" # => "do-something"
    def self.resolve_method(meth)
      meth.to_s.tr "_", "-"
    end

    # Catches all undefined configuration keys and defaults them to false.
    # @return [false]
    def self.method_missing(method, *args)
      # this is basically useless, since respond_to_missing? will always be true,
      # but it gets RuboCop to shut up.
      if respond_to_missing? method, *args
        false
      else
        super
      end
    end

    # We "respond" to all methods with a default of false, so this is always true.
    # @return [true]
    def self.respond_to_missing?(*_args)
      true
    end

    # @return [Boolean] whether or not the given plugin is configured
    # @note the truth-value of this method is used in part to determine which
    #   plugins should be loaded.
    def self.plugin?(pname)
      respond_to? "plugin_#{pname}"
    end

    if File.exist?(CONFIG_FILE)
      user_config = YAML.load_file(CONFIG_FILE)
    else
      user_config = DEFAULT_CONFIG

      [CONFIG_DIR, PLAYLIST_DIR, USER_PLUGIN_DIR, USER_COMMAND_DIR].each do |d|
        FileUtils.mkdir_p d
      end

      File.open(CONFIG_FILE, "w") { |io| io.write DEFAULT_CONFIG.to_yaml }
    end

    @config = DEFAULT_CONFIG.merge(user_config)

    @config.each do |key, _|
      define_singleton_method resolve_command(key) do
        @config[key]
      end

      define_singleton_method "#{resolve_command(key)}=" do |value|
        @config[key] = value
        File.open(CONFIG_FILE, "w") { |io| io.write @config.to_yaml }
      end
    end
  end
end
