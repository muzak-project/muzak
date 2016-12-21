module Muzak
  module Cmd
    # List all currently available playlists.
    # @command `list-playlists`
    # @cmdexample `muzak> list-playlists`
    def list_playlists(*args)
      Playlist.playlist_names.each do |playlist|
        info playlist
      end
    end

    # Delete the given playlist.
    # @command `playlist-delete <playlist>`
    # @cmdexample `muzak> playlist-delete favorites`
    def playlist_delete(*args)
      fail_arity(args, 1)
      pname = args.shift

      debug "deleting playist '#{pname}'"

      Playlist.delete!(pname)
      playlists[pname] = nil
    end

    # Add the given playlist to the player's queue.
    # @command `enqueue-playlist <playlist>`
    # @cmdexample `muzak> enqueue-playlist favorites`
    def enqueue_playlist(*args)
      fail_arity(args, 1)
      pname = args.shift

      player.enqueue_playlist(playlists[pname])
      event :playlist_enqueued, playlists[pname]
    end

    # Add the given album to the given playlist.
    # @command `playlist-add-album <playlist> <album name>`
    # @cmdexample `muzak> playlist-add-album favorites Your Favorite Album`
    def playlist_add_album(*args)
      pname = args.shift
      return if pname.nil?

      album_name = args.join(" ")
      return if album_name.nil?

      album = index.albums[album_name]
      return if album.nil?

      playlists[pname].add(album.songs)
    end

    # Add the given artist to the given playlist.
    # @command `playlist-add-artist <playlist> <artist name>`
    # @cmdexample `muzak> playlist-add-artist dad-rock The Rolling Stones`
    def playlist_add_artist(*args)
      pname = args.shift
      return if pname.nil?

      artist = args.join(" ")
      return if artist.nil?

      playlists[pname].add(index.songs_by(artist))
    end

    # Add the currently playing song to the given playlist.
    # @see Muzak::Player::StubPlayer#now_playing
    # @command `playlist-add-current <playlist>`
    # @cmdexample `muzak> playlist-add-current favorites`
    def playlist_add_current(*args)
      return unless player.running?

      pname = args.shift
      return if pname.nil?

      playlists[pname].add player.now_playing
    end

    # Deletes the currently playing song from the given playlist.
    # @see Muzak::Player::StubPlayer#now_playing
    # @command `playlist-del-current <playlist>`
    # @cmdexample `muzak> playlist-del-current favorites`
    def playlist_del_current(*args)
      return unless player.running?

      pname = args.shift
      return if pname.nil?

      playlists[pname].delete player.now_playing
    end

    # Shuffle the given playlist.
    # @see Muzak::Playlist#shuffle!
    # @command `playlist-shuffle <playlist>`
    # @cmdexample `muzak> playlist-shuffle dad-rock`
    def playlist_shuffle(*args)
      pname = args.shift
      return if pname.nil?

      playlists[pname].shuffle!
    end
  end
end
