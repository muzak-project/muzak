require_relative "plugin/stub_plugin"
require_relative "plugin/notify"
require_relative "plugin/scrobble"

module Muzak
  module Plugin
    PLUGIN_MAP = {
      "notify" => Plugin::Notify
    }
  end
end
