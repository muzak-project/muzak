module Muzak
  # Represents muzak's music index.
  class Index
    include Utils

    # @return [String] the path of the root of the music tree
    attr_accessor :tree

    # @return [Boolean] whether the index is "deep" (includes metadata) or not
    attr_accessor :deep

    # @return [Hash] the index hash
    attr_accessor :hash

    # @param tree [String] the root to begin indexing from
    # @param deep [Boolean] whether to build a "deep" index
    # @note if the index ({Muzak::INDEX_FILE}) already exists and is not
    #   outdated, no building is performed.
    # @see #build!
    def initialize(tree, deep: false)
      @tree = tree
      @deep = deep

      if File.exist?(INDEX_FILE)
        verbose "loading index from #{INDEX_FILE}"
        @hash = Marshal::load(File.read INDEX_FILE)
        return unless outdated?
      end

      build!
    end

    # (Re)builds and saves the index ({Muzak::INDEX_FILE}) to disk.
    # @note This method can be expensive.
    def build!
      @hash = build_index_hash!

      debug "indexed #{albums.length} albums by #{artists.length} artists"

      File.open(INDEX_FILE, "w") { |io| io.write Marshal::dump @hash }
    end

    # @return [Boolean] whether or not the current index is deep
    def deep?
      deep
    end

    # @return [Integer] the UNIX timestamp from when the index was built
    def timestamp
      @hash["timestamp"]
    end

    # @return [Boolean] whether or not the index is currently out of date
    # @note The behavior of this method is affected by the value of
    #   {Muzak::Config.index_autobuild}.
    def outdated?
      Time.now.to_i - timestamp >= Config.index_autobuild
    end

    # @return [Array<String>] a list of all artists in the index
    def artists
      @artists ||= @hash["artists"].keys
    end

    # @return [Hash{String => Album}] a hash of all album names with their
    #   {Album} objects
    def albums
      @albums_hash ||= begin
        albums_hash = {}

        artists.each do |a|
          @hash["artists"][a]["albums"].each do |title, album_hash|
            albums_hash[title] = Album.new(title, album_hash)
          end
        end

        albums_hash
      end
    end

    # @return [Array<String>] a list of all albums in the index
    # @note albums with the same name will appear, but can't be disambiguated
    #   from here
    def album_names
      artists.map { |a| @hash["artists"][a]["albums"].keys }.flatten
    end

    # @param artist [String] the artist's name
    # @return [Array<Album>] all albums by the given artist
    def albums_by(artist)
      if artists.include?(artist)
        @hash["artists"][artist]["albums"].map { |title, album| Album.new(title, album) }
      else
        error "no such artist: '#{artist}'" unless @hash["artists"].key?(artist)
        []
      end
    end

    # Produces a 'jukebox' of random songs.
    # @param count [Integer] the number of random songs to return
    # @return [Array<Song>] an array of randomly chosen songs
    def jukebox(count = 50)
      @all_albums ||= @hash["artists"].map { |_, a| a["albums"] }.flatten

      if deep?
        @all_deep_songs ||= @all_albums.map { |aa| aa.map { |_, a| a["deep-songs"] } }.flatten
        @all_deep_songs.sample(count)
      else
        @all_songs ||= @all_albums.map { |aa| aa.map { |_, a| a["songs"] } }.flatten
        @all_songs.sample(count).map { |s| Song.new(s) }
      end
    end

    # @param artist [String] the artist's name
    # @return [Array<Song>] an array of all the artist's songs
    # @note no inter-album order is guaranteed. songs within an album are
    #   generally sorted by track number.
    def songs_by(artist)
      error "no such artist: '#{artist}'" unless @hash["artists"].key?(artist)

      begin
        albums_by(artist).map do |album|
          album.songs
        end.flatten
      rescue Exception => e
        []
      end
    end

    private

    def build_index_hash!
      index_hash = {
        "timestamp" => Time.now.to_i,
        "artists" => {},
        "deep" => deep
      }

      Dir.entries(tree).each do |artist|
        next unless File.directory?(File.join(tree, artist))
        next if artist.start_with?(".")

        index_hash["artists"][artist] = {}
        index_hash["artists"][artist]["albums"] = {}

        Dir.entries(File.join(tree, artist)).each do |album|
          next if album.start_with?(".")

          index_hash["artists"][artist]["albums"][album] = {}
          index_hash["artists"][artist]["albums"][album]["songs"] = []
          index_hash["artists"][artist]["albums"][album]["deep-songs"] = []

          Dir.glob(File.join(tree, artist, album, "**")) do |file|
            index_hash["artists"][artist]["albums"][album]["cover"] = file if album_art?(file)

            if music?(file)
              index_hash["artists"][artist]["albums"][album]["songs"] << file
              if deep?
                index_hash["artists"][artist]["albums"][album]["deep-songs"] << Song.new(file)
              end
            end
          end

          index_hash["artists"][artist]["albums"][album]["songs"].sort!
          index_hash["artists"][artist]["albums"][album]["deep-songs"].sort_by!(&:track)
        end
      end

      index_hash
    end
  end
end
