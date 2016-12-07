muzak
=====

muzak is an attempt at a metamusic player.

It indexes a filesystem tree, providing metadata to a user's preferred media
player. It also provides a pseudo-shell for controlling the indexed files
and the state of the player.

### Screenshot

![screenshot](https://sr.ht/A-oS.png)

### Usage

Muzak is still a work in process. Don't expect stability or pleasant output.

On the command-line:

```shell
$ ruby -Ilib muzak.rb # flags: --verbose, --debug
muzak> help
```

Daemonized:

```shell
$ ruby -Ilib muzakd.rb
echo "command" > ~/.config/muzak/muzak.fifo
```

### TODO

* GUI "frontend"?
* optional "deep" index containing ID3 tags
* isolation of art and music output (`Muzak::ArtProvider`?)
* current indexing/sorting logic is terrible
* all the documentation
* readline's tab complete is terrible with spaces (maybe use `bond`?)
