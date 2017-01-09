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
    # Catches all undefined configuration keys and defaults them to false.
    # @return [false]
    def self.method_missing(method, *args)
      false
    end

    # Synchronizes the in-memory configuration with {CONFIG_FILE}.
    # @return [void]
    def self.sync!
      File.open(CONFIG_FILE, "w") { |io| io.write @config.to_yaml }
    end

    # @return [Boolean] whether or not the given plugin is configured
    # @note the truth-value of this method is used to determine which
    #   plugins should be loaded.
    def self.plugin?(pname)
      respond_to? "plugin_#{pname}"
    end

    DEFAULT_CONFIG = {
      # core defaults
      "debug" => false,
      "verbose" => true,
      "music" => File.expand_path("~/music"),
      "player" => "mpv",
      "jukebox-size" => 100,

      # client/daemon defaults
      "daemon-port" => 2669,
      "daemon-host" => "localhost",
    }.freeze

    if File.exist?(CONFIG_FILE)
      user_config = YAML::load_file(CONFIG_FILE)
    else
      user_config = DEFAULT_CONFIG

      [CONFIG_DIR, PLAYLIST_DIR, USER_PLUGIN_DIR, USER_COMMAND_DIR].each do |d|
        FileUtils.mkdir_p d
      end

      sync!
    end

    @config = DEFAULT_CONFIG.merge(user_config)

    @config.each do |key, _|
      define_singleton_method Utils.resolve_command(key) do
        @config[key]
      end

      define_singleton_method "#{Utils.resolve_command(key)}=" do |value|
        @config[key] = value
        sync!
      end
    end
  end
end
