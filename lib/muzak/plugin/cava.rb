require "shellwords"

module Muzak
  module Plugin
    class Cava < StubPlugin
      include Utils

      def initialize(instance)
        super
        @term_args = Shellwords.split instance.config["plugin-cava"]
        @pid = nil
      end

      def player_activated
        start_cava! unless cava_running?
      end

      def player_deactivated
        stop_cava! if cava_running?
      end

      private

      def cava_running?
        begin
          !!@pid && Process.waitpid(@pid, Process::WNOHANG).nil?
        rescue Errno::ECHILD
          false
        end
      end

      def start_cava!
        args = [*@term_args, "-e", "cava"]
        @pid = Process.spawn(*args)
      end

      def stop_cava!
        Process.kill :TERM, @pid
        Process.wait @pid
        @pid = nil
      end
    end
  end
end
