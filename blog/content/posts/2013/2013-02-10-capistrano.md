+++
date = "2013-02-10T02:18:43+00:00"
draft = false
tags = ["capistrano", "rails", "ruby", "deploy"]
title = "capistranoのタスク作る"
+++
sshログインしてwhoamiしてみる。

## in locale
***

gem入れる

	$ gem install bundler
	$ vim Gemfile
	source "http://rubygems.org"
	
	gem 'capistrano'
	
	$ bundle install
	$ capify .
	$ vim deploy.rb
	task :hoge, :hosts => "localhost" do
		run "whoami"
	endT

localからsshログインできるよう設定

	$ cap ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
	System Preferences -> Sharing -> Remote Login needed to be enabled
	
	$ ssh localhost


Test

	$ cap hoge
