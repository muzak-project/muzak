module Muzak
  module Cmd
    def player_activate
      if player.running?
        warn "player is already running"
        return
      end

      player.activate!
    end

    def player_deactivate
      warn "player is not running" unless player.running?

      # do cleanup even if the player isn't running, just in case
      player.deactivate!
    end

    def play
      player.play
    end

    def pause
      player.pause
    end

    def toggle
      if player.playing?
        player.pause
      else
        player.play
      end
    end

    def next
      player.next_song
    end

    def previous
      player.previous_song
    end

    def enqueue_artist(*args)
      artist = args.join(" ")
      return if artist.nil?

      albums = index.albums_by(artist)
      return if albums.empty?

      albums.each do |album|
        player.enqueue_album album
      end
    end

    def enqueue_album(*args)
      album_name = args.join(" ")
      return if album_name.nil?

      debug album_name
      album = index.albums[album_name]
      debug album.to_s
      return if album.nil?

      player.enqueue_album album
    end

    def jukebox(*args)
      count = args.shift || Config.jukebox_size

      songs = index.jukebox(count.to_i)

      songs.each { |s| player.enqueue_song s }
    end

    def list_queue
      puts player.list_queue.map(&:title)
    end

    def shuffle_queue
      player.shuffle_queue
    end

    def clear_queue
      player.clear_queue
    end

    def now_playing
      return unless player.playing?

      info player.now_playing.full_title
    end
  end
end
