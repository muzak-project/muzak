module Muzak
  class Config
    def self.exist?
      File.exist?(CONFIG_FILE)
    end

    def self.load!
      if exist?
        @config = YAML::load_file(CONFIG_FILE)
      else
        @config = {
          "music" => File.expand_path("~/music"),
          "player" => "mpv",
          "index-autobuild" => 86400,
          "deep-index" => false,
          "jukebox-size" => 100
        }

        # we only need to sync in the initialization case
        sync!
      end

      @config.each do |key, value|
        define_singleton_method Cmd.resolve_command(key).to_s do
          value
        end
      end
    end

    # if a key doesn't exist, assume it's false
    def self.method_missing(method, *args)
      false
    end

    def self.plugin?(pname)
      respond_to? "plugin_#{pname}"
    end

    def self.sync!
      File.open(CONFIG_FILE, "w") { |io| io.write @config.to_yaml }
    end
  end
end
