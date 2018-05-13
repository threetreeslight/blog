+++
date = "2013-09-22T06:01:38+00:00"
draft = false
tags = ["unicorn", "development", "local", "rails"]
title = "Unicornをrails4のローカル開発サーバーとして使う際のログ設定"
+++
Unicornをローカル開発環境で使うと、基本的にはdebugログを吐かない。これで悲しんだ。

ちゃんとdebugログを吐くように設定することで、幸せが訪れる。

	$ config/environments/development.rb
	
	  # for unicorn
	  config.logger = Logger.new(STDOUT)
	  config.logger.level = Logger.const_get('DEBUG')


	$ foreman start
	
