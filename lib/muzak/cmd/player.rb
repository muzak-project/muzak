module Muzak
  module Cmd
    def player_activate
      if @player.running?
        warn "player is already running"
        return
      end

      @player.activate!
    end

    def player_deactivate
      warn "player is not running" unless @player.running?

      # do cleanup even if the player isn't running, just in case
      @player.deactivate!
    end

    def play
      @player.play
    end

    def pause
      @player.pause
    end

    def next
      @player.next_song
    end

    def previous
      @player.previous_song
    end

    def enqueue_artist(*args)
      artist = args.join(" ")
      return if artist.nil?

      albums = @index.albums_by(artist)

      albums.each do |_, album|
        @player.enqueue album["songs"], album["cover"]
      end
    end

    def enqueue_album(*args)
      album = args.join(" ")
      return if album.nil?

      album_hash = @index.albums[album]
      return if album_hash.nil?

      @player.enqueue album_hash["songs"], album_hash["cover"]
    end

    def shuffle_queue
      @player.shuffle_queue
    end

    def clear_queue
      @player.clear_queue
    end

    def now_playing
      info @player.now_playing
    end
  end
end
