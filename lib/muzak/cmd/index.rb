module Muzak
  module Cmd
    INDEX_FILE = File.join(CONFIG_DIR, "index.yml")

    def _index_available?
      File.file?(INDEX_FILE)
    end

    def _index_loaded?
      !!@index
    end

    def _index_sync
      debug "syncing index hash with #{INDEX_FILE}"
      File.open(INDEX_FILE, "w") { |io| io.write @index.hash.to_yaml }
    end

    def index_load
      debug "loading index from #{INDEX_FILE}"

      @index = Index.load_index(INDEX_FILE)
    end

    def index_build(*args)
      warn_arity(args, 0)

      @index = Index.new(@config["music"])
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

      puts @index.albums_by(artist).keys
    end

    def songs_by_artist(*args)
      return unless _index_loaded?

      artist = args.join(" ")
      return if artist.nil?

      puts @index.songs_by(artist)
    end
  end
end
