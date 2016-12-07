require "yaml"

module Muzak
  module Cmd
    def _config_available?
      File.file?(CONFIG_FILE)
    end

    def _config_loaded?
      !!@config
    end

    def _config_sync
      debug "syncing config hash with #{CONFIG_FILE}"
      File.open(CONFIG_FILE, "w") { |io| io.write @config.to_yaml }
    end

    def _config_init
      debug "creating a config file in #{CONFIG_FILE}"

      @config = {
        "music" => File.expand_path("~/music"),
        "player" => "mpv",
        "index-autobuild" => 86400
      }

      Dir.mkdir(CONFIG_DIR) unless Dir.exist?(CONFIG_DIR)
      _config_sync
    end

    def _config_plugin?(name)
      @config.key?("plugin-#{name}")
    end

    def config_load
      verbose "loading config from #{CONFIG_FILE}"

      @config = YAML::load_file(CONFIG_FILE)
    end

    def config_get(*args)
      return unless _config_loaded?

      fail_arity(args, 1)
      key = args.shift
      return if key.nil?

      info "#{key}: #{@config[key]}"
    end
  end
end
