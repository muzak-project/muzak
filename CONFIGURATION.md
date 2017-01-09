Muzak configuration
===================

This is the user-facing documentation for muzak's configuration.

For the developer documentation, see {Muzak::Config}.

## General behavior

All of muzak's configuration is kept in {Muzak::Config}, which is read
during load-time (i.e., during `require`) from {Muzak::CONFIG_FILE}, which
is YAML-formatted.

Muzak loads configuration keys just like commands, translating them from
`kebab-case` to `snake_case`. For example, take the following configuration:

```yaml
---
debug: true
verbose: true
music: "/home/william/mnt/fortuna/music/"
player: mpv
art-geometry: 300x300
jukebox-size: 100
deep-index: true
```

This is exposed in `Muzak::Config` as follows:

```ruby
Muzak::Config.debug # => true
Muzak::Config.verbose # => true
Muzak::Config.music # => "/home/william/mnt/fortuna/music/"
Muzak::Config.player # => "mpv"
Muzak::Config.art_geometry # => "300x300"
Muzak::Config.jukebox_size # => 100
```

Since {Muzak::Config} is populated whenever `muzak` is loaded via `require`,
it can be used within both scripts and clients. As such, it should be preferred
over custom configuration solutions for external programs that interact
primarily with muzak.

{Muzak::Config} resolves undefined keys to `false`, allowing a pattern like
this:

```ruby
something_special Config.special_key if Config.special_key
```

## A note on plugin configuration

Muzak loads a plugin if and only if `plugin-$name` is present in the
configuration, where `$name` is the lowercased class name of the plugin
(see {Muzak::Plugin::StubPlugin.plugin_name} and {Muzak::Config.plugin?}).

For example, to enable the made-up "foo" plugin, your configuration should
include something like this.

```
plugin-foo:
  foo-option-1: bar
  foo-option-2: baz
```

Plugins can, of course, access their configuration through {Muzak::Config}:

```
Muzak::Config.plugin_foo["foo-option-1"] # => "bar"
```

## Core configuration

These are the configuration keys observed by muzak's "core," particularly
{Muzak::Instance} any everything it controls.

In no particular order:

### `debug`

*Optional.*

*Default:* `false`

If `debug: true` is set in the configuration file, then muzak operates in
debugging mode. This includes printing debug messages and not forking `muzakd`
into the background.

### `verbose`

*Optional.*

*Default:* `true`

If `verbose: true` is set in the configuration file, then muzak operates in
verbose mode. This includes printing informational messages and not forking
`muzakd` into the background.

### `music`

*Mandatory.*

*Default:* `~/music`

`music: <directory>` should be set to the directory of the music library.
Muzak uses this key to point the indexer at the correct directory.

### `player`

*Mandatory.*

*Default:* `mpv`

`player: <player>` should be set to the short name of the user's music player.
Muzak uses this key to find the correct {Muzak::Player} underclass to
initialize and control.

The short names of supported players can be found in
{Muzak::Player::PLAYER_MAP}.

### `jukebox-size`

*Mandatory.*

*Default:* `100`

`jukebox-size: <size>` should be set to the number of random songs to enqueue
by default with the `jukebox` size.

### `art-geometry`

*Optional.*

*No default.*

`art-geometry: <geometry>` should be set to the desired size of displayed
album art, in "WxH" format. If not set, album art will be displayed at
any size the player pleases.

It's entirely up to the user's player to obey this value.

### `autoplay`

*Optional.*

*No default.*

`autoplay: <playlist>` should be set to a playlist that the user wishes to
automatically start when muzak starts. If not set, no playlist is automatically
played.

## Daemon/client configuration

These are configuration keys observed by muzak's interface(s).

### `daemon-port`

*Optional.*

*Default:* `2669`

`daemon-port: <port>` should be set to a valid port number for `muzakd` to
listen on.

### `daemon-host`

*Optional.*

*Default:* `localhost`

`daemon-host: <hostname>` should be set to the hostname for `muzakd` to
listen on.

### `dmenu-exec`

*Optional.*

*No default.*

`dmenu-exec: <command args...>` can be used to alter `muzak-dmenu`'s
invocation of `dmenu`. It can also be used to substitute a dmenu-compatible
prompt like `rofi -dmenu`.
