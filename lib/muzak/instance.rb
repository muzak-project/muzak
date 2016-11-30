module Muzak
  class Instance
    include Cmd
    include Utils

    def method_missing(meth)
      warn "unknown command: #{meth.to_s}"
      help
    end

    attr_reader :config, :player, :index

    def initialize(opts = {})
      $debug = opts[:debug]
      $verbose = opts[:verbose]

      debug "muzak is starting..."

      _config_init unless _config_available?
      config_load

      index_build unless _index_available?
      index_load

      @player = Player::PLAYER_MAP[@config["player"]].new
    end
  end
end
