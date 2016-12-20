# we have to require StubPlugin first because ruby's module resolution is bad
require_relative "plugin/stub_plugin"

# load plugins included with muzak
Dir.glob(File.join(__dir__, "plugin/*")) { |file| require_relative file }

module Muzak
  module Plugin
    # load plugins included by the user
    Dir.glob(File.join(USER_PLUGIN_DIR, "*")) { |file| require file }

    def self.plugin_classes
      constants.map(&Plugin.method(:const_get)).grep(Class)
    end

    def self.plugin_names
      plugin_classes.map do |pk|
        pk.plugin_name
      end
    end

    def self.load_plugins!
      pks = Plugin.plugin_classes.select { |pk| Config.plugin? pk.plugin_name }
      pks.map { |pk| pk.new }
    end

    PLUGIN_MAP = plugin_names.zip(plugin_classes).to_h.freeze
  end
end
