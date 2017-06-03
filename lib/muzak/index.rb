# frozen_string_literal: true

module Muzak
  # Represents muzak's music index.
  class Index
    include Utils

    # @return [Index] a {Index} instance instantiated with {Config::INDEX_FILE}
    def self.load_index!
      if File.exist?(Config::INDEX_FILE)
        Index.new
      else
        error! "#{Config::INDEX_FILE} missing, did you forget to run muzak-index?"
      end
    end

    # @return [String] the path of the index data file
    attr_accessor :file

    # @return [String] the path of the root of the music tree
    attr_accessor :tree

    # @return [Hash] the index hash
    attr_accessor :hash

    # @param file [String] the path of the index data file
    def initialize(file: Config::INDEX_FILE)
      debug "loading index from '#{file}'..."

      @file = file
      @hash = Marshal.load File.read(file) # rubocop:disable Security/MarshalLoad

      memoize_collections!
    end

    # Refresh the {Index} instance's state from the index data file.
    # @note This method does *not* rebuild the index data file.
    # @return [void]
    def reload!
      debug "reloading index from '#{file}'..."
      @hash = Marshal.load File.read(file) # rubocop:disable Security/MarshalLoad
      @albums_hash = nil
      memoize_collections!
    end

    # @return [Boolean] whether or not the current index is deep
    def deep?
      @hash["deep"]
    end

    # @return [Integer] the UNIX timestamp from when the index was built
    def timestamp
      @hash["timestamp"]
    end

    # @return [Array<String>] a list of all artists in the index
    def artists
      @hash["artists"].keys
    end

    # @return [Hash{String => Album}] a hash of all album names with their
    #   {Album} objects
    def albums
      @albums_hash ||= begin
        albums_hash = {}

        artists.each do |a|
          @hash["artists"][a]["albums"].each do |title, album_hash|
            songs = load_songs album_hash
            albums_hash[title] = Album.new(title, songs, album_hash["cover"])
          end
        end

        albums_hash
      end
    end

    # @return [Array<Song>] a list of all Song objects in the index
    # @note This method **requires** a deep index.
    def songs
      unless deep?
        danger "tried to call a deep-index-only method with a shallow index"
        return []
      end

      @all_deep_songs
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
        @hash["artists"][artist]["albums"].map do |title, album_hash|
          songs = load_songs album_hash
          Album.new(title, songs, album_hash["cover"])
        end
      else
        error "no such artist: '#{artist}'" unless @hash["artists"].key?(artist)
        []
      end
    end

    # Produces a 'jukebox' of random songs.
    # @param count [Integer] the number of random songs to return
    # @return [Array<Song>] an array of randomly chosen songs
    def jukebox(count = 50)
      if deep?
        @all_deep_songs.sample(count)
      else
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
        albums_by(artist).map(&:songs).flatten
      rescue
        []
      end
    end

    # Create some frequently accessed collections to speed things up a bit.
    # @return [void]
    # @api private
    def memoize_collections!
      @all_albums = @hash["artists"].map { |_, a| a["albums"] }.flatten

      if deep?
        @all_deep_songs = @all_albums.map do |aa|
          aa.map { |_, a| a["deep-songs"] }
        end.flatten
      else
        @all_songs = @all_albums.map { |aa| aa.map { |_, a| a["songs"] } }.flatten
      end
    end

    # Load the songs from an album hash into {Song} instances.
    # @param ah [Hash] the album hash
    # @api private
    def load_songs(ah)
      if deep?
        ah["deep-songs"]
      else
        ah["songs"].map { |s| Song.new s }
      end
    end
  end
end
