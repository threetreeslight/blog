+++
date = "2014-04-27T07:21:30+00:00"
draft = false
tags = ["mysql", "RDS", "InnoDB", "unique", "index"]
title = "[mysql]unique_indexは767bytesまで"
+++
mysql + InnoDB でkeyを生成しようとしたらすんごい勢いで起こられた。

	Mysql2::Error: Specified key was too long; max key length is 767 bytes:


どうやらkey値が767 bytesまでしかだめな模様。

ふーむ。

以下のサイトも参考にしつつ無難な解決策を探る

[[mysql][memo]MySQLのUNIQUEなINDEXには長さ767byteまでしか使えない件と対策](http://d.hatena.ne.jp/tanamon/20090930/1254332746)

## 状況

utf8mb4だと１文字４byte換算に成る。

そうすると、、、約191文字しか入らないという悪夢。南無三。

まっそもそもkey値にそんな長い文字列をぶっ込む事態で、それやりたいんならsolarかelastic searchでも使うと言い寄って事なんだと思う。うん。

## 解決策

1. 短くする
2. 文字コードを変える

無難な、とか良いながら２種類しか無いと思う。
