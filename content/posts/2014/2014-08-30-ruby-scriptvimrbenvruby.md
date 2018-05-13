+++
date = "2014-08-30T06:16:10+00:00"
draft = false
tags = ["rbenv", "vim", "ruby"]
title = "ruby scriptをvimから実行すると、rbenvのrubyが読まれない"
+++
## require

- rbenv
- ruby
- bash or zsh


## 問題

ruby scriptをvimから実行すると、rbenvのバージョンのrubyが読まれない

## 原因

intractive shell起動じゃないから。

## 解決策

zshの場合は、zshenvに記載

```bash
$ vim ~/.zshenv
export PATH="$HOME/.rbenv/bin:$PATH"
```

boxenの場合はzshevnにこんな感じ

```bash
$ vim ~/.zshenv
source /opt/boxen/env.sh
```

その他shellの場合

[rbenv - Unix shell initialization](https://github.com/sstephenson/rbenv/wiki/Unix-shell-initialization)
