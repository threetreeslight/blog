+++
date = "2013-10-12T13:47:26+00:00"
draft = false
tags = ["ruby", "rubyist", "rubocop", "vim", "styleguide"]
title = "rubocopを入れて意識の高いrubyist目指す"
+++
コードが良い臭いのするコードでありたい。

そのためには、適切なstyle guideに遵守、もとい慣れ親しむ事が必要？というか出来てないから怒ってほしい？

そんなときに使うのが[rubocop](https://github.com/bbatsov/rubocop)


	$ rubocop app spec lib/something.rb
	
こんな感じでチェック実行可能。


install
-------

まずインストール。個人的にはboxen辺りに仕込んでおきました。

	$ gem install rubocop
	

vimに組み込む
-----------

今回は、vim-rubocopを利用します。

	$ vim ~/.vimrc
	  " Ruby static code analyzer.
	  NeoBundleLazy 'ngmy/vim-rubocop', {
	      \   'autoload' : { 'filetypes' : ['ruby'] }
	      \ }
	  let s:bundle = neobundle#get('vim-fugitive')
	  function! s:bundle.hooks.on_source(bundle)
	    let g:vimrubocop_keymap = 0
	    nmap <Leader>r :RuboCop<CR>
	  endfunction

試す
---

hoge.rubyを作って試します。

	$ vim hoge.ruby
	def badName
	  if something
	    test
	    end
	end
	
	vim> \r
	
	hoge.rb|2 col 5| C: Use snake_case for methods.
	hoge.rb|3 col 3| C: Favor modifier if/unless usage when you have a single-line body. Another good alternative is the usage of control flow &&/||.

すばらしい。

必要に応じて
----------

git commitにhookしたり

[Gitフックを使っておかしいRubyコードをコミットできないようにする](http://qiita.com/yuku_t/items/ad072418290a2b01a35a)


vim保存時に自動実行したり

[Rubocopをsyntasticを使ってVimから自動実行する](http://qiita.com/yuku_t/items/0ac33cea18e10f14e185)


します。