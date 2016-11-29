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
      puts tree
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
        []
      end
    end

    def songs_by(artist)
      error "no such artist: '#{artist}'" unless @hash["artists"].key?(artist)

      begin
        albums_by(artist).keys.map { |a| albums_by(artist)[a]["songs"].sort }.flatten
      rescue Exception => e
        []
      end
    end

    private

    def music?(filename)
      [".mp3", ".flac", ".m4a", ".wav", ".ogg", ".oga", ".opus"].include?(File.extname(filename))
    end

    def album_art?(filename)
      File.basename(filename) =~ /(cover)|(folder).(jpg)|(png)/i
    end
  end
end
