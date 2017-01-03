muzak
=====

[![Gem Version](https://badge.fury.io/rb/muzak.svg)](https://badge.fury.io/rb/muzak)

muzak is an attempt at a metamusic player.

It indexes a filesystem tree, providing metadata to a user's preferred media
player. It also provides a command API for controlling the indexed files
and the state of the player.

### Screenshot

![screenshot](https://sr.ht/V4mX.gif)

### Usage

Muzak is still a work in process. Don't expect stability or pleasant output.

```shell
$ ruby -Ilib bin/muzakd.rb
$ ruby -Ilib bin/muzak-cmd enqueue-artist "The Beatles"
```

### Documentation

API documentation can be found on [RubyDoc](http://www.rubydoc.info/gems/muzak/).

User documentation for commands can be found under [COMMANDS](COMMANDS.md),
as well as on RubyDoc.

User documentation for configuration can be found under [CONFIGURATION](CONFIGURATION.md),
as well as on RubyDoc.

### TODO

* GUI "frontend"?
* isolation of art and music output (`Muzak::ArtProvider`?)
* current indexing/sorting logic is terrible
