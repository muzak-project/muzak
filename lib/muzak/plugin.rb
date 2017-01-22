# we have to require StubPlugin first because ruby's module resolution is bad
require_relative "plugin/stub_plugin"

# load plugins included with muzak
Dir.glob(File.join(__dir__, "plugin/*")) { |file| require_relative file }

module Muzak
  # The namespace for muzak plugins.
  module Plugin
    # load plugins included by the user
    Dir.glob(File.join(Config::USER_PLUGIN_DIR, "*")) { |file| require file }

    # All classes (plugins) under the {Player} namespace.
    # @see Plugin::StubPlugin.plugin_name
    # @api private
    PLUGIN_CLASSES = constants.map(&Plugin.method(:const_get)).grep(Class).freeze

    # All human-friendly player plugin names.
    # @api private
    PLUGIN_NAMES = PLUGIN_CLASSES.map(&:plugin_name).freeze

    # An association of human-friendly plugin names to plugin classes.
    # @api private
    PLUGIN_MAP = PLUGIN_NAMES.zip(PLUGIN_CLASSES).to_h.freeze

    # Instantiates all configured plugins and returns them.
    # @return [Array<StubPlugin>] the instantiated plugins
    def self.load_plugins!
      pks = PLUGIN_CLASSES.select { |pk| Config.plugin? pk.plugin_name }
      pks.map { |pk| pk.new }
    end
  end
end
