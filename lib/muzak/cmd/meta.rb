module Muzak
  module Cmd
    def help(*args)
      commands = Muzak::Cmd.commands.join(", ")
      info "available commands: #{commands}"
    end

    def list_plugins
      plugins = Plugin.plugin_names.join(", ")
      puts "available plugins: #{plugins}"
    end

    def quit
      verbose "muzak is quitting..."
      @player.deactivate!
    end
  end
end
