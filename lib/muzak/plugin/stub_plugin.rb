module Muzak
  module Plugin
    class StubPlugin
      include Utils

      def self.plugin_name
        name.split("::").last.downcase
      end

      def initialize
        debug "loading #{self.class}"
      end

      PLUGIN_EVENTS.each do |event|
        define_method(event) do |*args|
          nil # do nothing.
        end
      end
    end
  end
end

