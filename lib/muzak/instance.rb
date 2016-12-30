module Muzak
  # Encapsulates the entirety of muzak's running state.
  class Instance
    include Cmd
    include Utils

    # Sends a command to the instance.
    # @param cmd [String] the name of the command
    # @param args [Array<String>] the command's arguments
    # @example
    #   instance.command "enqueue-playlist", "favorites"
    #   instance.command "pause"
    def command(cmd, *args)
      if Cmd.commands.include?(cmd)
        meth = method(Utils.resolve_command(cmd))
        if meth.arity == args.size || meth.arity <= -1
          meth.call *args
        else
          build_response error: "got #{args.size} args, needed #{meth.arity}"
        end
      else
        warn "unknown command: '#{cmd}'"
        build_response error: "unknown command '#{cmd}'"
      end
    end

    # @return [Index] the instance's music index
    attr_reader :index

    # @return [StubPlayer] the instance's player
    attr_reader :player

    # @return [Array<StubPlugin>] the instance's plugins
    attr_reader :plugins

    # @return [Hash{String => Playlist}] the instance's playlists
    attr_reader :playlists

    def initialize(opts = {})
      verbose "muzak is starting..."

      error! "#{Config.music} doesn't exist" unless File.exist?(Config.music)

      @index = Index.load_index!

      @player = Player.load_player!(self)

      @plugins = Plugin.load_plugins!

      @playlists = Playlist.load_playlists!

      enqueue_playlist Config.autoplay if Config.autoplay
    end

    # Dispatch an event to all plugins.
    # @param type [Symbol] the type of event to dispatch
    # @param args [Array] the event's arguments
    # @note {Muzak::PLUGIN_EVENTS} contains all valid events.
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
