+++
date = "2014-01-18T06:51:52+00:00"
draft = false
tags = ["iOS", "cocoapods", "cocoa", "objective-c"]
title = "[iOS][Objective-C]cocoapodsを使ったlibraryの管理"
+++
さてさて、iOSのお作法やobjective-cの習わしなど慣れてきて、やっとこさガシガシ書き始めており、やっとAWS SDK for iOSを使って遊び始めたい年頃に成ってきました。

実際にフレームワークを入れて見ると、とりあえず置いてframeworkとしてaddするとか、なんというか、あーこれチームで開発していると漏れるだろうなーという感じでした。

で、リポジトリに包むにしても、何処に置くのがベストプラクティスなのかとか全然分からないしどうなんだろう？と悩み始める訳です。

むしろbundlerやCPANみたいな仕組み無いのかな？と楽したくも成ります。

で、探していると、ありました。

[cocoapods](http://cocoapods.org/)
---

> Cocoa 向け外部ライブラリの集積所。Bundler 的なフロントエンドを使って依存関係含め、インストール周りを管理できます。素敵！ 自分が初めて Cocoapods について耳にしたのは 2011 年ころで、確かそのぐらいにリリースされたものだと記憶しています。当初は登録されているライブラリも多くなかったのでまだまだこれからという感じでしたが、結構な時間が経ってきてだいぶその辺も充実してきました。

参考：[RubyMotion で AWS iOS SDK を使う (もしくは Objective-C ライブラリの使い方、あるいはドラクエ10について)](http://d.hatena.ne.jp/naoya/20121221/1356079672)


naoyaさんすげー。これやっ！！！


require
---

* ruby
* bundler gem (あれば)

install cocoapods
---

	$ cd ${project_home}
	$ bundle init
	$ vim Gemfile
	source "https://rubygems.org"

	gem "cocoapods"

	$ bundle install
	
これでインストールは完了。

install libraries
---

今回はAWS SDK for iOSを利用する事にします。

	$ vim Podfile
  	platform :ios

	pod 'AWSiOSSDK', '~> 1.7.1'
	
	$ pod install
	$ bundle exec pod install
	Setting up CocoaPods master repo
	
	
	Setup completed (read-only access)
	Analyzing dependencies
	Downloading dependencies
	Installing AWSiOSSDK (1.7.1)
	Generating Pods project
	Integrating client project
	
	[!] From now on use `sample.xcworkspace`.
	[deprecated] I18n.enforce_available_locales will default to true in the future. If you really want to skip validation of your locale you can set I18n.enforce_available_locales = false to avoid this message.

ok!入った！

install後の状態
---

インストール後のディレクトリを見て見ると。

	$ ls -l | awk '{ print $9 }'
	Gemfile
	Gemfile.lock
	Podfile
	Podfile.lock
	Pods
	
と、バージョン固定用のPodfile.lockとlibraryを格納しているPodsディレクトリが出来ます。

また、Xcodeのプロジェクトを開いてみると、library周りにlibPodsが追加されています。

	Linked Frameworks and Libraries

	libPods.a
	
	
このlibPodsがインストールしたlibraryの管理をしています。


よし後は組み込むだけ
---


こんな感じで終わり。

	#import <AWSS3/AWSS3.h>


うん。便利だねー！


