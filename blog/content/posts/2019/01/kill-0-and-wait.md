+++
date = "2019-01-06T12:00:00+09:00"
title = "Tips: Kill -0 and Wait command"
tags = ["unix"]
categories = ["programming"]
+++

[GoogleCloudPlatform/gke-managed-certs](https://github.com/GoogleCloudPlatform/gke-managed-certs) を覗いていたら普段あまり使わないunix commandがあったのでメモ

### `wait $pid`

特定プロセスの完了を待つ。

ついついwhile loopでpolingしちゃうことがあるんだけど、そんなことしなくて良いよね。

e.g. backgroud jobに飛ばした処理を待ってなにかする

```console
% sleep 1 &; wait $! && echo 'finished!'
[1] 16769
[1]  + done       sleep 1
finished!
```

### `kill -0 $pid`

`kill -0` はprocessが存在することを確認することができる

e.g. processが存在していたら処理を実行する。

```console
% sleep 1 &; kill -0 $! && echo "existing"
[1] 16575
existing
~/src/github.com/GoogleCloudPlatform/gke-managed-certs
master %
[1]  + done       sleep 1
~/src/github.com/GoogleCloudPlatform/gke-managed-certs
master % sleep 1 &; wait $! && kill -0 $!
[1] 16603
[1]  + done       sleep 1
kill: kill 16603 failed: no such process
```

ちなみに、以下のようにwhileしてpidがあるときだけwaitを繰り返す理由は調べてみたのだがわからない :thinking:

```console
sleep 10 &
pid="$!"

# We need a loop here, because receiving signal breaks out of wait.
# kill -0 doesn't send any signal, but it still checks if the process is running.
while kill -0 $pid > /dev/null 2>&1; do;
  wait $pid
done
exit "$?"
```

処理が継続しているのにwaitを抜けることがあるのだろうか？

- [stackexchange - What does `kill -0` do?](https://unix.stackexchange.com/questions/169898/what-does-kill-0-do)
