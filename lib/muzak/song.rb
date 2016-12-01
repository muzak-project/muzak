require "taglib"

module Muzak
  class Song
    attr_reader :path, :title, :artist, :album, :year, :track, :genre, :comment

    def initialize(path)
      @path = path

      TagLib::FileRef.open(path) do |ref|
        break if ref.null?
        @title = ref.tag.title || File.basename(path, File.extname(path))
        @artist = ref.tag.artist
        @album = ref.tag.album
        @year = ref.tag.year
        @track = ref.tag.track
        @genre = ref.tag.genre
        @comment = ref.tag.comment
      end
    end
  end
end
