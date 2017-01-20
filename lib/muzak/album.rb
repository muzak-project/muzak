module Muzak
  # Represents a collection of songs for muzak.
  class Album
    # @return [String] the album's title
    attr_reader :title

    # @return [Array<Muzak::Song>] the album's songs
    attr_reader :songs

    # @return [String] the path to the album's cover art
    attr_reader :cover_art

    # @param title [String] the album's title
    # @param songs [Array<Song>] the album's songs
    # @param cover_art [String] the album's cover art
    def initialize(title, songs, cover_art = nil)
      @title = title
      @songs = songs
      @cover_art = cover_art
    end
  end
end
