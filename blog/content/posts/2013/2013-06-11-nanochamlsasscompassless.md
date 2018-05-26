+++
date = "2013-06-11T14:43:00+00:00"
draft = false
tags = ["rack", "nanoc", "haml", "sass", "less", "compass"]
title = "nanocにhamlやsass、compass、lessやら仕込んで、使いやすくしないと。"
+++
nanocにhamlやsass、compass、lessを仕込みます。

### haml, sass, compass, less
***

必要なgemをごにょごにょ。

	$ vim Gemfile
	gem 'haml'
	gem 'less'
	gem 'sass'
	gem 'compass'
	gem 'coffee-script'
	gem 'uglifier'

	gem 'therubyracer' # v8 to use compile less execjs

less, compass, sass周りの設定。compressもします。

	$ vim Rule
	compile '/stylesheets/_*/' do
	  # do not compile
	end
	compile '/stylesheets/*/' do
	  case item[:extension]
	  when 'sass'
	    filter :sass, sass_options
	  when 'scss'
	    filter :sass, sass_options
	  when 'less'
	    filter :less
	  when 'css'
	    # Nothing
	  end
	end
	
	…

	route '/stylesheets/_*/' do
	  nil
	end
	route '/stylesheets/*/' do
	  item.identifier.chop + '.css'
	end
	
	$ vim config/compass.rb
	http_path     = '/' 
	project_path  = '../' 
	css_dir       = 'output/stylesheets' 
	sass_dir      = 'content/stylesheets' 
	images_dir    = 'output/images'
	output_style  = :compressed

coffeescript周りの設定とcompress。

	compile '/javascripts/*/' do
	  case item[:extension]
	  when 'coffee'
	    filter :coffeescript
	  when 'js'
	    # Nothing
	  end
	  filter :uglify_js
	end
	
	…

	route '/javascripts/*/' do
	  item.identifier.chop + '.js'
	end

hamlなどのテンプレートエンジン周りを設定します。

	compile '*' do
	  if item.binary?
	    # don’t filter binary items
	  else
	    case item[:extension]
	    when 'haml'
	      filter :haml, haml_options
	    when 'erb'
	      filter :erb
	    when 'md'
	      filter :kramdown
	    when 'nothing'
	      # Nothing
	    end
	    layout 'default'
	  end
	end

参考

* [nanoc filter](http://nanoc.ws/docs/reference/filters/)
* [meskyanichi / nanoc-heroku](https://github.com/meskyanichi/nanoc-heroku)
* [ngs / nanoc-heroku-template](https://github.com/ngs/nanoc-heroku-template)


### やりかけTODO
***

* sprocketsで結合
* assetsをfog経由でS3に吹っ飛ばすrake
* rack-livereloadによるlivereload対応
* herokuに飛ばす仕組みづくり。

特にlivereloadをrack-livereloadで動かすためには、もう少しrackの仕組みを理解しないと厳しいかもしれない。
