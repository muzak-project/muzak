Muzak commands
==============

This is the user-facing documentation for muzak's commands.

For the developer documentation, see {Muzak::Cmd the Muzak::Cmd module}.

## General behavior

In general, muzak commands take 0 or more *arguments* and return a single
JSON *response* (sent to `stdout` when run through `muzak-cmd`).

Arguments are denoted with `<angle brackets>` when mandatory
and with `[square brackets]` when optional.

This response will *always* look something like this:

```json
{
   "response" : {
      "data" : "some response string (or hash)",
      "error" : null,
      "method" : "the corresponding muzak method"
   }
}
```

**Important:** Programs that interact with `muzak` through commands should
**always** check the `error` field. If `error` is non-`null`, then the rest of
the response should be discarded (or at least not treated as a success).

The `data` field may be either null, a string, array, or a sub-hash, depending
on the command issued. The documentation below will clarify whichever is the
case for each command.

The `method` field corresponds to the {Muzak::Cmd} method that was invoked.
In general this will be the "resolved" equivalent
(e.g. {Muzak::Cmd#albums_by_artist} for `albums-by-artist`). If muzak
doesn't recognize a command or can't match the given arguments to the
ones that the command expects, this field will be `command` instead
(as the processing is terminated in {Muzak::Instance#command}).

## Writing commands

Since muzak commands are just ruby methods under {Muzak::Cmd}, users
can write their own commands. These are loaded during muzak's initialization
from `~/.config/muzak/commands/*.rb`.

Commands are essentially first-class members of muzak, and as such can access
just about everything available to a {Muzak::Instance}:

* The current {Muzak::Index}.
* The user's {Muzak::Player::StubPlayer player}.
* All loaded {Muzak::Plugin::StubPlugin plugins}.
* All loaded {Muzak::Playlist}s.

This makes commands flexible, but also very dangerous - it's easy
to monkeypatch over an existing command and subtly break muzak's behavior.

Here's an example command:

```ruby
module Muzak
  module Cmd
    def dump_state
      debug "dumping muzak's state"

      build_response data: {
        index: index.to_s
        player: player.to_s
        plugins: plugins.to_s
        playlists: playlists.to_s
      }
    end
  end
end
```

In the above example, `dump_state` will be exposed as `dump-state` via
{Muzak::Cmd.commands}, which is used by clients to enumerate and display
available commands.

It can also be invoked either directly (`Muzak::Instance#dump_state`) or
through {Muzak::Instance#command} (`instance.command "dump-state"`).

## `albums-by-artist`

Provides a list of albums by the given artist.

### Syntax

`albums-by-artist <artist name>`

### Example

```bash
$ muzak-cmd albums-by-artist Blink-182
```

### Example Response

```json
{
   "response" : {
      "error" : null,
      "method" : "albums_by_artist",
      "data" : {
         "albums" : [
            "Buddha",
            "Cheshire Cat",
            "Cheshire Cat (Japanese Edition)",
            "Greatest Hits (UK Bonus)",
            "Take Off Your Pants And Jacket",
            "Neighborhoods (Deluxe Edition)",
            "The Mark, Tom And Travis Show",
            "Enema Of The State",
            "Blink-182",
            "Greatest Hits (Japanese Retail + Bonus Tracks)",
            "Blink-182 (Australian Exclusive Tour Edition)",
            "Dude Ranch"
         ]
      }
   }
}

```

## `clear-queue`

Clears the current playback queue.

### Syntax

`clear-queue`

### Example

```bash
$ muzak-cmd clear-queue
```

### Example Response

```json
{
   "response" : {
     "error" : null,
     "method" : "clear_queue",
     "data" : "null"
   }
}
```

## `config-get`

Gets the value corresponding to the given config key.

### Syntax

`config-get <key>`

### Example

```bash
$ muzak-cmd config-get jukebox-size
```

### Example Response

```json
{
   "response" : {
      "error" : null,
      "method" : "config_get",
      "data" : {
         "jukebox-size" : 100
      }
   }
}
```

## `dump-index`

Dumps the current state of muzak's index into a response.

### Syntax

`dump-index`

### Example

```bash
$ muzak-cmd dump-index
```

### Example Response

```json
{
   "response" : {
      "error" : null,
      "method" : "dump_index",
      "data" : {
         "index": { /* ... */ }
      }
   }
}
```

## `enqueue-album`

Adds the given album to the player's queue.

### Syntax

`enqueue-album <album name>`

### Example

```bash
$ muzak-cmd enqueue-album Energy
```

### Example Response

```json
{
   "response" : {
     "error" : null,
     "method" : "enqueue_album",
     "data" : "null"
   }
}
```

## `enqueue-artist`

Adds the given artist (i.e., all of their songs) to the player's queue.

### Syntax

`muzak-cmd enqueue-artist <artist name>`

### Example

```bash
$ muzak-cmd enqueue-artist Operation Ivy
```

### Example Response

```json
{
   "response" : {
     "error" : null,
     "method" : "enqueue_artist",
     "data" : "null"
   }
}
```

## `enqueue-playlist`

Adds the given playlist to the player's queue.

**Note:** This triggers the `playlist_enqueued` event.

### Syntax

`muzak-cmd enqueue-playlist <playlist name>`

### Example

```bash
$ muzak-cmd enqueue-playlist worst-of-2016
```

### Example Response

```json
{
   "response" : {
     "error" : null,
     "method" : "enqueue_playlist",
     "data" : "null"
   }
}
```

## `help`

Returns a list of available commands.

### Syntax

`help`

### Example

```bash
$ muzak-cmd help
```

### Example Response

```json
{
   "response" : {
      "data" : {
         "commands" : [
            "next",
            "jukebox",
            "player-activate",
            "player-deactivate",
            "play",
            "pause",
            "toggle",
            "previous",
            "enqueue-artist",
            "enqueue-album",
            "list-queue",
            "shuffle-queue",
            "clear-queue",
            "now-playing",
            "index-build",
            "list-artists",
            "list-albums",
            "albums-by-artist",
            "songs-by-artist",
            "config-get",
            "list-playlists",
            "playlist-delete",
            "enqueue-playlist",
            "playlist-add-album",
            "playlist-add-artist",
            "playlist-add-current",
            "playlist-del-current",
            "playlist-shuffle",
            "ping",
            "help",
            "list-plugins",
            "quit",
            "more-by-artist",
            "more-from-album",
            "favorite",
            "unfavorite"
         ]
      },
      "error" : null,
      "method" : "help"
   }
}
```

## `jukebox`

Adds *N* random songs to the player's queue, where *N* is either the optional
argument or `jukebox-size` in the configuration.

### Syntax

`jukebox [size]`

### Example

```bash
$ muzak-cmd jukebox 20
```

### Example Response

```json
{
   "response" : {
      "data" : {
         "jukebox" : [
            "Outro by Madvillain on Koushik Remixes",
            "intro by jizue on journal",
            "Familiar Patterns by PUP on The Dream Is Over",
            "I Want Cancer For Christmas by Johnny Hobo And The Freight Trains on Love Songs For The Apocalypse",
            "At The Movies by Bad Brains on Soul Brains - A Bad Brains Reunion Live From Maritime Hall",
            "Abnormality by The Arrogant Sons Of Bitches on Built To Fail (Remastered)",
            "Going to Pasalaqua (Live) by Green Day on Longview",
            "Carnival Of Souls (feat. Demoz by Jedi Mind Tricks on Violence Begets Violence",
            "Cowboy Coffee by The Mighty Mighty Bosstones on More Noise And Other Disturbances",
            "Let Us Get Murdered by Andrew Jackson Jihad on Andrew Jackson Jihad/Ghost Mice Split"
         ]
      },
      "error" : null,
      "method" : "jukebox"
   }
}
```

## `list-albums`

Returns all albums in the index.

### Syntax

`list-albums`

### Example

```bash
$ muzak-cmd list-albums
```

### Example Response

```json
{
   "response" : {
      "error" : null,
      "method" : "list_albums",
      "data" : {
         "artists" : [
            "Album 1",
            "Album 2",
            "Album 3"
         ]
      }
   }
}
```

## `list-artists`

Returns all artists in the index.

### Syntax

`list-artists`

### Example

```bash
$ muzak-cmd list-artists
```

### Example Response

```json
{
   "response" : {
      "error" : null,
      "method" : "list_artists",
      "data" : {
         "artists" : [
            "Artist 1",
            "Artist 2",
            "Artist 3"
         ]
      }
   }
}
```

## `list-playlists`

Returns all available playlists.

### Syntax

`list-playlists`

### Example

```bash
$ muzak-cmd list-playlists
```

### Example Response

```json
{
   "response" : {
      "method" : "list_playlists",
      "error" : null,
      "data" : {
         "playlists" : [
            "favorites",
            "dad-rock",
            "best-of-2016"
         ]
      }
   }
}
```

## `list-plugins`

Returns all available plugins.

**Note:** This list will differ from the list of loaded plugins unless all
available plugins have been configured.

### Syntax

`list-plugins`

### Example

```bash
$ muzak-cmd list-plugins
```

### Example Response

```json
{
   "response" : {
      "data" : {
         "plugins" : [
            "stubplugin",
            "notify",
            "scrobble"
         ]
      },
      "error" : null,
      "method" : "list_plugins"
   }
}
```

## `list-queue`

Returns the player's playback queue.

**Note:** This may include already-played songs.

### Syntax

`list-queue`

### Example

```bash
$ muzak-cmd list-queue
```

### Example Response

```json
{
   "response" : {
      "error" : null,
      "method" : "list_queue",
      "data" : {
         "queue" : [
            "Song 1",
            "Song 2",
            "Song 3"
         ]
      }
   }
}
```

## `next`

Starts the next song in the player's queue.

### Syntax

`next`

### Example

```bash
$ muzak-cmd next
```

### Example Response

```json
{
   "response" : {
     "error" : null,
     "method" : "next",
     "data" : "null"
   }
}
```

## `now-playing`

Returns the currently playing song.

### Syntax

`now-playing`

### Example

```bash
$ muzak-cmd now-playing
```

### Example Response

```json
{
   "response" : {
      "error" : null,
      "data" : {
         "playing" : "22 Offs by Chance The Rapper on 10 Day"
      },
      "method" : "now_playing"
   }
}
```

## `pause`

Pauses the player.

### Syntax

`pause`

### Example

```bash
$ muzak-cmd pause
```

### Example Response

```json
{
   "response" : {
      "data" : null,
      "method" : "pause",
      "error" : null
   }
}
```

## `ping`

Pings muzak to confirm that the instance is running as expected.

**Note**: This is mostly useful for debugging purposes.

### Syntax

`ping`

### Example

```bash
$ muzak-cmd ping
```

### Example Response

```json
{
   "response" : {
      "method" : "ping",
      "error" : null,
      "data" : {
         "pong" : 1483395120
      }
   }
}
```

## `play`

Tells the play to play.

### Syntax

`play`

### Example

```bash
$ muzak-cmd play
```

### Example Response

```json
{
   "response" : {
      "error" : null,
      "data" : null,
      "method" : "play"
   }
}
```

## `player-activate`

Activates the player.

**Note:** This will usually be done automatically when the user issues a command
that affects the playback state for the first time. Calling it manually may
be useful for debugging purposes.

### Syntax

### Example

```bash
$ muzak-cmd player-activate
```

### Example Response

```json
{
   "response" : {
      "error" : null,
      "data" : {
        "player": "Muzak::Player::MPV"
      },
      "method" : "player_activate"
   }
}
```

## `player-deactivate`

Deactivates the player.

**Note:** This will usually be done automatically when muzak is quitting.
Calling it manually may be useful for debugging purposes.

### Syntax

### Example

```bash
$ muzak-cmd
```

### Example Response

```json
{
   "response" : {
      "error" : null,
      "data" : {
        "player": "Muzak::Player::MPV"
      },
      "method" : "player_deactivate"
   }
}
```

## `playlist-add-album`

Adds the given album to the given playlist.

### Syntax

`playlist-add-album <playlist name> <album name>`

### Example

```bash
$ muzak-cmd playlist-add-album best-of-2016 Coloring Book
```

### Example Response

```json
{
   "response" : {
      "error" : null,
      "data" : null,
      "method" : "playlist_add_album"
   }
}
```

## `playlist-add-artist`

Adds the given artist (i.e., their songs) to the given playlist.

### Syntax

`playlist-add-artist <playlist name> <artist name>`

### Example

```bash
$ muzak-cmd playlist-add-artist dad-rock The Beatles
```

### Example Response

```json
{
   "response" : {
      "error" : null,
      "data" : null,
      "method" : "playlist_add_artist"
   }
}
```

## `playlist-add-current`

Adds the currently playing song to the given playlist.

### Syntax

`playlist-add-current <playlist name>`

### Example

```bash
$ muzak-cmd playlist-add-current favorites
```

### Example Response

```json
{
   "response" : {
      "error" : null,
      "data" : null,
      "method" : "playlist_add_current"
   }
}
```

## `playlist-del-current`

Removes the currently playing song from the given playlist.

### Syntax

`playlist-del-current <playlist name>`

### Example

```bash
$ muzak-cmd playlist-del-current favorites
```

### Example Response

```json
{
   "response" : {
      "error" : null,
      "data" : null,
      "method" : "playlist_del_current"
   }
}
```

## `playlist-delete`

Deletes the given playlist.

### Syntax

`playlist-delete <playlist name>`

### Example

```bash
$ muzak-cmd playlist-delete worst-of-2016
```

### Example Response

```json
{
   "response" : {
      "error" : null,
      "data" : null,
      "method" : "playlist_delete"
   }
}
```

## `playlist-shuffle`

Shuffles the given playlist.

**Note:** If the playlist has already been enqueued, the playback order
is not affected.

### Syntax

`playlist-shuffle <playlist name>`

### Example

```bash
$ muzak-cmd playlist-shuffle favorites
```

### Example Response

```json
{
   "response" : {
      "error" : null,
      "data" : null,
      "method" : "playlist_shuffle"
   }
}
```

## `previous`

Play the previous song in the player's queue.

### Syntax

`previous`

### Example

```bash
$ muzak-cmd previous
```

### Example Response

```json
{
   "response" : {
      "error" : null,
      "data" : null,
      "method" : "previous"
   }
}
```

## `quit`

Terminates muzak.

**Note:** This terminates the {Muzak::Instance}, meaning that clients/interfaces
are expected to terminate as well.

### Syntax

`quit`

### Example

```bash
$ muzak-cmd quit
```

### Example Response

```json
{
   "response" : {
      "error" : null,
      "data" : "quitting",
      "method" : "quit"
   }
}
```

## `reload-index`

Reloads muzak's in-memory index.

**Note:** This does *not* rebuild the index file - `muzak-index` is provided
as a command line utility for that.

### Syntax

`reload-index`

### Example

```bash
$ muzak-cmd reload-index
```

### Example Response

```json
{
   "response" : {
      "error" : null,
      "data" : {
         "artist_count" : 262,
         "album_count" : 1161,
         "deep" : true
      },
      "method" : "reload_index"
   }
}
```

## `shuffle-queue`

Shuffles the player's playback queue.

### Syntax

`shuffle-queue`

### Example

```bash
$ muzak-cmd shuffle-queue
```

### Example Response

```json
{
   "response" : {
      "error" : null,
      "data" : null,
      "method" : "shuffle_queue"
   }
}
```

## `songs-by-artist`

Returns all songs by the given artist.

### Syntax

`songs-by-artist <artist name>`

### Example

```bash
$ muzak-cmd songs-by-artist "Bob Dylan"
```

### Example Response

```json
{
   "response" : {
      "error" : null,
      "data" : {
         "songs" : [
            "The Times They Are A' Changing",
            "Hurricane",
            "All Along the Watchtower"
         ]
      },
      "method" : "songs_by_artist"
   }
}

```

## `toggle`

Toggles the playback state of the player.

### Syntax

`toggle`

### Example

```bash
$ muzak-cmd toggle
```

### Example Response

```json
{
   "response" : {
      "error" : null,
      "data" : null,
      "method" : "toggle"
   }
}
```

