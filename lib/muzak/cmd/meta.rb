module Muzak
  module Cmd
    # Print a "helpful" listing of commands.
    # @command `help`
    # @cmdexample `muzak> help`
    def help(*args)
      commands = Muzak::Cmd.commands.join(", ")
      info "available commands: #{commands}"
    end

    # List all available plugins.
    # @command `list-plugins`
    # @cmdexample `muzak> list-plugins`
    # @note This list will differ from loaded plugins, if not all available
    #   plugins are configured.
    def list_plugins
      plugins = Plugin.plugin_names.join(", ")
      puts "available plugins: #{plugins}"
    end

    # Terminates the muzak instance (**not** just the client).
    # @command `quit`
    # @cmdexample `muzak> quit`
    def quit
      verbose "muzak is quitting..."
      player.deactivate!
    end
  end
end
