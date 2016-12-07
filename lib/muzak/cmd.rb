Dir.glob(File.join(__dir__, "cmd/*")) { |f| require_relative f }

module Muzak
  module Cmd
    def self.resolve_command(cmd)
      cmd.tr "-", "_"
    end

    def self.resolve_method(meth)
      meth.to_s.tr "_", "-"
    end

    def self.commands
      commands = instance_methods.map(&:to_s).reject { |m| m.start_with?("_") }
      commands.map { |c| c.tr "_", "-" }
    end
  end
end
