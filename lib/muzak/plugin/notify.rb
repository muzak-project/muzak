module Muzak
  module Plugin
    class Notify < StubPlugin
      def song_loaded(song)
        notify song.full_title
      end

      private

      def notify(msg)
        return if msg.nil? || msg.empty?
        pid = Process.spawn("notify-send", "muzak", msg)
        Process.detach(pid)
      end
    end
  end
end
