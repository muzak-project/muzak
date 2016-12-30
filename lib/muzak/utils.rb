module Muzak
  # A collection of convenience utilities for use throughout muzak.
  module Utils
    # Convert the given command into a method (kebab to camel case).
    # @param cmd [String] the command to convert
    # @return [String] the method corresponding to the command
    # @example
    #   resolve_command "do-something" # => "do_something"
    def self.resolve_command(cmd)
      cmd.tr "-", "_"
    end

    # Convert the given method into a command (camel to kebab case).
    # @param meth [String, Symbol] the method to convert
    # @return [String] the command corresponding to the method
    # @example
    #   resolve_method "do_something" # => "do-something"
    def self.resolve_method(meth)
      meth.to_s.tr "_", "-"
    end

    # Tests whether the given filename is likely to be music.
    # @param filename [String] the filename to test
    # @return [Boolean] whether or not the file is a music file
    def music?(filename)
      [".mp3", ".flac", ".m4a", ".wav", ".ogg", ".oga", ".opus"].include?(File.extname(filename.downcase))
    end

    # Tests whether the given filename is likely to be album art.
    # @param filename [String] the filename to test
    # @return [Boolean] whether or not the file is an art file
    def album_art?(filename)
      File.basename(filename) =~ /(cover)|(folder).(jpg)|(png)/i
    end

    # @return [Boolean] whether or not muzak is running in debug mode
    def debug?
      Config.debug
    end

    # @return [Boolean] whether or not muzak is running in verbose mode
    def verbose?
      Config.verbose
    end

    # Formats a string with ANSI colors.
    # @param color [Symbol] the color to use on the string
    # @param str [String] the string to format
    # @return [String] the color-formatted string
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

    # Outputs a boxed message and arguments.
    # @param box [String] the string to box
    # @param args [Array<String>] the trailing strings to print
    # @return [void]
    def output(box, *args)
      msg = args.join(" ")
      puts "[#{box}] #{msg}"
    end

    # Outputs a boxed warning message.
    # @param args [Array<String>] the message(s)
    # @return [void]
    def warn(*args)
      output pretty(:yellow, "warn"), args
    end

    # Outputs a boxed error message.
    # @param args [Array<String>] the message(s)
    # @return [void]
    def error(*args)
      output pretty(:red, "error"), "[#{self.class.name}]", args
    end

    # Outputs a boxed error message and then exits.
    # @param args [Array<String>] the message(s)
    # @return [void]
    def error!(*args)
      error *args
      exit 1
    end

    # Outputs a boxed debugging message.
    # @param args [Array<String>] the message(s)
    # @return [void]
    def debug(*args)
      return unless debug?

      output pretty(:yellow, "debug"), "[#{self.class.name}]", args
    end

    # Outputs a boxed verbose message.
    # @param args [Array<String>] the message(s)
    # @return [void]
    def verbose(*args)
      return unless verbose?

      output pretty(:blue, "verbose"), args
    end

    # Returns a response hash containing the given data and error.
    # @param error [String] the error string, if needed
    # @param data [String, Hash] the data, if needed
    def build_response(error: nil, data: nil)
      { response: {
          error: error,
          data: data,
          method: caller_locations.first.label
        }
      }
    end
  end
end
