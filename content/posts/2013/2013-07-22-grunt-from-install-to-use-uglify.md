+++
date = "2013-07-22T05:54:36+00:00"
draft = false
tags = ["node", "grunt", "uglify"]
title = "grunt使ってみる from install to use uglify"
+++
nodeを0.10系にアップグレードするにあたり、折角だからgruntぐらいは直ぐ使えるようにしてみる。

### nodeをnvmでupdate

	$ nvm list-remote
	$ nvm install v0.10.13
	
本家を見ると0.10.13がstableっぽいので。
	
必要に応じて古いvを削除

### grunt install
***

gruntを試す用にprojectを作る

	$ mkdir grunt_test
	$ cd grunt_test
	$ npm init
	
grunt-cliをインストール

	$ npm install -g grunt-cli
	$ grant	
	grunt-cli: The grunt command line interface. (v0.1.9)
	
	Fatal error: Unable to find local grunt.
	
	If you're seeing this message, either a Gruntfile wasn't found or grunt
	hasn't been installed locally to your project. For more information about
	installing and configuring grunt, please see the Getting Started guide:
	
	http://gruntjs.com/getting-started
	
gruntが入ってないよって。言われた通りgetting-started読む。

参考：[grant - getting-started](http://gruntjs.com/getting-started)

grantとpackage.json、gruntfileが無いとだめよっていう。

	$ npm install grunt --save-dev
	$ cat package.json
	...
	  "devDependencies": {
	    "grunt": "~0.4.1",
	  }
	...

	$ touch Gruntfile.js
	
これで準備完了。


### 次にuglifyプラグインを入れて試す
***

定番のminifyなどしてくれるuglifyを入れる

	$ npm install grunt-contrib-uglify

> ちなみにGruntfileはエキスポートして内容を記述する。

	$ vim Gruntfile.js
	module.exports = function(grunt) {
	  // Do grunt-related things in here
	};
	
今回ではGetting Startedにあるよう導入uiglifyを設定

	module.exports = function(grunt) {
	
	  // Project configuration.
	  grunt.initConfig({
	    pkg: grunt.file.readJSON('package.json'),
	    uglify: {
	      options: {
	        banner: '/*! <%= pkg.name %> <%= grunt.template.today("yyyy-mm-dd") %> */\n'
	      },
	      build: {
	        src: 'src/<%= pkg.name %>.js',
	        dest: 'build/<%= pkg.name %>.min.js'
	      }
	    }
	  });
	
	  // Load the plugin that provides the "uglify" task.
	  grunt.loadNpmTasks('grunt-contrib-uglify');
	
	  // Default task(s).
	  grunt.registerTask('default', ['uglify']);
	
	};
	
uglifyの動作確認用サンプルプログラムを書く。

	$ mkdir [src,build]
	$ vim ./src/grunt_test
	console.log('hello world');

	var http = require('http');
	
	var server = http.createServer(function(req, res) {
	  res.end("Hello Grunt");
	});
	
	server.listen(8000, function(){
	  console.log('Server started, listening on : 3000');
	});


動かす

	$ gruad
	grunt
	Running "uglify:build" (uglify) task
	File "build/grunt_test.min.js" created.

	Done, without errors.

でけました。


### 設定ファイルが生のjsだと悲しいので、coffeeで書き直す
***

かなりすっきり。
	
	module.exports = (grunt) ->
	  # Project configuration.
	  grunt.initConfig
	    pkg: grunt.file.readJSON('package.json')
	    uglify:
	      options:
	        banner: '/*! <%= pkg.name %> <%= grunt.template.today("yyyy-mm-dd") %> */\n'
	      build:
	        src: 'src/<%= pkg.name %>.js'
	        dest: 'build/<%= pkg.name %>.min.js'
	
	  # Load the plugin
	  grunt.loadNpmTasks 'grunt-contrib-uglify'
	
	  # Default task(s).
	  grunt.registerTask 'default', [
	    'uglify'
	  ]

### その他
***

その他一般的なモジュールについてはyoman使って開発する予定なので取り急ぎここまで。

参考：[昨今のWebアプリケーションのひな形その2 - Grunt](http://d.hatena.ne.jp/naoya/20130504/1367640512)


本当はgrunt-initとか使ってテンプレートかしないといけないのかなぁ。

