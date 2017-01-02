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

The `data` field may be either a string, array, or a sub-hash, depending on the
command issued. The documentation below will clarify whichever is the case for
each command.

The `method` field corresponds to the {Muzak::Cmd} method that was invoked.
In general this will be the "resolved" equivalent
(e.g. {Muzak::Cmd#albums_by_artist} for `albums-by-artist`). If muzak
doesn't recognize a command or can't match the given arguments to the
ones that the command expects, this field will be `command` instead
(as the processing is terminated in {Muzak::Instance#command}).

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

## `index-build`

(Re-)builds the index.

**Note:** This command can take quite some time to run. It's generally a good
idea to either set `index-autobuild` in the configuration to do automatic
rebuilds or schedule this command via `cron` or a similar tool.

### Syntax

`index-build`

### Example

```bash
$ muzak-cmd index-build
```

### Example Response

```json
{
   "response" : {
     "error" : null,
     "method" : "index_build",
     "data" : {
       "artists" : 10,
       "albums": 100
     }
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

### Syntax

### Example

```bash
$ muzak-cmd
```

### Example Response

```json

```

## `pause`

### Syntax

### Example

```bash
$ muzak-cmd
```

### Example Response

```json

```

## `play`

### Syntax

### Example

```bash
$ muzak-cmd
```

### Example Response

```json

```

## `player-activate`

### Syntax

### Example

```bash
$ muzak-cmd
```

### Example Response

```json

```

## `player-deactivate`

### Syntax

### Example

```bash
$ muzak-cmd
```

### Example Response

```json

```

## `playlist-add-album`

### Syntax

### Example

```bash
$ muzak-cmd
```

### Example Response

```json

```

## `playlist-add-artist`

### Syntax

### Example

```bash
$ muzak-cmd
```

### Example Response

```json

```

## `playlist-add-current`

### Syntax

### Example

```bash
$ muzak-cmd
```

### Example Response

```json

```

## `playlist-del-current`

### Syntax

### Example

```bash
$ muzak-cmd
```

### Example Response

```json

```

## `playlist-delete`

### Syntax

### Example

```bash
$ muzak-cmd
```

### Example Response

```json

```

## `playlist-shuffle`

### Syntax

### Example

```bash
$ muzak-cmd
```

### Example Response

```json

```

## `previous`

### Syntax

### Example

```bash
$ muzak-cmd
```

### Example Response

```json

```

## `quit`

### Syntax

### Example

```bash
$ muzak-cmd
```

### Example Response

```json

```

## `shuffle-queue`

### Syntax

### Example

```bash
$ muzak-cmd
```

### Example Response

```json

```

## `songs-by-artist`

### Syntax

### Example

```bash
$ muzak-cmd
```

### Example Response

```json

```

## `toggle`

### Syntax

### Example

```bash
$ muzak-cmd
```

### Example Response

```json

```

## `unfavorite`

### Syntax

### Example

```bash
$ muzak-cmd
```

### Example Response

```json

```


