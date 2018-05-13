+++
date = "2013-05-30T14:57:44+00:00"
draft = false
tags = ["rails", "rails4", "rack-rewrite", "rack", "thread safe"]
title = "rails4でrack rewriteの設定"
+++
rails4では、デフォルトでthread safeが適用されている。

そのため、以下のようなinitializeの書き方をすると怒られる。そんなの無いよ。ってな感じで。

	Hoge::Application.config.middleware.insert_before(Rack::Lock, Rack::Rewrite) do

そのため、以下のようにRuntimeにする

	Hoge::Application.config.middleware.insert_before(Rack::Runtime, Rack::Rewrite) do



参考

* [Rails 4 is thread safe by default [Rails 4 Countdown to 2013]](http://blog.remarkablelabs.com/2012/12/rails-4-is-thread-safe-by-default-rails-4-countdown-to-2013)
* [rack-rewrite with Rails 3.2.3 on Heroku](http://stackoverflow.com/questions/11569176/rack-rewrite-with-rails-3-2-3-on-heroku)