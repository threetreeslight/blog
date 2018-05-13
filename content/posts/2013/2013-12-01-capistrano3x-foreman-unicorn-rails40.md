+++
date = "2013-12-01T14:25:00+00:00"
draft = false
tags = ["rails4", "rails", "capistrano", "foreman", "unicorn"]
title = "capistrano3.x + foreman + unicorn + rails4.0"
+++
cap deploy時にforeman経由でunicornを起動するコマンドをexport、そして起動を行います。

プロセス監視や起動、停止を楽にするためです。



実行サービスは以下の環境です。

* cent os 6.4
* nginx
* ruby2.0.0
* rails4.0.1

デプロイ利用の環境は以下の通り、

* Capistrano Version: 3.0.1 (Rake Version: 10.1.0)
* foreman 0.63.0
* unicorn v4.7.0

capistrano3.xとrailsの設定はこちらを参考下さい。

[capistrano 3.x系を使ってrailsをデプロイ](http://threetreeslight.com/post/68344998681/capistrano-3-x-rails)



serverの足回り
-------------

nginxの設定はよしなに行って下さい。

	$ vim /etc/nginx/sites-avairables/my-app.conf
	
ttyアクセスが必要なのでcap実行ユーザーでsudo叩けるように

	$ visudo
	Defaults:my-user !requiretty

あと、最低限、railsの環境変数周りはexportしておきましょう。

	$ vim /etc/profile.d/my-app.sh
	RAILS_ENV=production
	RACK_ENV=production

上記はchefで作っておくと幸せ。


foreman taskの追加
-----------------

	$ vim lib/capistrano/tasks/foreman.cap
	namespace :foreman do
	  desc "Export the Procfile to Ubuntu's upstart scripts"
	  task :export do
	    on roles(:app) do
	      within release_path do
	        execute :sudo, <<-EOC
	          PATH=$PATH $(rbenv which bundle) exec \
	          foreman export upstart /etc/init -f ./Procfile \
	            -a #{fetch(:application)} \
	            -u webadmin -l /var/log/#{fetch(:application)}
	        EOC
	      end
	    end
	  end
	
	  desc "Start the application services"
	  task :start do
	    on roles(:app) do
	      execute :sudo, "start #{fetch(:application)}"
	    end
	  end
	
	  desc "Stop the application services"
	  task :stop do
	    on roles(:app) do
	      execute :sudo, "stop #{fetch(:application)}"
	    end
	  end
	
	  desc "Restart the application services"
	  task :restart do
	    on roles(:app) do
	      execute :sudo, "start #{fetch(:application)} || sudo restart #{fetch(:application)}"
	    end
	  end
	
	end

deploy processに追加
-------------------

	$ vim config/deploy.rb
	after "deploy", "foreman:export"
	after "deploy", "foreman:restart"


あとプロセス監視(monit)との組み合わせか。。。ふぅ。。