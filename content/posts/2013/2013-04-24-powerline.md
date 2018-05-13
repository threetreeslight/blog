+++
date = "2013-04-24T04:29:09+00:00"
draft = false
tags = ["vim", "zsh", "tmux", "powerline"]
title = "powerlineの導入"
+++
かっこよくしたいので入れた。

**install**
***

	$ vim ~/.vimrc
	NeoBundle 'Lokaltog/powerline', { 'rtp' : 'powerline/bindings/vim'}
	
	:NeoBundleInstall

**fontの拡張**
***

[Lokaltog/powerline-fonts](https://github.com/Lokaltog/powerline-fonts)から落とす

いつもSouceCodeProを利用しているのでそれをダウンロードしfontをインストール


利用しているfontが無い場合は自分で作る

	$ brew install fontforge
	$ cp ~/Library/Fonts/hoge.ttf ~/.fonts
	$ fontforge -script $HOME/.vim/bundle/powerline/fonts/fontpatcher.py $HOME/Library/Fonts/hoge.ttf


**tmux**
***

iterm2のtmux対応バージョンダウンロード

	$ tar xvzf tmux-for-iTerm2-20130319.tar.gz
	$ cd tmux
	$ ./configure
	$ make
	$ make clean
	$ sudo make install
	
	$ vim ~/.tmux.conf
	source ~/.vim/bundle/powerline/bindings/tmux/powerline.conf
	set-option -g status-justify "centre"

**zsh**
***

怒られるので、後で直す。

	$ vim ./.zshrc
	. ~/.vim/bundle/powerline/powerline/bindings/zsh/powerline.zsh