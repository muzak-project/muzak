module Muzak
  module Cmd
    def index_build(*args)
      warn_arity(args, 0)

      verbose "building a new index, this may take a while"

      index.build!
    end

    def list_artists(*args)
      warn_arity(args, 0)

      puts @index.artists.join("\n")
    end

    def list_albums(*args)
      warn_arity(args, 0)

      puts @index.album_names.join("\n")
    end

    def albums_by_artist(*args)
      artist = args.join(" ")
      return if artist.nil?

      puts @index.albums_by(artist).map(&:title)
    end

    def songs_by_artist(*args)
      artist = args.join(" ")
      return if artist.nil?

      puts @index.songs_by(artist).map(&:title)
    end
  end
end
