module Muzak
  module Player
    class StubPlayer
      include Utils

      attr_reader :instance

      def initialize(instance)
        @instance = instance
      end

      def running?
        debug "#running?"
      end

      def activate!
        debug "#activate!"
      end

      def deactivate!
        debug "#deactivate!"
      end

      def play
        debug "#play"
      end

      def pause
        debug "#pause"
      end

      def next_song
        debug "#next_song"
      end

      def previous_song
        debug "#previous_song"
      end

      def enqueue_song(song)
        debug "#enqueue_song"
      end

      def enqueue_album(album)
        debug "#enqueue_album"
      end

      def enqueue_playlist(playlist)
        debug "#enqueue_playlist"
      end

      def list_queue
        debug "#list_queue"
      end

      def shuffle_queue
        debug "#shuffle_queue"
      end

      def clear_queue
        debug "#clear_queue"
      end

      def now_playing
        debug "#now_playing"
      end
    end
  end
end
