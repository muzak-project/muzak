require_relative "plugin/stub_plugin"
require_relative "plugin/notify"
require_relative "plugin/scrobble"

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
