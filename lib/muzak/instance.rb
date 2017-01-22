module Muzak
  # Encapsulates the entirety of muzak's running state.
  class Instance
    include Cmd
    include Utils

    # Sends a command to the instance.
    # @param cmd [String] the name of the command
    # @param args [Array<String>] the command's arguments
    # @return [Hash] the command's response hash
    # @example
    #   instance.command "enqueue-playlist", "favorites"
    #   instance.command "pause"
    def command(cmd, *args)
      if Cmd.commands.include?(cmd)
        meth = method(Config.resolve_command(cmd))
        if meth.arity == args.size || meth.arity <= -1
          meth.call *args
        else
          build_response error: "got #{args.size} args, needed #{meth.arity}"
        end
      else
        danger "unknown command: '#{cmd}'"
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

    def initialize
      verbose "muzak is starting..."

      error! "#{Config.music} doesn't exist" unless File.exist?(Config.music)

      @index = Index.load_index!

      @player = Player.load_player!(self)

      @plugins = Plugin.load_plugins!

      @playlists = Playlist.load_playlists!

      enqueue_playlist Config.default_playlist if Config.default_playlist

      event :instance_started, self
    end

    # Dispatch an event to all plugins.
    # @param type [Symbol] the type of event to dispatch
    # @param args [Array] the event's arguments
    # @return [void]
    # @note {Config::PLUGIN_EVENTS} contains all valid events.
    def event(type, *args)
      return unless Config::PLUGIN_EVENTS.include?(type)

      plugins.each do |plugin|
        Thread.new do
          plugin.send(type, *args)
        end
      end
    end
  end
end
