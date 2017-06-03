# frozen_string_literal: true

require "taglib"
require "json"

module Muzak
  # Represents a single song for muzak.
  class Song
    include Utils

    # @return [String] the fully-qualified path to the song
    attr_reader :path

    # @return [String] the title of the song, identified from metadata
    # @note if metadata is missing, the basename of the path is used instead
    attr_reader :title

    # @return [String, nil] the artist of the song, identified from metadata
    attr_reader :artist

    # @return [String, nil] the album of the song, identified from metadata
    attr_reader :album

    # @return [Integer, 0] the year of the song, identified from metadata
    attr_reader :year

    # @return [Integer, 0] the track number of the song, identified from metadata
    attr_reader :track

    # @return [String, nil] the genre of the song, identified from metadata
    attr_reader :genre

    # @return [String, nil] any comments in the song's metadata
    attr_reader :comment

    # @return [Integer] the length of the song, in seconds
    attr_reader :length

    # @param path [String] the path of the song to load
    def initialize(path)
      @path = path

      TagLib::FileRef.open(path) do |ref|
        @title   = ref&.tag&.title
        @artist  = ref&.tag&.artist
        @album   = ref&.tag&.album
        @year    = ref&.tag&.year
        @track   = ref&.tag&.track
        @genre   = ref&.tag&.genre
        @comment = ref&.tag&.comment
        @length  = ref&.audio_properties&.length
      end

      # provide some sane fallbacks
      @title ||= File.basename(path, File.extname(path)) rescue ""
      @track ||= 0 # we'll need to sort by track number
    end

    # @return [String] A best guess path for the song's cover art
    # @example
    #   song.best_guess_album_art # => "/path/to/song/directory/cover.jpg"
    def best_guess_album_art
      album_dir = File.dirname(path)

      art = Dir.entries(album_dir).find { |ent| Utils.album_art?(ent) }
      File.join(album_dir, art) unless art.nil?
    end

    # @return [String] the "full" title of the song, including artist and album
    #   if available.
    # @example
    #   song.full_title # => "Song by Artist on Album"
    def full_title
      full = title.dup
      full << " by #{artist}" if artist
      full << " on #{album}" if album

      full
    end

    # @return [Boolean] whether or not the given object is equal to this one
    # @note compares song paths, not metadata
    def ==(other)
      other.is_a?(Song) && path == other.path
    end

    # @return [Hash] a hash representation of the song, including pathname
    def to_h
      {
        path: path,
        title: title,
        artist: artist,
        album: album,
        year: year,
        track: track,
        genre: genre,
        comment: comment,
        length: length,
      }
    end

    # @param options [Array] options passed to the internal `to_json` call
    # @return [String] a JSON-serialized representation of the song
    # @note uses {to_h} to build the representation
    def to_json(*options)
      to_h.to_json(*options)
    end
  end
end
