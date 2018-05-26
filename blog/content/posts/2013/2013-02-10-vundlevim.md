+++
date = "2013-02-10T10:05:00+00:00"
draft = false
tags = ["vim", "plugin", "vundle"]
title = "vundle使ってvim最初から設定"
+++
sublime2を利用しているものの、ターミナル間の移動が非常に面倒になってきたので、vimに統一しようと試みる。


### 必要なディレクトリの作成

	$ mkdir -p ~/.vim/bundle
	$ cd ~/.vim
	$ touch .vimrc
	$ ln -s ./.vim/.vimrc ./
	$ git init
	$ vim ./.gitignore
	

### vunble

[vendle](https://github.com/gmarik/vundle)

	$ cd ~/.vim
	$ git submodule add git://github.com/gmarik/vundle.git ./bundle/vundle
	$ ln -s ./.vimrc ~/
	
	$ vim ./.vimrc
	"" display
	"
	set showmode
	set title
	set ruler
	set showcmd
	set showmatch
	set laststatus=2
	
	"" dev
	"
	syntax on
	set smartindent
	
	" tab
	set expandtab
	set ts=2 sw=2 sts=0
	
	autocmd BufReadPost * if line("'\"") &gt; 0 &amp;&amp; line("'\"") &lt;= line("$") | exe "normal g`\"" | endif
	
	"" search
	"
	set ignorecase
	set smartcase
	set wrapscan
	set noincsearch
	set nohlsearch
	
	"" plugnin
	"
	" vundle
	set nocompatible " be iMproved 
	filetype off  " required!
	set rtp+=~/.vim/bundle/vundle/
	call vundle#rc()
	
	" let Vundle manage Vundle
	" required!
	Bundle 'gmarik/vundle'
	
	" My Bundles here:
	"
	" original repos on github
	Bundle 'scrooloose/nerdtree'
	Bundle 'tpope/vim-rails'
	Bundle 'tpope/vim-bundler'
	Bundle 'vim-ruby/vim-ruby'
	Bundle 'vim-scripts/dbext.vim'
	
	
	filetype plugin indent on " required!

	$ vim 
	:BundleInstall



うん。超便利になった。

