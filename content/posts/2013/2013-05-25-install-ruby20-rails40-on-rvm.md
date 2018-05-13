+++
date = "2013-05-25T13:41:00+00:00"
draft = false
tags = ["rvm", "ruby-version", "ruby-gemset", "rvmrc", "rails4", "ruby2.0"]
title = "install ruby2.0 + rails4.0 on rvm"
+++
新しく軽めのサービスを作る必要があるため、使おうと思い今更ながらやりました。

ruby2.0もpreview2, rails4.0もrc1だし、いけるかなーと素人ながら思いまして。

### rvmの更新
***

	$ rvm get latest
	$ rvm reload
	$ rvm -v
	rvm 1.20.12 (latest) by Wayne E. Seguin , Michal Papis  [https://rvm.io/


### rubyの2.0のインストール
***

	$ rvm list known
	$ rvm install 2.0.0

ついでに1.9.3もバージョンアップし、最新版をデフォルトに設定。

	$ ruby install 1.9.3
	$ rvm use 1.9.3-p429 --default
	$ rvm uninstall 1.9.3-p362

### rails4のインストール
***

	$ rvm use 2.0.0@hoge --create
	$ gem install bundler
	$ gem install rails --version 4.0.0.rc1 --no-ri --no-rdoc  
	   

### rvmrcをruby-version, ruby-gemsetに切替
***

	$ vim ./.vimrc
	rvm use 1.9.3@hoge --create
	$ cd ..
	$ cd ./hoge
	You are using '.rvmrc', it requires trusting, it is slower and it is not compatible with other ruby managers,
	you can switch to '.ruby-version' using 'rvm rvmrc to [.]ruby-version'
	or ignore this warnings with 'rvm rvmrc warning ignore /Users/hoge/myapp/.rvmrc',
	'.rvmrc' will continue to be the default project file in RVM 1 and RVM 2,
	to ignore the warning for all files run 'rvm rvmrc warning ignore all.rvmrcs'.

読むとrvmrcは信頼性が必要だし、遅いし、他のruby managerと相性が悪いんで、`.ruby-version`使うべきだよ。と怒られた。

warrningにある通り実施。

	$ rvm rvmrc to [.]ruby-version
	$ ll | ack .ruby-
	-rw-r--r--   1 hoge  staff      8  5 25 20:22 .ruby-gemset
	-rw-r--r--   1 hoge  staff     16  5 25 20:22 .ruby-version
	                           
rbenvへの乗せ換え楽そう。

### とりあえずheroku
***

プロジェクトつくってみる。

	$ rails new hoge -T --skip-bundle
	$ bundle insstall
	$ rails s
	
こいつ・・・動くぞ！

Gemfileがすげーシンプル。
とりあえずGemflleもごにょごにょ色々書いて、とりあえずherokuにデプロイ。

	$ vim Gemfile
	ruby "2.0.0"

	# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
	gem 'rails', '4.0.0.rc1'
	
	# Use sqlite3 as the database for Active Record
	group :production do 
	  gem 'thin'
	  gem 'pg'
	end
	group :development do
	  gem 'sqlite3'
	end
        ...

	
	$ git init
	$ git add .
	$ git commit -am "Initial commit"
	$ heroku create unkounkounko
	$ git push heroku master
	
えっ？動かない。log見る。

	$ heroku logs -t
	
	2013-05-25T11:51:27.037870+00:00 app[web.1]: I, [2013-05-25T11:51:12.022608 #2]  INFO -- : Started GET "/" for 36.2.207.198 at 2013-05-25 11:51:12 +0000
	2013-05-25T11:51:27.037870+00:00 app[web.1]: F, [2013-05-25T11:51:12.025103 #2] FATAL -- :
	2013-05-25T11:51:27.037870+00:00 app[web.1]: ActionController::RoutingError (No route matches [GET] "/"):
	2013-05-25T11:51:27.037870+00:00 app[web.1]:   vendor/bundle/ruby/2.0.0/gems/actionpack-4.0.0.rc1/lib/action_dispatch/middleware/debug_exceptions.rb:21:in `call'
	2013-05-25T11:51:27.037870+00:00 app[web.1]:   vendor/bundle/ruby/2.0.0/gems/actionpack-4.0.0.rc1/lib/action_dispatch/middleware/show_exceptions.rb:30:in `call'
	2013-05-25T11:51:27.037870+00:00 app[web.1]
	…
		
あるあるなrouting error。

ちなみに、public配下にindex.htmlやpublic/assets配下にfavicon.icoが無い。app/assets/配下にimagesファイルもないのは驚いた。

	$ rails g controller hoge index
	$ vim config/routes.rb
	root 'hoge#index'

これでデプロイしたら動きました。


### 参考
***

web/db pressのこの号を参考

<div>
<a href="http://www.amazon.co.jp/gp/product/4774155071/ref=as_li_ss_il?ie=UTF8&amp;camp=247&amp;creative=7399&amp;creativeASIN=4774155071&amp;linkCode=as2&amp;tag=ae06710-22"><img src="http://ws.assoc-amazon.jp/widgets/q?_encoding=UTF8&amp;ASIN=4774155071&amp;Format=_SL160_&amp;ID=AsinImage&amp;MarketPlace=JP&amp;ServiceVersion=20070822&amp;WS=1&amp;tag=ae06710-22" alt="image" style="border: 0px;" /></a><img src="http://www.assoc-amazon.jp/e/ir?t=ae06710-22&amp;l=as2&amp;o=9&amp;a=4774155071" width="1" height="1" alt="" style="border:none !important; margin:0px !important; border: 0px;" />
</div>