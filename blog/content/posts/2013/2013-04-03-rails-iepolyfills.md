+++
date = "2013-04-03T08:15:00+00:00"
draft = false
tags = ["rails", "ie", "polyfill", "modernizr", "CSS3", "CSS3 PIE", "PIE", "media query", "ie7.js", "ie8.js", "ie9.js"]
title = "[rails] IEのpolyfills頑張った。"
+++
今回はieを切らずに、ie8〜の対応を頑張った。

## ie用のcss, jsを用意する
***

	$ touch app/assets/javascripts/ie.js.coffee
	$ vim ie.js.coffee
	#= require_self

	$ touch app/assets/stylesheetss/ie.css.sass
	$vim ie.css.sass
	//= require_self

	$ vim config/production.rb
	config.assets.precompile += %w( ie.css ie.js )
	
	$ vim application.html.haml
	\[if IE]
	  =stylesheet_link_tag 'ie'
	  =javascript_link_tag 'ie'


**補足**

切り分け方法については、以下を参照

* [条件付きコメント](http://ja.wikipedia.org/wiki/%E6%9D%A1%E4%BB%B6%E4%BB%98%E3%81%8D%E3%82%B3%E3%83%A1%E3%83%B3%E3%83%88)

なお、coffee scriptでは`/*@cc_on`が利用できないので注意。

## modernizr
***

CSS3等の対応状況のチェックと、HTML5要素を有効化に利用する。なお、html5shivは組み込まれているので新しく追加する必要は無い。

[modernizr](http://modernizr.com/)

	$ vim ie.js.coffee
	#= require modernizr

## CSS3 PIEを利用する
***

[CSS3 PIE](http://css3pie.com/)

compass gemを利用して実装。

**対応しているCSS3**

* border-radius
* box-shadow
* background-image
* liner-gradient
* rgba

**実装**

	$ compass install compass/pie
	$ vim config/initializers/mime_types.rb
	
	Rack::Mime::MIME_TYPES.merge!({
	  ".ogg"     =&gt; "application/ogg",
	  ".ogx"     =&gt; "application/ogg",
	  ".ogv"     =&gt; "video/ogg",
	  ".oga"     =&gt; "audio/ogg",
	  ".mp4"     =&gt; "video/mp4",
	  ".m4v"     =&gt; "video/mp4",
	  ".mp3"     =&gt; "audio/mpeg",
	  ".m4a"     =&gt; "audio/mpeg",
	  ".htc"     =&gt; "text/x-component"
	})

**modernizrのチェックと組み合わせて実装**

	$ vim hoge.css.sass
	
	@import 'pie'
	ex)
	.hoge 
	  color: rgba(192,168,0,.5)
	  .hoge.rgba
	    @include pie
	  
詳しくは以下の[modernizrのドキュメント](http://modernizr.com/docs/#polyfills)を参照。




## 必要に応じてIE7.jsの実装
***

重いけど大体これで行ける。具体的な対応内容は以下の通り

[IE7 { css2: auto; }](http://ie7-js.googlecode.com/svn/test/index.html)

**Dwonload(CDN利用)**

[IE7.js](https://code.google.com/p/ie7-js/)

**実装**

	/[if lt IE 7]
	  %script{ :src =&gt; "http://ie7-js.googlecode.com/svn/version/2.1(beta4)/IE7.js" }
	/[if lt IE 8]
	  %script{ :src =&gt; "http://ie7-js.googlecode.com/svn/version/2.1(beta4)/IE8.js" }
	/[if lt IE 9]
	  %script{ :src =&gt; "http://ie7-js.googlecode.com/svn/version/2.1(beta4)/IE9.js" }
	  

**補足**

* IEのfont-face対応については挙動が怪しい。 -&gt; [issues265](https://code.google.com/p/ie7-js/issues/detail?id=265)
* エスケープ文字が理解されないので、IEの場合はjsで画像に置き換えるなどの処理が必要。
* nth-child系は初動のみの変換になるので、動的に生成されるnth-child系の対応についてはclassに置き換えておくこと。


## 必要に応じて活用
***

[HTML5-Cross-browser-Polyfills](https://github.com/Modernizr/Modernizr/wiki/HTML5-Cross-browser-Polyfills)


**js**

* IEで動作しない`console.log`を削除し忘れない。

**media query**

* [Respond.js](https://github.com/scottjehl/Respond) &lt;- 軽い

**nth-child系**

* [selectivizr](http://selectivizr.com/) &lt;- 動的にコンテンツを生成する場合は注意。

**filter**

* [css3-for-ie](http://kojika17.com/2011/02/css3-for-ie.html)

