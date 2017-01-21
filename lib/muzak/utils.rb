module Muzak
  # A collection of convenience utilities for use throughout muzak.
  module Utils
    # Tests whether the given filename is likely to be music.
    # @param filename [String] the filename to test
    # @return [Boolean] whether or not the file is a music file
    def self.music?(filename)
      Config::MUSIC_SUFFIXES.include?(File.extname(filename.downcase))
    end

    # Tests whether the given filename is likely to be album art.
    # @param filename [String] the filename to test
    # @return [Boolean] whether or not the file is an art file
    def self.album_art?(filename)
      File.basename(filename) =~ Config::ALBUM_ART_REGEX
    end

    # Tests whether the given utility is available in the system path.
    # @param util [String] the utility to test
    # @return [Boolean] whether or not the utility is available
    def self.which?(util)
      ENV["PATH"].split(File::PATH_SEPARATOR).any? do |path|
        File.executable?(File.join(path, util))
      end
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
    def danger(*args)
      output pretty(:yellow, "warn"), args
    end

    # Outputs a boxed error message.
    # @param args [Array<String>] the message(s)
    # @return [void]
    def error(*args)
      context = self.is_a?(Module) ? name : self.class.name
      output pretty(:red, "error"), "[#{context}]", args
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
      context = self.is_a?(Module) ? name : self.class.name
      output pretty(:yellow, "debug"), "[#{context}]", args
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
