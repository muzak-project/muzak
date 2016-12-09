module Muzak
  class Index
    include Utils
    attr_accessor :hash

    def self.load_index(file)
      instance = allocate
      instance.hash = YAML::load_file(file)

      instance
    end

    def initialize(tree, deep: false)
      @hash = {
        "timestamp" => Time.now.to_i,
        "artists" => {},
        "deep" => deep
      }

      Dir.entries(tree).each do |artist|
        next unless File.directory?(File.join(tree, artist))
        next if artist.start_with?(".")

        @hash["artists"][artist] = {}
        @hash["artists"][artist]["albums"] = {}

        Dir.entries(File.join(tree, artist)).each do |album|
          next if album.start_with?(".")

          @hash["artists"][artist]["albums"][album] = {}
          @hash["artists"][artist]["albums"][album]["songs"] = []
          @hash["artists"][artist]["albums"][album]["deep-songs"] = []

          Dir.glob(File.join(tree, artist, album, "**")) do |file|
            @hash["artists"][artist]["albums"][album]["cover"] = file if album_art?(file)

            if music?(file)
              @hash["artists"][artist]["albums"][album]["songs"] << file
              @hash["artists"][artist]["albums"][album]["deep-songs"] << Song.new(file)
            end
          end

          @hash["artists"][artist]["albums"][album]["songs"].sort!
          @hash["artists"][artist]["albums"][album]["deep-songs"].sort_by!(&:track)
        end
      end
    end

    def deep?
      !!@hash["deep"]
    end

    def artists
      @hash["artists"].keys
    end

    def albums
      albums_hash = {}

      artists.each do |a|
        @hash["artists"][a]["albums"].each do |title, album_hash|
          albums_hash[title] = Album.new(title, album_hash)
        end
      end

      albums_hash
    end

    def album_names
      artists.map { |a| @hash["artists"][a]["albums"].keys }.flatten
    end

    def albums_by(artist)
      error "no such artist: '#{artist}'" unless @hash["artists"].key?(artist)

      @hash["artists"][artist]["albums"].map { |title, album| Album.new(title, album) }
    end

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
  end
end
