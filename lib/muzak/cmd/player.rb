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

    def toggle
      if @player.playing?
        @player.pause
      else
        @player.play
      end
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

      album_hashes = @index.albums_by(artist)
      return if album_hashes.empty?

      albums = album_hashes.map do |album_name, album_hash|
        Album.new(album_name, album_hash)
      end

      albums.each do |album|
        @player.enqueue_album album
      end
    end

    def enqueue_album(*args)
      album_name = args.join(" ")
      return if album_name.nil?

      album_hash = @index.albums[album_name]
      return if album_hash.nil?

      album = Album.new(album_name, album_hash)

      @player.enqueue_album album
    end

    def jukebox(*args)
      count = args.shift || @config["jukebox-size"]

      songs = @index.jukebox(count.to_i).map { |s| Song.new(s) }

      songs.each { |s| @player.enqueue_song s }
    end

    def list_queue
      puts @player.list_queue.map(&:title)
    end

    def shuffle_queue
      @player.shuffle_queue
    end

    def clear_queue
      @player.clear_queue
    end

    def now_playing
      info @player.now_playing.full_title
    end
  end
end
