module Muzak
  module Cmd
    def _index_available?
      File.file?(INDEX_FILE)
    end

    def _index_loaded?
      !!@index
    end

    def _index_outdated?
      Time.now.to_i - @index.timestamp >= Config.index_autobuild
    end

    def _index_sync
      debug "syncing index hash with #{INDEX_FILE}"
      File.open(INDEX_FILE, "w") { |io| io.write @index.hash.to_yaml }
    end

    def index_load
      verbose "loading index from #{INDEX_FILE}"

      @index = Index.load_index(INDEX_FILE)

      # the order is important here, since Config.index_autobuild
      # will short-circuit if index-autobuild isn't set
      if Config.index_autobuild && _index_outdated?
        verbose "rebuilding outdated index"
        index_build
      end
    end

    def index_build(*args)
      warn_arity(args, 0)

      verbose "building a new index, this may take a while"

      @index = Index.new(Config.music, deep: Config.deep_index)
      _index_sync
    end

    def list_artists(*args)
      return unless _index_loaded?

      warn_arity(args, 0)

      puts @index.artists.join("\n")
    end

    def list_albums(*args)
      return unless _index_loaded?

      warn_arity(args, 0)

      puts @index.album_names.join("\n")
    end

    def albums_by_artist(*args)
      return unless _index_loaded?

      artist = args.join(" ")
      return if artist.nil?

      puts @index.albums_by(artist).map(&:title)
    end

    def songs_by_artist(*args)
      return unless _index_loaded?

      artist = args.join(" ")
      return if artist.nil?

      puts @index.songs_by(artist).map(&:title)
    end
  end
end
