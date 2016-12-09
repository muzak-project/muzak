module Muzak
  module Cmd
    def _playlist_file(pname)
      File.join(PLAYLIST_DIR, pname) + ".yml"
    end

    def _playlist_available?(pname)
      File.exist?(_playlist_file(pname))
    end

    def _playlist_loaded?
      !!@playlist
    end

    def list_playlists
      Playlist.playlist_names.each do |playlist|
        info playlist
      end
    end

    def playlist_load(*args)
      fail_arity(args, 1)
      pname = args.shift

      if _playlist_available?(pname)
        info "loading playlist '#{pname}'"
        @playlist = Playlist.load_playlist(_playlist_file(pname))
      else
        info "creating playlist '#{pname}'"
        @playlist = Playlist.new(pname, [])
        playlist_sync
      end

      event :playlist_loaded, @playlist
    end

    def playlist_delete(*args)
      fail_arity(args, 1)
      pname = args.shift

      debug "deleting playist '#{pname}'"

      File.delete(_playlist_file(pname)) if _playlist_available?(pname)
      @playlist = nil
    end

    def playlist_sync(*args)
      return unless _playlist_loaded?
      fail_arity(args, 0)

      debug "syncing playlist '#{@playlist.name}'"

      Dir.mkdir(PLAYLIST_DIR) unless Dir.exist?(PLAYLIST_DIR)
      File.open(_playlist_file(@playlist.name), "w") { |io| io.write @playlist.to_hash.to_yaml }
    end

    def enqueue_playlist
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

      album.songs.each { |song| @playlist.add song }

      playlist_sync
    end

    def playlist_add_current
      return unless @player.running? && _playlist_loaded?

      @playlist.add @player.now_playing

      playlist_sync
    end

    def playlist_del_current
      return unless @player.running? && _playlist_loaded?

      @playlist.delete(@player.now_playing)

      playlist_sync
    end

    def playlist_shuffle
      return unless _playlist_loaded?

      @playlist.shuffle!

      playlist_sync
    end
  end
end
