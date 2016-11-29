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
      unless @player.running?
        warn "player is not running"
        return
      end

      @player.deactivate!
    end

    def play
      @player.play
    end

    def pause
      @player.pause
    end

    def next
      @player.next
    end

    def previous
      @player.previous
    end

    def enqueue_artist(*args)
      artist = args.join(" ")
      return if artist.nil?

      @player.enqueue @index.songs_by(artist)
    end

    def enqueue_album(*args)
      album = args.join(" ")
      return if album.nil?

      album_hash = @index.albums[album]
      return if album_hash.nil?

      @player.enqueue album_hash["songs"], album_hash["cover"]
    end
  end
end
