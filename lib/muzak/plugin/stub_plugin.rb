module Muzak
  module Plugin
    class StubPlugin
      attr_reader :instance

      def initialize(instance)
        @instance = instance
        puts "loading #{self.class}"
      end

      PLUGIN_EVENTS.each do |event|
        define_method(event) do |*args|
          nil # do nothing.
        end
      end
    end
  end
end

