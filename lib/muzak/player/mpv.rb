require "tempfile"
require "socket"
require "json"

module Muzak
  module Player
    class MPV
      include Utils

      def initialize
        @running = false
      end

      def running?
        @running
      end

      def activate!
        return if running?

        @sock_path = Dir::Tmpname.make_tmpname("/tmp/mpv", ".sock")
        mpv_args = [
          "--idle",
          "--no-terminal",
          "--input-ipc-server=%{socket}" % { socket: @sock_path }
        ]

        @pid = Process.spawn("mpv", *mpv_args)

        until File.exists?(@sock_path)
          sleep 0.1
        end

        @socket = UNIXSocket.new(@sock_path)
        @running = true
      end

      def deactivate!
        return unless running?

        command("quit")
        Process.kill :TERM, @pid
        Process.wait @pid
        @socket.close
        File.delete(@sock_path) if File.exists?(@sock_path)
        @running = false
      end

      def play
        return unless running?

        set_property "pause", false
      end

      def pause
        return unless running?

        set_property "pause", true
      end

      def next
        return unless running?

        command "playlist-next"
      end

      def previous
        return unless running?

        command "playlist-prev"
      end

      def enqueue(files, album_art = nil)
        activate! unless running?

        files.each do |file|
          cmds = ["loadfile", file, "append-play"]
          cmds << "external-file=#{album_art}" if album_art
          command *cmds
        end
      end

      private

      def command(*args)
        return unless running?

        payload = {
          "command" => args
        }

        debug "mpv payload: #{payload.to_s}"

        @socket.puts(JSON.generate(payload))

        loop do
          response = JSON.parse(@socket.readline)

          # we're not interested in event messages, only responses
          next if response["event"]

          error "mpv: #{response["error"]}" if response["error"] != "success"

          return response
        end
      end

      def set_property(*args)
        command "set_property", *args
      end
    end
  end
end
