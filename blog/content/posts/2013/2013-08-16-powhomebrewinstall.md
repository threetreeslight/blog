+++
date = "2013-08-16T02:41:03+00:00"
draft = false
tags = ["pow", "rails", "rack"]
title = "powをhomebrewでinstall"
+++
thin使う理由も無いし、foreman経由でunicorn叩くし、ローカルどうしようかな？ということで前々から使おうと思ってたpowを導入。

[pow - Knock Out Rails & Rack Apps Like a Superhero.](http://pow.cx/)

* 簡素なrackサーバ
* 複数のアプリケーションを同時起動するとき、localhostで接続する必要がない幸せ。
* アプリケーションまたいだテスト楽
* ちょっと工夫すると、ネットワーク内のデバイスからアクセスできる。

## boxen経由で入れる
***

[boxen/puppet-pow](https://github.com/boxen/puppet-pow)

	$ cd /opt/boxen/repo
	$ vim ./Puppetfile
	github 'pow', '1.0.0'

	$ vim ./modules/people/manifest/hogehoge.pp
	include pow
	
	$ script/boxne --no-fde
	
## powの初期化
***

	$ brew info pow
	pow: stable 0.4.1
	http://pow.cx/
	/opt/boxen/homebrew/Cellar/pow/0.4.1 (726 files, 12M) *
	  Built from source
	From: https://github.com/mxcl/homebrew/commits/master/Library/Formula/pow.rb
	==> Dependencies
	Required: node
	==> Caveats
	Sets up firewall rules to forward port 80 to Pow:
	  sudo pow --install-system
	
	Installs launchd agent to start on login:
	  pow --install-local
	
	Enables both launchd agents:
	  sudo launchctl load -w /Library/LaunchDaemons/cx.pow.firewall.plist
	  launchctl load -w ~/Library/LaunchAgents/cx.pow.powd.plist
	
なるほど。言われた通りにやります。

	$ sudo pow --install-system
	$ pow --install-local
	$ sudo launchctl load -w /Library/LaunchDaemons/cx.pow.firewall.plist
	$ launchctl load -w ~/Library/LaunchAgents/cx.pow.powd.plist
	

## 環境設定
***

環境変数ぶっ込んで、.powディレクトリ作成

	$ eval $(pow --print-config)
	$ mkdir -p "`echo $POW_HOST_ROOT`" 
	$ ln -s "`echo $POW_HOST_ROOT`" ~/.pow

## アプリ設定
***
	
	$ cd ~/.pow
	$ ln -s /application_directory

	$ oepn http://application_directory_name.dev


で、動かない。

	Bundler::RubyVersionMismatch: Your Ruby version is 1.8.7, but your Gemfile specified 1.9.3
	/Library/Ruby/Gems/1.8/gems/bundler-1.3.5/lib/bundler/definition.rb:361:in `validate_ruby!'
	/Library/Ruby/Gems/1.8/gems/bundler-1.3.5/lib/bundler.rb:116:in `setup'
	/Library/Ruby/Gems/1.8/gems/bundler-1.3.5/lib/bundler/setup.rb:17
	/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/1.8/rubygems/custom_require.rb:36:in `gem_original_require'
	/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/1.8/rubygems/custom_require.rb:36:in `require'
	Show 11 more lines


powrcでrbenvを読み込ませるようにする

	$ vim ${Application_directory}/.powrc
	## rbenv
	#
	if [[ -f /opt/boxen/env.sh ]] ; then
	  source /opt/boxen/env.sh
	fi
	if [[ -s $BOXEN_HOME/rbenv/bin ]] ; then
	  rbenv local 1.9.3-p448
	  echo "ruby is "`rbenv version | sed -e 's/ .*//'`
	fi

## あとは少し自動かしたり
***

	$ vim gemfile
	gem 'guard-pow'
	gem 'powder'
	
	$ bundle install
	$ guard init pow

## 参考
***

* [Pow User's Manual](http://pow.cx/manual.html#section_2.3.1)
* [pow + rbenvで手軽なRack環境構築](http://qiita.com/d6rkaiz/items/0f0b15b800fcd8a742f9)