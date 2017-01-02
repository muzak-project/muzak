Dir.glob(File.join(__dir__, "cmd/*")) { |f| require_relative f }

module Muzak
  # The namespace for all commands exposed by muzak.
  # @see file:COMMANDS.md User Commands
  module Cmd
    # load commands included by the user
    Dir.glob(File.join(USER_COMMAND_DIR, "*")) { |file| require file }

    # @return [Array<String>] all valid muzak commands
    def self.commands
      commands = instance_methods.map(&:to_s).reject { |m| m.start_with?("_") }
      commands.map { |c| Utils.resolve_method c }
    end
  end
end
