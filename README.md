muzak
=====

muzak is an attempt at a metamusic player.

It indexes a filesystem tree, providing metadata to a user's preferred media
player. It also provides a pseudo-shell for controlling the indexed files
and the state of the player.

### Screenshot

![screenshot](https://sr.ht/A-oS.png)

### TODO

* current indexing/sorting logic is terrible
* index's timestamp should be used for automatic reindexing
* album art logic for `mpv` is funky
* all the documentation
* readline's tab complete is terrible with spaces (maybe use `bond`?)
