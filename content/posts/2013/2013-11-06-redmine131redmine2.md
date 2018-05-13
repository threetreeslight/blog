+++
date = "2013-11-06T06:01:00+00:00"
draft = false
tags = ["redmine", "migration", "install"]
title = "redmineが1.3.1ととても悲しいので、redmineを2系に持っていく。"
+++
redmineが1.3.1ととても悲しいので、redmineを2系に持っていく。

ソースはgithubにあるし、普通のrailsプロジェクト（だと信じます）だと思うので、すんなりやっていきます。

local
-----

	$ git clone git@github.com:redmine/redmine.git
	$ cd redmine

database設定する

	$ mv config/database.yml.example config/database.yml
	$ vim config/database.yml
	
	# 今回はmysqlを利用するので、必要に応じてsocketの設定等を行う。

gem入れる。 ( database.yml見て、installするDBアダプターを調整している。 )

	$ bundle install --path vendor/bundle
	

dbつくって、マイグレーション

	$ rake db:create
	$ rake db:migrate
	
サーバー起動してどーん！

	$ rails s
	$ open http://localhost:8000
	
あっ怒られた。
	
	Internal error
	
	An error occurred on the page you were trying to access.
	If you continue to experience problems please contact your Redmine administrator for assistance.
	
	If you are the Redmine administrator, check your log files for details about the error.
	
	Back
	
	
config周りを直す

    $ mv config/configuration.yml.example config/configuration.yml

もう一度rails s

	$ rails s
	$ open http://localhost:8000

redmineをgithub projectからcloneしているので、今後のマイグレーションは超楽だろう。



production
----------

本番環境で移行します。

require

* rbenv
* ruby 2.0
* bundler
* apache
* passegner
* mysql

optの下辺りで良いかな？

	$ cd /opt
	$ git clone git@github.com:redmine/redmine.git

rubyのバージョンは早いし2.0で。

	$ rbenv local 2.0.0-p247

configure.ymlとdatabase.ymlを持ってくる

	$ cp configure.yml /opt/redmine/config/
	$ cp database.yml /opt/redmine/config/

database.ymlを修正。activerecordのdatabase adopterがmysqlからmysql2になっているので。

	$ vim config/database.yml
	production:
	  adapter: mysql2
	  ...

bundlerでpassengerも入るようにする。

	$ vim Gemfile
	gem 'passenger'

さて、gem群をインストール。テストと開発用もgem抜きで。

	$ bundle install  --without development test --path vendor/bundle

secret tokenの生成

	$ bundle exec rake generate_secret_token

dbをマイグレーション

	$ RAILS_ENV=production rake db:migrate

apache用のpassenger moduleをコンパイル

	$ bundle exec passenger-install-apache2-module
	
apacheの設定を修正


	$ vim /etc/httpd/conf.d/passenger.conf
	LoadModule passenger_module /opt/redmine/vendor/bundle/ruby/2.0.0/gems/passenger-4.0.23/buildout/apache2/mod_passenger.so
	PassengerRoot /opt/redmine/vendor/bundle/ruby/2.0.0/gems/passenger-4.0.23
	PassengerDefaultRuby /opt/rbenv/versions/2.0.0-p247/bin/ruby
	
	versions/2.0.0-p247/bin/ruby
	
	
	Header always unset "X-Powered-By"
	Header always unset "X-Rack-Cache"
	Header always unset "X-Content-Digest"
	Header always unset "X-Runtime"
	
	PassengerMaxPoolSize 20
	PassengerMaxInstancesPerApp 4
	PassengerPoolIdleTime 3600
	# PassengerUseGlobalQueue on
	PassengerHighPerformance on
	PassengerStatThrottleRate 10
	RailsSpawnMethod smart
	RailsAppSpawnerIdleTime 86400
	# RailsFrameworkSpawnerIdleTime 0
	
	
	RailsBaseURI /redmine
	

	$ /etc/init.d/httpd restart

動きました。

今後のバージョンアップはgit pullしてdb:migrateすればよさげになりました。よかったよかった。


[Redmine 2.3をCentOS 6.4にインストールする手順](http://blog.redmine.jp/articles/2_3/installation_centos/)