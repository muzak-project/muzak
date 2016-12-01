module Muzak
  class Instance
    include Cmd
    include Utils

    def method_missing(meth, *args)
      warn "unknown command: #{meth.to_s}"
      help
    end

    attr_reader :config, :player, :index

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
    end

    def initialize_plugins!
      plugin_klasses = Plugin.constants.map(&Plugin.method(:const_get)).grep(Class)
      @plugins = plugin_klasses.map { |pk| pk.new(self) }
    end

    def event(type, *args)
      return unless PLUGIN_EVENTS.include?(type)

      @plugins.each do |plugin|
        Thread.new do
          plugin.send(type, *args)
        end
      end
    end
  end
end
