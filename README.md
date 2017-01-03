muzak
=====

muzak is an attempt at a metamusic player.

It indexes a filesystem tree, providing metadata to a user's preferred media
player. It also provides a pseudo-shell for controlling the indexed files
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

Documentation for user commands can be found under [COMMANDS.md](./COMMANDS.md).

### TODO

* GUI "frontend"?
* isolation of art and music output (`Muzak::ArtProvider`?)
* current indexing/sorting logic is terrible
