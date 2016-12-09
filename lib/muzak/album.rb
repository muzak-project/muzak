module Muzak
  class Album
    attr_reader :title, :songs, :cover_art

    # instead of passing an album hash directly from the index,
    # this should really just take a title and an array of Song
    # objects.
    def initialize(title, album_hash)
      @title = title
      @cover_art = album_hash["cover"]

      if album_hash["deep-songs"]
        @songs = album_hash["deep-songs"]
      else
        @songs = album_hash["songs"].map { |s| Song.new(s) }
      end
    end
  end
end
