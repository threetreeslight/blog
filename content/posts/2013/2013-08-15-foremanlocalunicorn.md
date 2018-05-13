+++
date = "2013-08-15T03:15:16+00:00"
draft = false
tags = ["foreman", "rails", "unicorn", "heroku"]
title = "foremanを使ってlocalのunicornを動かす。"
+++
そういえば、商用サービスでherokuを使っているのですが、よくよく考えてみると、本番と同じproduction環境がlocalに無いってまずくない？

別環境でごまかさず、unicornをforemanで起動する環境を整えました。

## 設定
***

	$ vim Gemfile
	gem 'foreman'
	
	$ bundle install
	$ vim Procfile
	web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb

## 内容をverifyして
***
	$ foreman check
	valid procfile detected (web)

## 動かしてみる
***

	$ foreman start
	09:09:34 web.1  | started with pid 95960
	09:09:36 web.1  | I, [2013-08-15T09:09:36.038648 #95960]  INFO -- : Refreshing Gem list
	09:09:46 web.1  | I, [2013-08-15T09:09:46.225668 #95960]  INFO -- : listening on addr=0.0.0.0:5000 fd=14
	09:09:46 web.1  | I, [2013-08-15T09:09:46.229835 #95960]  INFO -- : master process ready
	09:09:46 web.1  | I, [2013-08-15T09:09:46.272823 #95998]  INFO -- : worker=0 ready
	09:09:46 web.1  | I, [2013-08-15T09:09:46.273745 #95999]  INFO -- : worker=1 ready
	09:09:46 web.1  | I, [2013-08-15T09:09:46.276185 #96000]  INFO -- : worker=2 ready

	$ ps aux | ack unicorn
	hoge      96000   0.0  0.7  2566904  28676 s002  S+    9:09AM   0:00.04 unicorn worker[2] -p 5000 -c ./config/unicorn.rb
	hoge      95999   0.0  0.7  2566904  28236 s002  S+    9:09AM   0:00.04 unicorn worker[1] -p 5000 -c ./config/unicorn.rb
	hoge      95998   0.0  0.7  2566904  28740 s002  S+    9:09AM   0:00.04 unicorn worker[0] -p 5000 -c ./config/unicorn.rb
	hoge      95960   0.0  3.1  2566904 131668 s002  S+    9:09AM   0:10.29 unicorn master -p 5000 -c ./config/unicorn.rb

立ち上がっとるようです。

ちなみに、Foremanが`$PORT`環境変数のデフォルト値として、5000番提供します。

なので、`localhost:5000`にアクセスすると、無事動きました。


### 環境変数の設定など
***

プロジェクトディレクトリの.envファイル内に保存される変数は、Foremanにより実行時、環境へ追加されるとのことなので。

	$ echo "RACK_ENV=development" >>.env
	$ echo "RAILS_ENV=development" >>.env
	$ foreman run irb
	> puts ENV["RACK_ENV"]
	> development

### P.S.
***

unicornの設定ファイルについては、herokuを参照。

```
$ curl https://raw.github.com/heroku/ruby-rails-unicorn-sample/master/config/unicorn.rb > config/unicorn.rb
```

参考

* [ddollar/foreman](https://github.com/ddollar/foreman)
* [rails cast - #281 Foreman](http://railscasts.com/episodes/281-foreman?language=ja&view=asciicast)
* [herokaijp/devcenter](https://github.com/herokaijp/devcenter/wiki/procfile)