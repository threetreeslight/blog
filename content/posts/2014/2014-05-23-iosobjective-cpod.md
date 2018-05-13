+++
date = "2014-05-23T09:12:00+00:00"
draft = false
tags = ["pod", "ios", "objective-c", "cocoapods"]
title = "[ios][objective-c]podを作る"
+++
配布するSDKの導入が容易になる様、cocoapodsで配布しようと思います。

[cocoapods](http://cocoapods.org/)

## require

* ruby


## 下ごしらえ


まずpodsいれる

	$ gem install cocoapods

それでもってひな形を作る

	$ pod lib create Foo

これでディレクトリが出来る
	
	├── Assets
	├── CHANGELOG.md
	├── Classes
	    └── ios
	    └── osx
	├── Example
	    └── Podfile
	├── LICENSE
	├── README.md
	├── Rakefile
	└── NAME.podspec
	
更新者のpodは行ってない場合もふまえbundlerでcocoapods入れるようにします。

	$ bundler init
	$ vim Gemfile
	gem 'cocoapods'
	
	$ bundle
	

reference

* [Making a CocoaPod](http://guides.cocoapods.org/making/making-a-cocoapod.html)	

	
## podspecを作る

	$ pod spec create Foo
	$ vim ./Foo.podspec

よしなに [Podspec Syntax Reference](http://guides.cocoapods.org/syntax/podspec.html#specification)


localのspecを対象にテストを通す

	$ pod lib link
	-> Foo
	...
	
	Foo passed validation.

おkおk。pushします

	$ git init
	$ git add -A
	$ git commit -am "Initial commit"
	$ git tag -a 0.0.1 -m "release 0.0.1"

## 試す

singole pageのprojectを作成

	$ cd Project_home
	$ pod init
	$ vim ./Podfile
	pod 'Foo', git: 'https://github.com/user_name/Foo.git

	$ pod install
	
これでworkstationに追加されていればと上手く行っている！

## Podに登録（これ古いやり方でしたごめんなさい）


まずは、[CocoaPods/Spec](https://github.com/CocoaPods/Specs)をfork

[https://github.com/CocoaPods/Specs](https://github.com/CocoaPods/Specs)


既に`pod setup`している場合は以下のディレクトリに存在します。

	$ cd ~/.cocoapods/master/


ここにremote先繋ぐと楽です。

	$ git remote add foo git@github.com:Foo/Specs.git

specを追加してコミットし

	$ git checkout -b foo
	$ mkdir Specs/Foo
	$ cp Foo.podspec ./Specs/Foo
	
pull requestを作る。

過去のものを参考にされると楽です。


[https://github.com/CocoaPods/Specs/pulls](https://github.com/CocoaPods/Specs/pulls)

これで後は待つべし


## Pods の公開方法変わったっぽい

[Getting Setup with Trunk](http://guides.cocoapods.org/making/getting-setup-with-trunk.html)

登録

    $ pod trunk register orta@cocoapods.org 'Orta Therox' --description='macbook air'

テスト

    $ pod spec lint

登録

    $ pod trunk push ./Foo.podspec