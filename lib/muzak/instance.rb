module Muzak
  class Instance
    include Cmd
    include Utils

    def command(cmd, *args)
      send Utils.resolve_command(cmd), *args
    end

    def method_missing(meth, *args)
      warn "unknown command: #{Utils.resolve_method(meth)}"
      help
    end

    attr_reader :config, :player, :index, :playlist

    def initialize(opts = {})
      $debug = opts[:debug]
      $verbose = opts[:verbose]

      debug "muzak is starting..."

      index_build unless _index_available?
      index_load

      @player = Player::PLAYER_MAP[Config.player].new(self)

      @plugins = initialize_plugins!

      playlists_load
      enqueue_playlist Config.autoplay if Config.autoplay
    end

    def initialize_plugins!
      pks = Plugin.plugin_classes.select { |pk| Config.plugin? pk.plugin_name }
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
