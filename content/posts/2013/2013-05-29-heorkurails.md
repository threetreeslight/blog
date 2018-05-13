+++
date = "2013-05-29T12:47:48+00:00"
draft = false
tags = ["rails", "rails4", "heroku"]
title = "heorkuにrailsでプロイするとき忘れがちな設定。"
+++
rails4でlocalウキウキ開発して、いざherokuにデプロイしたらassets周りが404でるおかしい。。

そういう時のheroku dev、みたら何か増えてた。

	gem 'rails_log_stdout',           github: 'heroku/rails_log_stdout'
	gem 'rails3_serve_static_assets', github: 'heroku/rails3_serve_static_assets'

ログ出力を標準出力にするのと、`config.serve_static_assets = true`にしてるだけじゃーん。

昔やったじゃーん。って悲しくなった。

でもこれをGemで提供されていると、ApplicationTemplateで設定するの楽そう。

参考：
[Getting Started with Rails 4.x on Heroku](https://devcenter.heroku.com/articles/rails4)