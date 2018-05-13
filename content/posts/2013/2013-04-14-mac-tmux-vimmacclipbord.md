+++
date = "2013-04-14T16:26:43+00:00"
draft = false
tags = ["tmux", "vim", "mac", "clipboard", "yank"]
title = "mac + tmux + vimでmacのclipbordにコピーできるようにしてみた。"
+++
とりあえずシンプルに。

### tmux上でmacのclipboradを利用できるように
***

	$ brew install reattach-to-user-namespac
	$ vim ~/.tmux.conf
	set-option -g default-command "reattach-to-user-namespace -l zsh"

### vimrcの設定
***

	$ vim ~/.vimrc
	vmap <C-c> :w !pbcopy<cr><cr>


これでCtrl+cでコピーが出来る。
