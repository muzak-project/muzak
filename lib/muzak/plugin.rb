# we have to require StubPlugin first because ruby's module resolution is bad
require_relative "plugin/stub_plugin"

Dir.glob(File.join(__dir__, "plugin/*")) { |file| require_relative file }

module Muzak
  module Plugin
    def self.plugin_classes
      constants.map(&Plugin.method(:const_get)).grep(Class)
    end

    def self.plugin_names
      plugin_classes.map do |pk|
        pk.plugin_name
      end
    end

    PLUGIN_MAP = plugin_names.zip(plugin_classes).to_h.freeze
  end
end
