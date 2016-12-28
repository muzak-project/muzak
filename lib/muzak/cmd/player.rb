module Muzak
  module Cmd
    # Activate the configured player.
    # @command `player-activate`
    # @cmdexample `muzak> player-activate`
    # @note Many playback commands will automatically activate the player.
    def player_activate
      if player.running?
        warn "player is already running"
        return
      end

      player.activate!
    end

    # Deactivate the configured player.
    # @command `player-deactivate`
    # @cmdexample `muzak> player-deactivate`
    # @note Deactivating the player (usually) ends playback immediately.
    def player_deactivate
      warn "player is not running" unless player.running?

      # do cleanup even if the player isn't running, just in case
      player.deactivate!
    end

    # Tell the player to begin playback.
    # @command `play`
    # @cmdexample `muzak> play`
    def play
      player.play
    end

    # Tell the player to pause.
    # @command `pause`
    # @cmdexample `muzak> pause`
    def pause
      player.pause
    end

    # Tell the player to toggle its playback state.
    # @command `toggle`
    # @cmdexample `muzak> toggle`
    def toggle
      if player.playing?
        player.pause
      else
        player.play
      end
    end

    # Tell the player to load the next song.
    # @command `next`
    # @cmdexample `muzak> next`
    def next
      player.next_song
    end

    # Tell the player to load the previous song.
    # @command `previous`
    # @cmdexample `muzak> previous`
    def previous
      player.previous_song
    end

    # Tell the player to enqueue all songs by the given artist.
    # @command `enqueue-artist <artist name>`
    # @cmdexample `muzak> enqueue-artist Your Favorite Artist`
    def enqueue_artist(*args)
      artist = args.join(" ")
      return if artist.nil?

      albums = index.albums_by(artist)
      return if albums.empty?

      albums.each do |album|
        player.enqueue_album album
      end
    end

    # Tell the player to enqueue the given album.
    # @command `enqueue-album <album name>`
    # @cmdexample `muzak> enqueue-album Your Favorite Album`
    def enqueue_album(*args)
      album_name = args.join(" ")
      return if album_name.nil?

      album = index.albums[album_name]
      return if album.nil?

      player.enqueue_album album
    end

    # Tell the player to load the given number of random songs.
    # @command `jukebox [count]`
    # @cmdexample `muzak> jukebox 150`
    def jukebox(*args)
      count = args.shift || Config.jukebox_size

      songs = index.jukebox(count.to_i)

      Thread.new do
        songs.each { |s| player.enqueue_song s }
      end
    end

    # Tell the player to list its internal queue.
    # @command `list-queue`
    # @cmdexample `muzak> list-queue`
    def list_queue
      puts player.list_queue.map(&:title)
    end

    # Tell the player to shuffle its internal queue.
    # @command `shuffle-queue`
    # @cmdexample `muzak> shuffle-queue`
    def shuffle_queue
      player.shuffle_queue
    end

    # Tell the player to clear its internal queue.
    # @command `clear-queue`
    # @cmdexample `muzak> clear-queue`
    # @note This does not (usually) stop the current song.
    def clear_queue
      player.clear_queue
    end

    # Retrieve the currently playing song from the player and print it.
    # @command `now-playing`
    # @cmdexample `muzak> now-playing`
    def now_playing
      return unless player.playing?

      info player.now_playing.full_title
    end
  end
end
