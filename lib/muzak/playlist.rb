module Muzak
  class Playlist
    attr_accessor :name, :songs

    def self.playlist_names
      Dir.entries(PLAYLIST_DIR).reject do |ent|
        ent.start_with?(".")
      end.map do |ent|
        File.basename(ent, File.extname(ent))
      end
    end

    def self.load_playlist(path)
      instance = allocate
      playlist_hash = YAML.load_file(path)

      instance.name = File.basename(path, File.extname(path))
      instance.songs = playlist_hash["songs"]

      instance
    end

    def initialize(name, songs)
      @name = name
      @songs = songs
    end

    def add(song)
      return if @songs.include?(song)
      @songs << song
    end

    def delete(song)
      @songs.delete(song)
    end

    def shuffle!
      @songs.shuffle!
    end

    def to_hash
      { "songs" => songs }
    end
  end
end
