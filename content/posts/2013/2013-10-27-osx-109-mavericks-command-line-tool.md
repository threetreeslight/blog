+++
date = "2013-10-27T07:46:00+00:00"
draft = false
tags = ["command line tools", "mavericks", "osx 10.9", "10.9"]
title = "osx 10.9 Mavericks でcommand line toolをインストールする"
+++
さてさて、早速mavericksにupgradeしてxcodeも5.1にしら、あれ、、、gitも何も動かない、、、


	Gem::Installer::ExtensionBuildError: ERROR: Failed to build gem native extension.
	
	    /System/Library/Frameworks/Ruby.framework/Versions/2.0/usr/bin/ruby extconf.rb
	mkmf.rb can't find header files for ruby at /System/Library/Frameworks/Ruby.framework/Versions/2.0/usr/lib/ruby/include/ruby.h
	
	
	Gem files will remain installed in /opt/boxen/repo/.bundle/ruby/2.0.0/gems/json-1.8.0 for inspection.
	Results logged to /opt/boxen/repo/.bundle/ruby/2.0.0/gems/json-1.8.0/ext/json/ext/generator/gem_make.out


もちろんcommand line tool周りだろうと思ってpropertyを見たら、、、

あれ、、、command line toolが無い、、、

調べると以下の通り。

[command line tools for new 10.9 OSX for ruby gems?](http://stackoverflow.com/questions/17066849/command-line-tools-for-new-10-9-osx-for-ruby-gems)


必要になったタイミングでXcode上のtrigerが発動し、インストールするか問うpopupが出てくるっぽい。

なにそれ、、、どんな嫌がらせ、、、？無理、無理ゲー。耐えられない。

そんなときはterminalから必要に迫らせて、trigerを強制的に発動させる。

    $ xcode-select --install

やっと先に進めそうです。

boxenの設定直そう。
