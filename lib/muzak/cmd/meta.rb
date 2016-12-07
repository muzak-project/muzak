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
      debug "muzak is quitting..."
      @player.deactivate!
      exit
    end
  end
end
