module Muzak
  class Album
    attr_reader :title, :songs, :cover_art

    def initialize(title, album_hash)
      @title = title
      @songs = album_hash["songs"].map { |s| Song.new(s) }
      @cover_art = album_hash["cover"]
    end
  end
end
