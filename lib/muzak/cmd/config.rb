require "yaml"

module Muzak
  module Cmd
    # Query the {Muzak::Config} for a given key.
    # @command `config-get <key>`
    # @cmdexample `muzak> config-get player`
    def config_get(key)
      value = Config.send Config.resolve_command(key)

      build_response data: { key => value }
    end
  end
end
