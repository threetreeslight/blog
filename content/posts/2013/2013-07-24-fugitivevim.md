+++
date = "2013-07-24T02:42:14+00:00"
draft = false
tags = ["git", "vim", "fugitive"]
title = "fugitive.vimの使い方を良く忘れる"
+++
[fugitive.vim](https://github.com/tpope/vim-fugitive)を積極的に使ってこなかったため、使い方を忘れる始末。

というわけで、備忘録代わりにでも書きたいと思います。


## 過去ソースを参照しつつ修正するとき
***

#### 方法１：`:Gdiff`

左ウィンドウがインデックス。右ウィンドウがワークで`dp`。

#### 方法２：`:Gblame`

左ウィンドウがコミットログ。右ウィンドウがソース

`~` : 見たいコミットログを選択して、~でHAED~相当の当該ログのソース

`P` : 見たいコミットログを選択して、~でHAED~相当の当該ログのソース

enter : 当該ログのコミットログ

そんなこんなでコピペして直したり。

#### 方法３： `:Gstatus`

対象ファイルにカーソルを合わせ`D`でVimDiff表示


## git addからcommit、そしてgit push
***

#### git add ( 編集中ファイルのみ )

	:Gwrite
	
もしくは

	:Gstatus

からの対象ファイルを選択して`-`または`p`

#### git commit

	:Gcommit -am "hogehoge"

もしくは

	:Gstatus
	からの
	C

でコミット

#### git push

あとは素直に

	:Git push origin master


## 部分的にgit add
***

	:Gdiff

左ウィンドウがインデックス。右ウィンドウがワーク

インデックス取り込みたい対象の箇所でdp

	:Gcommit -v
	
確認してみる


## その他
***

大体本家とhelpを見れば解決。

* [VimmerなGit使いはfugitive.vimを今すぐ入れたほうがいい](http://yuku-tech.hatenablog.com/entry/20110427/1303868482)
* [fugitive.vim が便利すぎたのでメモ](http://cohama.hateblo.jp/entry/20120317/1331978764)