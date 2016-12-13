module Muzak
  module Cmd
    def _playlist_loaded?
      !!@playlist
    end

    def list_playlists(*args)
      Playlist.playlist_names.each do |playlist|
        info playlist
      end
    end

    def playlist_load(*args)
      fail_arity(args, 1)
      pname = args.shift

      info "loading playlist '#{pname}'"
      @playlist = Playlist.new(pname)

      event :playlist_loaded, @playlist
    end

    def playlist_delete(*args)
      fail_arity(args, 1)
      pname = args.shift

      debug "deleting playist '#{pname}'"

      Playlist.delete!(pname)
      @playlist = nil
    end

    def enqueue_playlist(*args)
      return unless _playlist_loaded?

      @player.enqueue_playlist(@playlist)
      event :playlist_enqueued, @playlist
    end

    def playlist_add_album(*args)
      return unless _playlist_loaded?

      album_name = args.join(" ")
      return if album_name.nil?

      album = @index.albums[album_name]
      return if album.nil?

      @playlist.add(album.songs)
    end

    def playlist_add_current(*args)
      return unless @player.running? && _playlist_loaded?

      @playlist.add @player.now_playing
    end

    def playlist_del_current(*args)
      return unless @player.running? && _playlist_loaded?

      @playlist.delete @player.now_playing
    end

    def playlist_shuffle(*args)
      return unless _playlist_loaded?

      @playlist.shuffle!
    end
  end
end
