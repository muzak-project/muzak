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

    attr_reader :index, :player, :plugins, :playlists

    def initialize(opts = {})
      verbose "muzak is starting..."

      @index = Index.new(Config.music, deep: Config.deep_index)

      @player = Player.load_player!(self)

      @plugins = Plugin.load_plugins!

      @playlists = Playlist.load_playlists!

      enqueue_playlist Config.autoplay if Config.autoplay
    end

    def event(type, *args)
      return unless PLUGIN_EVENTS.include?(type)

      plugins.each do |plugin|
        Thread.new do
          plugin.send(type, *args)
        end
      end
    end
  end
end
