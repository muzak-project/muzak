module Muzak
  module Cmd
    # Rebuild the current instance's index.
    # @command `index-build`
    # @cmdexample `muzak> index-build`
    def index_build(*args)
      verbose "building a new index, this may take a while"

      index.build!

      build_response data: {
        artists: index.artists.size,
        albums: index.albums.size
      }
    end

    # List all artists in the index.
    # @command `list-artists`
    # @cmdexample `muzak> list-artists`
    def list_artists
      build_response data: {
        artists: index.artists
      }
    end

    # List all albums in the index.
    # @command `list-albums`
    # @cmdexample `muzak> list-albums`
    def list_albums
      build_response data: {
        albums: index.album_names
      }
    end

    # List all albums by the given artist in the index.
    # @command `albums-by-artist <artist name>`
    # @cmdexample `muzak> albums-by-artist Your Favorite Artist`
    def albums_by_artist(*args)
      artist = args.join(" ")

      albums = index.albums_by(artist).map(&:title)

      build_response data: {
        albums: albums
      }
    end

    # List all songs by the given artist in the index.
    # @command `songs-by-artist <artist name>`
    # @cmdexample `muzak> songs-by-artist Your Next Favorite Artist`
    def songs_by_artist(*args)
      artist = args.join(" ")

      songs = index.songs_by(artist).map(&:title)

      build_response data: {
        songs: songs
      }
    end
  end
end
