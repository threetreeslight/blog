+++
date = "2013-02-11T06:29:50+00:00"
draft = false
tags = ["vim", "terminal", "color", "Solarized"]
title = "[vim]SOLARIZEDが見やすいということで設定してみた。"
+++
で、vimだけ設定しようとしたら全然きれいに設定されないので、Terminalから設定をちゃんとやる。


## OS X terminal
*** 

今までの僕の設定

* Proをベース
* フォントは１３px、sourceCodePro
* アンチエイリアスがっちり

追加すること

* [Solarized](http://ethanschoonover.com/solarized)から落としてterminalからインポート
*  あと今までの僕の設定と一緒にする

## vim
***

.vimrc

	$ vim ~/.vim/.vimrc
	
	Bundle 'altercation/vim-colors-solarized'
	
	syntax enable
	let g:solarized_termcolors=256
	set background=dark
	colorscheme solarized	
	
	:BundleInstall

[vim-colors-solarized](https://github.com/altercation/vim-colors-solarized)

ok-
