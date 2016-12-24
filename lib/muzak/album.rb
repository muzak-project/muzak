module Muzak
  # Represents a collection of songs for muzak.
  class Album
    # @return [String] the album's title
    attr_reader :title

    # @return [Array<Muzak::Song>] the album's songs
    attr_reader :songs

    # @return [String] the path to the album's cover art
    attr_reader :cover_art

    # @note instead of passing an album hash directly from the index, this
    #   should really just take a title and an array of Song objects.
    def initialize(title, album_hash)
      @title = title
      @cover_art = album_hash["cover"]

      unless album_hash["deep-songs"].empty?
        @songs = album_hash["deep-songs"]
      else
        @songs = album_hash["songs"].map { |s| Song.new(s) }
      end
    end
  end
end
