require "taglib"

module Muzak
  class Song
    include Utils

    attr_reader :path, :title, :artist, :album, :year, :track, :genre, :comment, :length

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
        @length = ref.audio_properties.length
      end
    end

    def best_guess_album_art
      album_dir = File.dirname(path)

      Dir.entries(album_dir).find { |ent| album_art?(ent) }
    end

    def full_title
      full = title.dup
      full << " by #{artist}" if artist
      full << " on #{album}" if album

      full
    end

    def ==(other)
      path == other.path
    end
  end
end
