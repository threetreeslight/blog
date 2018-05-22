+++
date = "2018-05-21T00:00:00+09:00"
title = "what's proc dir"
tags = ["gcp", "kubanetis", "k9s", "container"]
categories = ["programming"]
draft = "true"
+++

## そもそも `/dev/std*` ってなに？

そもそも `/dev` dir ってなんなのってちゃんと分かってない気がする。
闇に葬りたいときに概ねつなぐところでしょ？ぐらいな認識。
これってエンジニアとしてまずいよね。うん、、、まずい。。。

というわけで少し勉強してみる

nginx containerで `/dev` を眺めると

```
$ ps axf
PID   USER     TIME   COMMAND
    1 root       0:00 nginx: master process nginx -g daemon off;
    5 nginx      0:00 nginx: worker process
    6 root       0:00 sh
   12 root       0:00 ps axf

$ ls -la /dev | grep std
lrwxrwxrwx    1 root     root            15 May 19 05:54 stderr -> /proc/self/fd/2
lrwxrwxrwx    1 root     root            15 May 19 05:54 stdin -> /proc/self/fd/0
lrwxrwxrwx    1 root     root            15 May 19 05:54 stdout -> /proc/self/fd/1
```

`/proc` につなぎこんでいるね。
`fd` だからfile discriptorなんだろうけど、 `/proc` dirってなによ？

```
$ ls -l /proc
total 4
dr-xr-xr-x    9 root     root             0 May 19 05:54 1
dr-xr-xr-x    9 root     root             0 May 19 06:08 14
dr-xr-xr-x    9 nginx    nginx            0 May 19 06:04 5
dr-xr-xr-x    9 root     root             0 May 19 06:03 6
lrwxrwxrwx    1 root     root             0 May 19 05:54 self -> 14
```

processごとにdirがある。なんとなく見えてきた。

ここらへんは実態のない仮想ファイルなのだが、そもそも仮想ファイルとはなんであるのか？

```
$ ls -l /proc/self/fd
total 0
lrwx------    1 root     root            64 May 19 06:11 0 -> /dev/pts/1
lrwx------    1 root     root            64 May 19 06:11 1 -> /dev/pts/1
lrwx------    1 root     root            64 May 19 06:11 2 -> /dev/pts/1
ls: /proc/self/fd/3: cannot read link: No such file or directory
lr-x------    1 root     root            64 May 19 06:11 3
```

なるほど、[pts](https://en.wikipedia.org/wiki/Pseudoterminal) なのね。

ここらへんの `/proc` は、`/proc` はカーネルのデータ構造への一般的なアクセスポインで、特殊ファイルシステムと呼ばれるらしいです。

> ### 特殊ファイルシステム
> ローカル、リモートの何方のディク領域も管理しないファイルシステムです。
> 特殊ファイルシステム(12.3.1を参照) の典型的な例として `/proc` ファイルシステムがあげられます。
>
> -- 詳細Linux

