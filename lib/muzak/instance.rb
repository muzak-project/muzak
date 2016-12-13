module Muzak
  class Instance
    include Cmd
    include Utils

    def command(cmd, *args)
      send Cmd.resolve_command(cmd), *args
    end

    def method_missing(meth, *args)
      warn "unknown command: #{Cmd.resolve_method(meth)}"
      help
    end

    attr_reader :config, :player, :index, :playlist

    def initialize(opts = {})
      $debug = opts[:debug]
      $verbose = opts[:verbose]

      debug "muzak is starting..."

      _config_init unless _config_available?
      config_load

      index_build unless _index_available?
      index_load

      @player = Player::PLAYER_MAP[@config["player"]].new(self)

      @plugins = initialize_plugins!

      playlists_load
      enqueue_playlist @config["autoplay"] if @config["autoplay"]
    end

    def initialize_plugins!
      pks = Plugin.plugin_classes.select { |pk| _config_plugin? pk.plugin_name }
      pks.map { |pk| pk.new(self) }
    end

    def event(type, *args)
      return unless PLUGIN_EVENTS.include?(type)

      @plugins.each do |plugin|
        Thread.new do
          plugin.send(type, *args)
        end.join
      end
    end
  end
end
