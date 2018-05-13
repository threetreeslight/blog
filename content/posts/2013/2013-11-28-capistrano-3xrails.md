+++
date = "2013-11-28T06:52:38+00:00"
draft = false
tags = ["rails", "capistrano"]
title = "capistrano 3.x系を使ってrailsをデプロイ"
+++
## 発端

サテー久しぶりにrails projectでも作るかなー、いつも通りdeployはcapでやろう。

	$ bundle install
	$ cap install
	
よし、中身を設定するかー。

	$ vim config/deploy.rb
	set :application, 'app_name'
	set :repo_url, 'git@repo:app.git'
	
	# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }
	
	# set :deploy_to, "/var/www/app_name"
	# set :scm, :git
	
	# set :format, :pretty
	# set :log_level, :debug
	# set :pty, true
	
	# set :linked_files, %w{config/database.yml}
	# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}
	
	# set :default_env, { path: "/opt/ruby/bin:$PATH" }
	# set :keep_releases, 5
	
	namespace :deploy do
	
	  desc 'Restart application'
	  task :restart do
	    on roles(:app), in: :sequence, wait: 5 do
	      # Your restart mechanism here, for example:
	      # execute :touch, release_path.join('tmp/restart.txt')
	    end
	  end
	
	  after :restart, :clear_cache do
	    on roles(:web), in: :groups, limit: 3, wait: 10 do
	      # Here we can do anything such as:
	      # within release_path do
	      #   execute :rake, 'cache:clear'
	      # end
	    end
	  end
	
	  after :finishing, 'deploy:cleanup'
	
	end
	
ファッ！？


> あ…ありのまま 今　起こった事を話すぜ！
> 
> 「おれは　いつも通りcapでデプロイ設定を使用と
> 思ったら　いつのまにか設定方法がごっそり変わっていた」
> 
> な…　何を言っているのか　わからねーと思うが　
> おれも　何をされたのか　わからなかった… 
> 
> 頭がどうにかなりそうだった…　催眠術だとか超スピードだとか
> 
> そんなチャチなもんじゃあ　断じてねえ
> 
> もっと恐ろしいものの片鱗を　味わったぜ…


というわけでcap3.xを学習

[capistrano - A remote server automation and deployment tool written in Ruby. For Any Language](http://www.capistranorb.com/)

汎用的なデプロイツールのDSL群みたいな感じに成ったのでしょう。

モジュール化されまくっているので、gemを考え直す

	$ vim Gemfile
	group :development do
	  gem 'capistrano'
	  gem 'capistrano-rails'
	end
	
	$ bundle install
	$ cap install

Capfileで必要なモジュールをロード
---

[Installation](http://www.capistranorb.com/documentation/getting-started/installation/)をみるとrailsが参考。

とりあえずassetsとmigration processおよび、consoleをrequire	

	# Load DSL and Setup Up Stages
	require 'capistrano/setup'
	
	# Includes default deployment tasks
	require 'capistrano/deploy'
	
	# Includes tasks from other gems included in your Gemfile
	require 'capistrano/rails'
	require 'capistrano/console'
	
	# Loads custom tasks from `lib/capistrano/tasks' if you have any defined.
	Dir.glob('lib/capistrano/tasks/*.cap').each { |r| import r }

prepare
---

[Preparing Your Application](http://www.capistranorb.com/documentation/getting-started/preparing-your-application/)を読むと今のところgitしかサポートしてないとの事。

> At present Capistrano v3.0.x only supports Git.

まず、id, pw, 環境変数が書かれたファイルはすべからくgitignoreに入れよとの事。

database.ymlとかもexampleとせよとのお達し。

	$ cp config/database.yml{,.example}
	$ echo config/database.yml >> .gitignore
	
AWSとかのキーもローカル開発時は、.evnファイルとして環境変数に入れておきましょう。

config/deploy/production.rb

今回は、さくらVPSにweb/ap, db全部乗せサーバーなので`role :all`でごっそりと。

	$ vim config/deploy/production.rb
	set :stage, :production

	role :all, %w{webadmin@sakura:1234}
	server 'sakura', user: 'webadmin', port: 1234, roles: %w{web app db}


共通設定ファイル周りをいじります。

deploy.rb

	$ vim config/deploy.rb
	set :application, 'foobar'
	set :repo_url, 'git@github.com:ae06710/foobar.git'

	set :deploy_to, "/var/www/${fetch(:application)}"
	set :keep_releases, 5

リポジトリにはbitbucketを利用しているので、bitbucketにnode(デプロイ先)の公開鍵をリポジトリのdeploy keyとしてぶっこんどきましょう。

cold start
---

[cold start](http://www.capistranorb.com/documentation/getting-started/cold-start/)までたどり着きました。

deploy:checkで必要なディレクトリ群の生成や、gitリポジトリ周りをチェックしてくれます。

とりあえず実行。

	$ cap production deploy:check

おーできてるできてる。

環境変数周りのチェックなどもタスクに食べさせたいなどはよしなに。


deploy
---

[Flow](http://www.capistranorb.com/documentation/getting-started/flow/)

信じてコマンドを叩く。


	$ cap production deploy

ちなみに、production.rbにて、server設定を行わないと、assets precompileで落ちます。

これをしなくても動くけど

	server 'sakura', user: 'webadmin', port: 1234, roles: %w{web app db}

こうなる。


	 WARN [SKIPPING] No Matching Host for /usr/bin/env if test ! -d /var/www/hogehoge/releases/20131127125226; then echo "Directory does not exist '/var/www/hogehoge/releases/20131127125226'" 1>&2; false; fi
	 WARN [SKIPPING] No Matching Host for bundle exec rake assets:precompile
	 WARN [SKIPPING] No Matching Host for /usr/bin/env if test ! -d /var/www/binary_option/releases/20131127125226; then echo "Directory does not exist '/var/www/binary_option/releases/20131127125226'" 1>&2; false; fi
	 WARN [SKIPPING] No Matching Host for /usr/bin/env cp /var/www/hogehoge/releases/20131127125226/public/assets/manifest* /var/www/binary_option/releases/20131127125226/assets_manifest_backup
	 WARN [SKIPPING] No Matching Host for /usr/bin/env if test ! -d /var/ww


`role`だけで完結しようとするとだめってことね。

あと、database schemaはcookbookなりで作っておきましょう。


もしくは、setup時に`RAILS_ENV=production rake db:create`するように仕込むとかする。
