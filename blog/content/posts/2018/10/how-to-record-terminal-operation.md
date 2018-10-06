+++
date = "2018-10-06T12:00:00+09:00"
title = "How to record terminal operation?"
tags = ["terminal", "blog", "gifani"]
categories = ["programming"]
+++

blogなどにかっこいい感じにterminalの情報を上げたいときがある。

この方法について、いくつかの方法があったので紹介したい。

## [mjording/ttyrec](https://github.com/mjording/ttyrec)

おなじみttyrec, ttyplay

### Usage

```bash
# Install
brew install ttyrec

# rec start with:
ttyrec demo.tty

# stop by exit tty

# reply with:
ttyplay demo.tty
```

## [asciinema](https://asciinema.org/)

[![asciicast](https://asciinema.org/a/6i3yq0xOwMT9DvRdR9ELXeeW1.png)](https://asciinema.org/a/6i3yq0xOwMT9DvRdR9ELXeeW1)

よく見るasciinema. ホスティングもコマンド一発なのでホント楽。

ちなみにpecoとかfzf噛むとその画面は記録されない :sweet_face:

### Usage

```bash
brew install asciinema

# Start recording with:
asciinema rec

# Upload operation with:
asciinema upload
```

## [faressoft/terminalizer](https://github.com/faressoft/terminalizer)

![](/images/blog/2018/10/06/kubectx.gif)

node製のterminal操作記録ツール。
操作をyamlで書き出してあとから編集できたり、いろいろ嬉しい。

anigifや外部の動画サービスに書き出しが気楽なのも良い。

### Usage

```bash
npm install -g terminalizer
terminalizer init
```

```bash
# Start recording with:
terminalizer record demo
# Generate anigif with:
terminalizer render demo
```

![](/images/blog/2018/10/06/kubectx.gif)

こんな
