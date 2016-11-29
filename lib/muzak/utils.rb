module Muzak
  module Utils
    def debug?
      !!@debug
    end

    def verbose?
      !!@verbose
    end

    def pretty(color = :none, str)
      colors = {
        none: 0,
        red: 31,
        green: 32,
        yellow: 33,
        blue: 34
      }

      "\e[#{colors[color]}m#{str}\e[0m"
    end

    def output(box, *args)
      msg = args.join(" ")
      puts "[#{box}] #{msg}"
    end

    def info(*args)
      output pretty(:green, "info"), args
    end

    def warn(*args)
      output pretty(:yellow, "warn"), args
    end

    def error(*args)
      output pretty(:red, "error"), args
    end

    def debug(*args)
      return unless debug?

      output pretty(:yellow, "debug"), args
    end

    def verbose(*args)
      return unless verbose?

      output pretty(:blue, "verbose"), args
    end

    def warn_arity(args, arity)
      warn "expected #{arity} arguments, got #{args.length}" unless args.length == arity
    end

    def fail_arity(args, arity)
      error "needed #{arity} arguments, got #{args.length}" unless args.length == arity
    end
  end
end
