module Muzak
  # Represents a sequential list of songs for muzak.
  class Playlist
    # @return [String] the absolute path to the playlist on disk
    attr_accessor :filename

    # @return [Array<Song>] the playlist's songs
    attr_accessor :songs

    # @param pname [String] the playlist's name
    # @return [String] the absolute path to the given playlist name
    def self.path_for(pname)
      File.join(Config::PLAYLIST_DIR, pname) + ".yml"
    end

    # @param pname [String] the playlist's name
    # @return [Boolean] whether or not the given playlist name already exists
    def self.exist?(pname)
      File.exist?(path_for(pname))
    end

    # Deletes the given playlist from disk.
    # @param pname [String] the playlist's name
    # @return [void]
    # @note If already instantiated, the playlist may still be present in
    #   memory (and may reappear on disk if modified in memory)
    def self.delete!(pname)
      File.delete(path_for(pname)) if exist? pname
    end

    # @return [Array<String>] the names of all currently available playlists
    def self.playlist_names
      Dir.entries(Config::PLAYLIST_DIR).reject do |ent|
        ent.start_with?(".")
      end.map do |ent|
        File.basename(ent, File.extname(ent))
      end
    end

    # Instantiates all playlists by loading them from disk.
    # @return [Hash{String => Playlist}] an association of playlist names to
    #   {Playlist} instances
    def self.load_playlists!
      playlists = {}
      playlists.default_proc = proc { |h, k| h[k] = Playlist.new(k) }

      playlist_names.each do |pname|
        playlists[pname] = Playlist.new(pname)
      end

      playlists
    end

    # Create a new {Playlist} with the given name, or load one by that
    #   name if it already exists.
    # @param pname [String] the playlist's name
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

    # @return [String] the playlist's name
    def name
      File.basename(@filename, File.extname(@filename))
    end

    # @param songs [Song, Array<Song>] one or more songs to add to the playlist
    # @return [void]
    def add(songs)
      # coerce a single song into an array
      [*songs].each do |song|
        next if @songs.include?(song)
        @songs << song
      end

      sync!
    end

    # @param songs [Song, Array<Song>] one or more songs to delete from the
    #   playlist
    # @return [void]
    def delete(songs)
      [*songs].each { |song| @songs.delete(song) }

      sync!
    end

    # Shuffles the internal order of the playlist's songs.
    # @return [void]
    def shuffle!
      @songs.shuffle!
    end

    # Synchronizes the current instance with its disk representation.
    # @return [void]
    # @note You shouldn't need to call this.
    def sync!
      File.open(@filename, "w") { |io| io.write to_hash.to_yaml }
    end

    # Provides a hash representation of the current instance.
    # @return [Hash{String => Array<Song>}] the instance's state
    def to_hash
      { "songs" => @songs }
    end
  end
end
