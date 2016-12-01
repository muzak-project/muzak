module Muzak
  module Plugin
    class StubPlugin
      include Utils
      attr_reader :instance

      def initialize(instance)
        @instance = instance
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

