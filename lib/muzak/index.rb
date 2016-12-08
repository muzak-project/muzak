module Muzak
  class Index
    include Utils
    attr_accessor :hash

    def self.load_index(file)
      instance = allocate
      instance.hash = YAML::load_file(file)

      instance
    end

    def initialize(tree)
      @hash = {
        "timestamp" => Time.now.to_i,
        "artists" => {}
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

          Dir.glob(File.join(tree, artist, album, "**")) do |file|
            @hash["artists"][artist]["albums"][album]["cover"] = file if album_art?(file)
            @hash["artists"][artist]["albums"][album]["songs"] << file if music?(file)
          end

          @hash["artists"][artist]["albums"][album]["songs"].sort!
        end
      end
    end

    def artists
      @hash["artists"].keys
    end

    def albums
      albums_hash = {}

      artists.each do |a|
        @hash["artists"][a]["albums"].keys.each do |ak|
          albums_hash[ak] = @hash["artists"][a]["albums"][ak]
        end
      end

      albums_hash
    end

    def album_names
      artists.map { |a| @hash["artists"][a]["albums"].keys }.flatten
    end

    def albums_by(artist)
      error "no such artist: '#{artist}'" unless @hash["artists"].key?(artist)

      begin
        @hash["artists"][artist]["albums"]
      rescue Exception => e
        {}
      end
    end

    def jukebox(count = 50)
      @all_albums ||= @hash["artists"].map { |_, a| a["albums"] }.flatten
      @all_songs ||= @all_albums.map { |aa| aa.map { |_, a| a["songs"] } }.flatten
      @all_songs.sample(count)
    end

    def songs_by(artist)
      error "no such artist: '#{artist}'" unless @hash["artists"].key?(artist)

      begin
        albums_by(artist).map do |_, album|
          album["songs"].map { |s| File.basename(s) }.sort
        end.flatten
      rescue Exception => e
        []
      end
    end
  end
end
