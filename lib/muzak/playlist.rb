module Muzak
  class Playlist
    attr_accessor :filename, :songs

    def self.path_for(pname)
      File.join(PLAYLIST_DIR, pname) + ".yml"
    end

    def self.exist?(pname)
      File.exist?(path_for(pname))
    end

    def self.delete!(pname)
      File.delete(path_for(pname)) if exist? pname
    end

    def self.playlist_names
      Dir.entries(PLAYLIST_DIR).reject do |ent|
        ent.start_with?(".")
      end.map do |ent|
        File.basename(ent, File.extname(ent))
      end
    end

    def initialize(pname)
      @filename = self.class.path_for pname

      if File.exist?(@filename)
        phash = YAML.load_file(@filename)
        @songs = phash["songs"]
      else
        @songs = []
      end

      sync!
    end

    def name
      File.basename(@filename, File.extname(@filename))
    end

    def add(songs)
      # coerce a single song into an array
      [*songs].each do |song|
        next if @songs.include?(song)
        @songs << song
      end

      sync!
    end

    def delete(songs)
      [*songs].each { |song| @songs.delete(song) }

      sync!
    end

    def shuffle!
      @songs.shuffle!
    end

    def sync!
      File.open(@filename, "w") { |io| io.write to_hash.to_yaml }
    end

    def to_hash
      { "songs" => @songs }
    end
  end
end
