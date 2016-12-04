module Muzak
  module Plugin
    class Notify < StubPlugin
      def song_loaded(song)
        notify song.full_title
      end

      private

      def notify(msg)
        pid = Process.spawn("notify-send", "muzak", msg)
        Process.detach(pid)
      end
    end
  end
end
