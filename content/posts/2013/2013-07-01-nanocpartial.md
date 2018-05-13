+++
date = "2013-07-01T08:18:29+00:00"
draft = false
tags = ["nanoc", "haml", "partical"]
title = "nanocでpartialを使う方法"
+++
丁度使ったのでメモ。

### 設定
***

renderメソッドを使えるようにする

	$ vim lib/helper.rb
	include Nanoc::Helpers::Rendering
	
### 配置
***

partialをlayoutsディレクトリに配置する。

renderの参照先はlayoutsディレクトリにのみ対応している。もちろんcontentsからでも参照は可能。

また、個人的な趣味になりますが、"_"(under bar)の接頭子が付いている物は、基本的にパーシャルとして取り扱います。

	$ vim layouts/_hoge.haml
	%h1 hogehoge
	%h2=@foo
	

### コンパイル回りの設定
***


コンパイルせず、ファイルも生成せず。

	$ vim Rule
	compile '*' do
	  if item.identifier =~ /_.*/
    	# don’t filter partial layouts items
	  end
	end

	route '*' do
	  if if item.identifier =~ /_.*/
	    nil # don’t create item
	  end
	end





参考：[nanoc basics](http://nanoc.ws/docs/basics/)