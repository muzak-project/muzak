require_relative "plugin/stub_plugin"
require_relative "plugin/notify"

module Muzak
  module Plugin
    PLUGIN_MAP = {
      "notify" => Plugin::Notify
    }
  end
end
