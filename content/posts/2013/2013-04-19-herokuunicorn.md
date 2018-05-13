+++
date = "2013-04-19T14:45:39+00:00"
draft = false
tags = ["rails", "unicorn", "heroku"]
title = "herokuでunicorn"
+++
herokuが提供している方法をそのままですが。

	$ vim Gemfile
	gem 'unicorn'
	
	$ bundle install
	
	$ curl https://raw.github.com/heroku/ruby-rails-unicorn-sample/master/config/unicorn.rb > config/unicorn.rb
	
	$ vim Procfile
	web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb
	
	$ git push heroku master

たったこれだけで直ぐ動くすばらしい。

細かい設定は後ほど。