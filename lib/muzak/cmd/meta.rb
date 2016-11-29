module Muzak
  module Cmd
    def help(*args)
      commands = Muzak::Cmd.humanize_commands!.join(", ")
      info "available commands: #{commands}"
    end

    def quit
      debug "muzak is quitting..."
      @player.deactivate!
      exit
    end
  end
end
