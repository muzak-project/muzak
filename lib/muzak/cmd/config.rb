require "yaml"

module Muzak
  module Cmd
    # Query the {Muzak::Config} for a given key.
    # @command `config-get <key>`
    # @cmdexample `muzak> config-get player`
    def config_get(*args)
      fail_arity(args, 1)
      key = args.shift
      return if key.nil?

      info "#{key}: #{Config.send Utils.resolve_method(key)}"
    end
  end
end
