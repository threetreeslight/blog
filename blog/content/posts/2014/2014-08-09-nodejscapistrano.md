+++
date = "2014-08-09T09:47:12+00:00"
draft = false
tags = ["node", "capistrano", "deploy", "nodejs"]
title = "nodejsのスクリプトをcapistranoでデプロイ"
+++
nodeのデプロイ洗ってみたけど、capistranoでやっていたり、shellでやっていたりベストプラクティスなんなんだろーと色々悩んでました。

必須の要件としてはシンプルに２つ。

- rollbackできるようにデプロイのバージョニング
- downtime無しで管理

## Require

スクリプト本体+http server

- nodejs
- coffee-script

process管理

- [pm2](https://github.com/Unitech/pm2)

deploy

- capistrano

## 下ごしらえ

packages

	$ npm i pm2@latest -g

gems

	$ bundle init
	$ vim Gemfile
	source 'https://rubygems.org'

	gem 'capistrano', '~> 3.2.0'
	gem 'capistrano-bundler', '~> 1.1.3'
	gem 'capistrano-npm'

	$ bundle

## デプロイ設定

initialize

	$ cap init

cap設定

	$ vim Capfile
	# Load DSL and Setup Up Stages
	require 'capistrano/setup'
	
	# Includes default deployment tasks
	require 'capistrano/deploy'
	require 'capistrano/bundler'
	require 'capistrano/npm'
	require 'capistrano/console'
	
	# Loads custom tasks from `lib/capistrano/tasks' if you have any defined.
	Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }

pm2をキックするスクリプトを作る
	
	$ vim lib/capistrano/tasks/pm2.rake
	require 'json'
	require 'pry'
	
	namespace :pm2 do
	  def start_app
	    within current_path do
	      execute :pm2, :start, fetch(:app_command)
	    end
	  end
	
	  def restart_app
	    within current_path do
	      execute :pm2, :restart, fetch(:app_command)
	    end
	  end
	
	  def stop_app
	    within current_path do
	      execute :pm2, :stop, fetch(:app_command)
	    end
	  end
	
	  def force_stop_app
	    within current_path do
	      execute :pm2, :stop, fetch(:app_command), '--force'
	    end
	  end
	
	  def graceful_reload_app
	    within current_path do
	      execute :pm2, :gracefulReload, fetch(:app_command)
	    end
	  end
	
	  def delete_app
	    within current_path do
	      execute :pm2, :delete, fetch(:app_command)
	    end
	  end
	
	  def app_status
	    within current_path do
	      ps = JSON.parse(capture :pm2, :jlist, fetch(:app_command))
	      if ps.empty?
	        return nil
	      else
	        # status: online, errored, stopped
	        return ps[0]["pm2_env"]["status"]
	      end
	    end
	  end
	
	  desc 'Start app'
	  task :start do
	    on roles(:app) do
	      start_app
	    end
	  end
	
	  desc 'Stop app'
	  task :stop do
	    on roles(:app) do
	      stop_app
	    end
	  end
	
	  desc 'Restart app gracefully'
	  task :restart do
	    on roles(:app) do
	      case app_status
	      when nil
	        info 'App is not registerd'
	        start_app
	      when 'stopped'
	        info 'App is stopped'
	        restart_app
	      when 'errored'
	        info 'App has errored'
	        restart_app
	      when 'online'
	        info 'App is online'
	        graceful_reload_app
	      end
	    end
	  end
	
	  desc 'Stop app immediately'
	  task :force_stop do
	    on roles(:app) do
	      force_stop_app
	    end
	  end
	
	  desc 'Delete app'
	  task :delete do
	    on roles(:app) do
	      delete_app
	    end
	  end
	end
	
デプロイ設定をごにょごにょ

	$ vim config/deploy.rb
	lock '3.2.1'
	
	set :application, 'YOUR_APP_NAME'
	set :app_command, 'egg.coffee'
	set :repo_url,    'git@github.com:foo/foo.git'
	
	set :deploy_to,   "/var/www/#{fetch(:application)}"
	set :log_level, :debug
	
	set :linked_dirs,  %w{ bin log node_modules }
	
	set :default_env, { node_env: "local" }
	
	namespace :deploy do
	
	  desc 'Restart application'
	  task :restart do
	    invoke 'pm2:restart'
	  end
	
	  after :publishing, :restart	
	end

targetにlocal作る(local VMを対象にしています)

	$ vim config/deploy/local.rb
	set :branch, ENV['BRANCH'] || 'master'
	set :user,   'vagrant'

	role :app, [ "#{fetch(:user)}@foo-server" ]
	
	server 'foo-server', user: fetch(:user), roles: %w{ app }

## localVMに流す

VMにPM2入れておいて

	$ cap local deploy:check
	$ cap local deploy

ok

pm2の操作はrakeの通り


## P.S.

pm2でもgitによるバージョニングのdeployが可能なので、それでやるほうがnodeの哲学に合ってるかもしれません。