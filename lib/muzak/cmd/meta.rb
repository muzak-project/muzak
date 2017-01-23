module Muzak
  module Cmd
    # Return a simple heartbeat message.
    # @command `ping`
    # @cmdexample `muzak> ping`
    def ping
      timestamp = Time.now.to_i
      debug "pong: #{timestamp}"

      build_response data: {
        pong: timestamp
      }
    end

    # Return a "helpful" listing of commands.
    # @command `help`
    # @cmdexample `muzak> help`
    def help(*args)
      build_response data: {
        commands: Muzak::Cmd.commands
      }
    end

    # List all available plugins.
    # @command `list-plugins`
    # @cmdexample `muzak> list-plugins`
    # @note This list will differ from loaded plugins, if not all available
    #   plugins are configured.
    def list_plugins
      build_response data: {
        plugins: Plugin.plugin_names
      }
    end

    # Terminates the muzak instance (**not** just the client).
    # @command `quit`
    # @cmdexample `muzak> quit`
    def quit
      verbose "muzak is quitting..."
      player.deactivate!

      event :instance_quitting
      build_response data: "quitting"
    end
  end
end
