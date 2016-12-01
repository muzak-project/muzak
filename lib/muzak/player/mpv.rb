require "tempfile"
require "socket"
require "json"

module Muzak
  module Player
    class MPV
      include Utils

      attr_accessor :instance

      def initialize(instance)
        @instance = instance
        @queue = []
        @index = -1
      end

      def running?
        begin
          @pid && Process.waitpid(@pid, Process::WNOHANG).nil?
        rescue Errno::ECHILD
          false
        end
      end

      def activate!
        return if running?

        debug "activating #{self.class}"

        @sock_path = Dir::Tmpname.make_tmpname("/tmp/mpv", ".sock")
        mpv_args = [
          "--idle",
          "--no-osc",
          "--no-osd-bar",
          "--no-input-default-bindings",
          "--no-input-cursor",
          "--no-terminal",
          "--input-ipc-server=%{socket}" % { socket: @sock_path }
        ]

        mpv_args << "--geometry=#{instance.config["art-geometry"]}" if instance.config["art-geometry"]

        @pid = Process.spawn("mpv", *mpv_args)

        until File.exists?(@sock_path)
          sleep 0.1
        end

        @socket = UNIXSocket.new(@sock_path)
      end

      def deactivate!
        return unless running?

        debug "deactivating #{self.class}"

        command "quit"
        Process.kill :TERM, @pid
        Process.wait @pid
        @socket.close
        File.delete(@sock_path) if File.exists?(@sock_path)
        @pid = nil
      end

      def play
        return unless running?

        set_property "pause", false
      end

      def pause
        return unless running?

        set_property "pause", true
      end

      def playing?
        return false unless running?

        !get_property "pause"
      end

      def next_song
        return unless running?
        return if @index >= @queue.length

        load_song *@queue[@index += 1]
      end

      def previous_song
        return unless running?
        return if @index <= 0

        load_song *@queue[@index -= 1]
      end

      def enqueue_album(album)
        activate! unless running?

        album.songs.each do |song|
          @queue << [song, album.cover_art]
        end

        next_song if @index < 0 # start playing if the user starts a new queue
      end

      def list_queue
        @queue.map { |e| e.first.path }
      end

      def shuffle_queue
        @queue.shuffle!
        @index = 0
      end

      def clear_queue
        @queue = []
        @index = -1
      end

      def now_playing
        return "nothing is playing" unless running?

        get_property "media-title"
      end

      private

      def load_song(song, album_art = nil)
        cmds = ["loadfile", song.path, "replace"]
        cmds << "external-file=#{album_art}" if album_art

        command *cmds

        debug "#{self.class} sending song_loaded event"
        instance.event :song_loaded, song
      end

      def command(*args)
        return unless running?

        payload = {
          "command" => args
        }

        debug "mpv payload: #{payload.to_s}"

        @socket.puts(JSON.generate(payload))

        loop do
          response = JSON.parse(@socket.readline)

          next if response["event"]

          error "mpv: #{response["error"]}" if response["error"] != "success"

          return response
        end
      end

      def set_property(*args)
        command "set_property", *args
      end

      def get_property(*args)
        command("get_property", *args)["data"]
      end
    end
  end
end
