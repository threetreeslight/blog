+++
date = "2013-05-25T14:34:45+00:00"
draft = false
tags = ["rails4", "compass"]
title = "rails4でcompass-railsを使う"
+++
rails4で[compass-rails](https://github.com/Compass/compass-rails)を使おうとすると、assets precompile時に以下のエラーが出て利用できない。

	Unsupported rails environment for compass
	
対処法は以下の通り

	$ vim Gemfile
	gem 'compass-rails', github: "milgner/compass-rails", branch: "rails4"
	
compassを利用して生成したsprite画像が反映されない場合

	$ vim application.css.sass
	@import "layout/*.png";
	@include all-layout-sprites;

	$ vim config/application.rb
	config.compass.images_dir = '/app/assets/images'
	
これでassets precompile通る。


詳しくはこちら

[https://github.com/Compass/compass-rails/pull/59](https://github.com/Compass/compass-rails/pull/59)

