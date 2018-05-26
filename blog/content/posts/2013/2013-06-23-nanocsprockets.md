+++
date = "2013-06-23T01:37:59+00:00"
draft = false
tags = ["nanoc", "sprockets", "livereload"]
title = "nanocにsprockets入れたら幸せになった"
+++

### sprockets導入
***

railsでコンパイル+圧縮+結合をやってくれる良い子。

**sprocketsをインストール**

	$ vim Gemfile
	gem 'sprockets'
	gem 'sprockets-helpers'
	gem 'sprockets-less'
	gem 'sprockets-sass'
	gem 'nanoc-sprockets-filter'
	
	$ bundle install

**ディレクトリやファイルの下ごしらえ**

個人的にRailsのディレクトリ構造がとても好きという事もあるので、railsライクにディレクトリ構造を変更。

assets用のディレクトリを作成( vendorディレクトリには、ライブラリに使うなどお好きに )

	$ mkdir -p {content,vendor}/assets/{javascripts,stylesheets,images,fonts}

詳しいディレクトリの参照（sprocketsのpath）は[yannlugrin/nanoc-sprockets-filter](https://github.com/https://github.com/yannlugrin/nanoc-sprockets-filter)を参照


nanoc.ymlの設定変更

	$ vim nanoc.yml	
	# 出力先をpublic
	output_dir: public
	
	# watch対象ディレクトリにvendorを追加. guardで監視しているからそっちだけで十分かな？
	watcher:
	  dirs_to_watch: [ 'vendor', 'content', 'layouts', 'lib' ]

output dirを削除

	$ rm -rf ./output
	
	$ vim Guardfile
	# 監視対象にvendorディレクトリを追加
	guard 'nanoc' do
	  watch('nanoc.yaml') # Change this to config.yaml if you use the old config file name
	  watch('Rules')
	  watch(%r{^(vendor|content|layouts|lib)/.*$})
	end


**compile対象のファイルを作成**

テストコードも含め、こんな感じに。
なお、jqueryはvendor配下に配置しています。

	$ vim content/assets/javascripts/application.js.coffee
	#= require_tree .
	#= require jquery
	#= require_self
	
	$ ->
	  console.log('the body is ', $('body'))

css周りもこんな感じに。なお、normalize.cssはvendor配下です。

	$ vim content/assets/stylesheets/application.css.sass
	//= require_tree .
	//= require normalize
	//= require_self
	
	@import 'compass'
	

詳しくは[sstephenson/sprockets](https://github.com/sstephenson/sprockets)を参照。


**layoutのcssやjsの参照先を変更**

詳しくは[petebrowne/sprockets-helpers](https://github.com/petebrowne/sprockets-helpers)を参照

	$ vim layouts/default.haml
	
	%link{:rel => "stylesheet", :href => stylesheet_path('application') }
	%script{:type => "text/javascript", :src => javascript_path('application') }


**sprocketsのfilterをincludeするようhelperを設定**

	$ vim lib/helper.rb
	require 'less'
	require 'sass'
	require 'uglifier'
	require 'sprockets-helpers'
	require 'sprockets-less'
	require 'sprockets-sass'
	require 'nanoc-sprockets-filter'
	
	include Nanoc::Helpers::Sprockets
	
	Nanoc::Helpers::Sprockets.configure do |config|
	  config.environment = Nanoc::Filters::Sprockets.environment
	  config.prefix      = '/assets'
	  config.digest      = false # index.htmlを強制コンパイルする仕組みを作っていないので、digest無し。
	end


**ruleを修正**

	$ vim Rule
	# application.js.coffeeとapplication.css.sassのみコンパイル
	compile %r{/assets/(stylesheets|javascripts)/application.*} do
	  filter :sprockets, {
	    :css_compressor => :sass,
	    :js_compressor  => :uglifier
	  }
	end
	compile %r{/assets/(stylesheets|javascripts)/.+} do
	    # don’t compile partials
	end
	
	# application.js.coffeeとapplication.css.sassのみ吐く
	route %r{/assets/(stylesheets|javascripts)/application.*} do
	  Nanoc::Helpers::Sprockets.asset_path(item)
	end
	route %r{/assets/(stylesheets|javascripts)/.*} do
	  nil	  
	end
	# imagesやfontsはそのまま。
	route %r{/assets/(images|fonts)/.*} do
	  Nanoc::Helpers::Sprockets.asset_path(item)
	end
	
あとはcompileして動けばOK

	$ nanoc compile
	
### livereload
***

guard liveload使います。

	$ vim Gemfile
	gem 'guard-liveload'
	gem 'rack-livereload'
	
	$ bundle install

監視対象はoutput

	$ guard init livereload
	$ vim Guardfile
	guard 'livereload' do
	  watch(%r{public/.*$})
	end

接続するためのjsを埋め込む。

	$ vim layouts/default.haml
	…	
	%script{ src: "https://github.com/livereload/livereload-js/raw/master/dist/livereload.js?host=localhost" }

guardで接続する事を確認

	$ guard
	> 22:38:08 - INFO - Browser connected.

でもjsを管理するのは嫌だよね。更新はrackで処理

	$ vim config.ru
	require 'rack-livereload'

	use Rack::LiveReload	

ってconfig.ruとか読まないからadfsとかどうしよう。って言う事でrackでの処理は断念。


参考

* [livereload](http://livereload.com/)
* [livereload/livereload-js](https://github.com/livereload/livereload-js)
* [guard/guard-livereload](https://github.com/guard/guard-livereload)
* [johnbintz/rack-livereload](https://github.com/johnbintz/rack-livereload)



### 上記のテンプレートは
***

githubにあげてありますので、宜しければどうぞ。	

[nanoc-sprockets-template](https://github.com/ae06710/nanoc-sprockets-template)

### やりかけTODO
***

* heroku用にThin serverで動くように書き直す。ついでにローカルもthinで動くように変更して、rack上からliveReloadを動くようにして幸せになる。
* fogでS3にデプロイするrake taskを作る。
* asset_pathを開発時はlocal, デプロイ時はS3のpathになるよう切り分ける。
