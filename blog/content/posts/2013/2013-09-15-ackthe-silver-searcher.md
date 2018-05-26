+++
date = "2013-09-15T03:21:33+00:00"
draft = false
tags = ["ack", "the_silver_searcher", "grep", "vim", "zsh"]
title = "ackより高速？The Silver Searcher導入"
+++
そいやack.vim入れてなかった、、、と思って調べた瞬間に出会った良さげな子。

**[ggreer/the_silver_searcher](https://github.com/ggreer/the_silver_searcher)**

早さの秘訣

> #### How is it so fast?
> 
> * Searching for literals (no regex) uses Boyer-Moore-Horspool strstr.
* Files are mmap()ed instead of read into a buffer.
* If you're building with PCRE 8.21 or greater, regex searches use the JIT compiler.
* Ag calls pcre_study() before executing the regex on a jillion files.
* Instead of calling fnmatch() on every pattern in your ignore files, non-regex patterns are loaded into an array and binary searched.
* Ag uses Pthreads to take advantage of multiple CPU cores and search files in parallel.
> 
> I've written several blog posts showing how I've improved performance. These include how I added pthreads, wrote my own scandir(), benchmarked every revision to find performance regressions, and profiled with gprof and Valgrind.

install
-------

brew

```
$ brew install the_silver_searcher
```

[ag.vim](https://github.com/rking/ag.vim)

```
$ vim $HOME/.vimrc
" filtering faster then ack,grep
NeoBundle 'rking/ag.vim'

```

action
------


```
$ ls -la | ag foo
$ ag bar
```

うーん幸せッ！！


参考：[ackを捨てて、より高速なag(The Silver Searcher)に切り替えた](http://blog.glidenote.com/blog/2013/02/28/the-silver-searcher-better-than-ack/)
