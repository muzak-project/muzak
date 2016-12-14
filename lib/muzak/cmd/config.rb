require "yaml"

module Muzak
  module Cmd
    def config_get(*args)
      fail_arity(args, 1)
      key = args.shift
      return if key.nil?

      info "#{key}: #{Config.send Utils.resolve_method(key)}"
    end
  end
end
