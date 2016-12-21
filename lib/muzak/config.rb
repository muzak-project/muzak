require "yaml"

module Muzak
  # Muzak's static configuration dumping ground.
  # Key-value pairs are loaded from {CONFIG_FILE} and translated from
  # kebab-case to snake_case methods.
  # @example
  #   # corresponds to `art-geometry: 300x300` in configuration
  #   Config.art_geometry # => "300x300"
  class Config
    if File.exist?(CONFIG_FILE)
      @config = YAML::load_file(CONFIG_FILE)
    else
      @config = {
        "debug" => false,
        "verbose" => false,
        "music" => File.expand_path("~/music"),
        "player" => "mpv",
        "index-autobuild" => 86400,
        "deep-index" => false,
        "jukebox-size" => 100
      }

      File.open(CONFIG_FILE, "w") { |io| io.write @config.to_yaml }
    end

    @config.each do |key, value|
      define_singleton_method Utils.resolve_command(key) do
        value
      end
    end

    # Catches all undefined configuration keys and defaults them to false.
    # @return [false]
    def self.method_missing(method, *args)
      false
    end

    # @return [Boolean] whether or not the given plugin is configured
    # @note the truth-value of this method is used to determine which
    #   plugins should be loaded.
    def self.plugin?(pname)
      respond_to? "plugin_#{pname}"
    end
  end
end
