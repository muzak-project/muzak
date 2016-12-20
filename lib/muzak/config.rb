require "yaml"

module Muzak
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

    # if a key doesn't exist, assume it's false
    def self.method_missing(method, *args)
      false
    end

    def self.plugin?(pname)
      respond_to? "plugin_#{pname}"
    end
  end
end
