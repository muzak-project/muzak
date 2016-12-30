module Muzak
  module Cmd
    # List all currently available playlists.
    # @command `list-playlists`
    # @cmdexample `muzak> list-playlists`
    def list_playlists
      build_response data: {
        playlists: Playlist.playlist_names
      }
    end

    # Delete the given playlist.
    # @command `playlist-delete <playlist>`
    # @cmdexample `muzak> playlist-delete favorites`
    def playlist_delete(pname)
      debug "deleting playist '#{pname}'"

      Playlist.delete!(pname)
      playlists[pname] = nil

      build_response
    end

    # Add the given playlist to the player's queue.
    # @command `enqueue-playlist <playlist>`
    # @cmdexample `muzak> enqueue-playlist favorites`
    def enqueue_playlist(pname)
      player.enqueue_playlist(playlists[pname])
      event :playlist_enqueued, playlists[pname]

      build_response
    end

    # Add the given album to the given playlist.
    # @command `playlist-add-album <playlist> <album name>`
    # @cmdexample `muzak> playlist-add-album favorites Your Favorite Album`
    def playlist_add_album(pname, *args)
      album_name = args.join(" ")
      album = index.albums[album_name]

      if album
        playlists[pname].add(album.songs)
        build_response
      else
        build_response error: "no such album: '#{album_name}'"
      end
    end

    # Add the given artist to the given playlist.
    # @command `playlist-add-artist <playlist> <artist name>`
    # @cmdexample `muzak> playlist-add-artist dad-rock The Rolling Stones`
    def playlist_add_artist(pname, *args)
      artist = args.join(" ")
      songs = index.songs_by(artist)

      unless songs.empty?
        playlists[pname].add(songs)
        build_response
      else
        build_response error: "no songs by artist: '#{artist}'"
      end
    end

    # Add the currently playing song to the given playlist.
    # @see Muzak::Player::StubPlayer#now_playing
    # @command `playlist-add-current <playlist>`
    # @cmdexample `muzak> playlist-add-current favorites`
    def playlist_add_current(pname)
      if player.running?
        playlists[pname].add player.now_playing
        build_response
      else
        build_response error: "the player is not running"
      end
    end

    # Deletes the currently playing song from the given playlist.
    # @see Muzak::Player::StubPlayer#now_playing
    # @command `playlist-del-current <playlist>`
    # @cmdexample `muzak> playlist-del-current favorites`
    def playlist_del_current(pname)
      if player.running?
        playlists[pname].delete player.now_playing
        build_response
      else
        build_response error: "the player is not running"
      end
    end

    # Shuffle the given playlist.
    # @see Muzak::Playlist#shuffle!
    # @command `playlist-shuffle <playlist>`
    # @cmdexample `muzak> playlist-shuffle dad-rock`
    def playlist_shuffle(pname)
      playlists[pname].shuffle!
      build_response
    end
  end
end
