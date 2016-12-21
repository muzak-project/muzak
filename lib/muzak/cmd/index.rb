module Muzak
  module Cmd
    # Rebuild the current instance's index.
    # @command `index-build`
    # @cmdexample `muzak> index-build`
    def index_build(*args)
      warn_arity(args, 0)

      verbose "building a new index, this may take a while"

      index.build!
    end

    # List all artists in the index.
    # @command `list-artists`
    # @cmdexample `muzak> list-artists`
    def list_artists(*args)
      warn_arity(args, 0)

      puts index.artists.join("\n")
    end

    # List all albums in the index.
    # @command `list-albums`
    # @cmdexample `muzak> list-albums`
    def list_albums(*args)
      warn_arity(args, 0)

      puts index.album_names.join("\n")
    end

    # List all albums by the given artist in the index.
    # @command `albums-by-artist <artist name>`
    # @cmdexample `muzak> albums-by-artist Your Favorite Artist`
    def albums_by_artist(*args)
      artist = args.join(" ")
      return if artist.nil?

      puts index.albums_by(artist).map(&:title)
    end

    # List all songs by the given artist in the index.
    # @command `songs-by-artist <artist name>`
    # @cmdexample `muzak> songs-by-artist Your Next Favorite Artist`
    def songs_by_artist(*args)
      artist = args.join(" ")
      return if artist.nil?

      puts index.songs_by(artist).map(&:title)
    end
  end
end
