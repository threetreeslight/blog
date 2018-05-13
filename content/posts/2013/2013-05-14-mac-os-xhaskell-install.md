+++
date = "2013-05-14T23:14:12+00:00"
draft = false
tags = ["mac", "brew", "homebrew", "haskell"]
title = "[mac os x]haskell install"
+++
すごいH本そろそろやろうかと思う。

そのためにmacに環境入れます。

**require**

* homebrew
* mac os x mountainlion

**install**

時間かかるので根気づよく待つ。大体２０分ぐらい。

	$ brew install ghc
	$ brew install haskell-platform


haskell-platformについては、OSへの対応状況等を意識してインストールしないと悲しくなる。


https://groups.google.com/forum/?fromgroups=#!topic/start-haskell/F2xiUb2-xos

**動作確認**

ターミナルを再起動

	$ ghci
	Prelude> 1+3
	Prelude> :help
	Prelude> :quit
 
ok


P.S.

そもそもghcコンパイラを入れる必要が合ったのだろうか？

haskell-plartform内に含まれているし、と今更ながら思う。