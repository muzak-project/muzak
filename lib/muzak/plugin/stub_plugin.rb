module Muzak
  module Plugin
    # A no-op plugin that all real plugins inherit from.
    class StubPlugin
      include Utils

      # The plugin's human friendly name.
      # @return [String] the name
      def self.plugin_name
        name.split("::").last.downcase
      end

      def initialize
        debug "loading #{self.class}"
      end

      Config::PLUGIN_EVENTS.each do |event|
        define_method(event) do |*args|
          nil # do nothing.
        end
      end
    end
  end
end

