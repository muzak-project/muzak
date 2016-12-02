module Muzak
  module Plugin
    class Notify < StubPlugin
      def song_loaded(song)
        msg = song.title.dup
        msg << " by #{song.artist}" if song.artist
        notify msg
      end

      private

      def notify(msg)
        pid = Process.spawn("notify-send", "muzak", msg)
        Process.detach(pid)
      end
    end
  end
end
