require "net/http"
require "digest"

module Muzak
  module Plugin
    class Scrobble < StubPlugin
      include Utils

      def initialize(instance)
        super
        @username, @password = instance.config["plugin-scrobble"].split(":")
      end

      def song_loaded(song)
        if song.title.nil? || song.artist.nil?
          debug "cowardly refusing to scrobble a song ('#{song.path}') with missing metadata"
          return
        end

        scrobble song
      end

      private

      def scrobble(song)
        if @username.nil? || @password.nil?
          error "missing username or password"
          return
        end

        handshake_endpoint = "http://post.audioscrobbler.com/"
        handshake_params = {
          "hs" => true,
          "p" => 1.1,
          "c" => "lsd",
          "v" => "1.0.4",
          "u" => @username
        }

        uri = URI(handshake_endpoint)
        uri.query = URI.encode_www_form(handshake_params)

        resp = Net::HTTP.get_response(uri)

        status, token, post_url, int = resp.body.split("\n")

        unless status =~ /UP(TO)?DATE/
          error "bad handshake, got '#{status}'"
          return
        end

        session_token = Digest::MD5.hexdigest(Digest::MD5.hexdigest(@password) + token)

        request_params = {
          "u" => @username,
          "s" => session_token,
          "a[0]" => song.artist,
          "t[0]" => song.title,
          "b[0]" => song.album,
          "m[0]" => "", # we don't know the MBID, so send an empty one
          "l[0]" => song.length,
          "i[0]" => Time.now.gmtime.strftime("%Y-%m-%d %H:%M:%S")
        }

        uri = URI(URI.encode(post_url))
        # uri.query = URI.encode_www_form(request_params)

        resp = Net::HTTP.post_form(uri, request_params)

        status, int = resp.body.split("\n")

        case status
        when "OK"
          debug "scrobble of '#{song.title}' successful"
        else
          debug "scrobble of '#{song.title}' failed, got '#{status}'"
        end
      end
    end
  end
end
