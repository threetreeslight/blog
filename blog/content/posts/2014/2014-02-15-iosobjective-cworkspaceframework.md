+++
date = "2014-02-15T10:29:00+00:00"
draft = false
tags = ["workspace", "ios", "objcetive-c", "xcode", "framework", "staticlibrary", "duplicate syntax"]
title = "[ios][objective-c]workspaceを使った楽々framework開発"
+++
framework開発をやるのは良いけれど、シミュレーターデバッグするために

1. Buildして
2. Archiveして
3. frameworkをデバッグ用のapp内に移動して
4. デバッグ用appをbuildしてRun

なんてやってたら日が暮れる。それもものすごい勢いで。

まさか世の中こんな方法でやっている訳が無いと思って考えたら、workspaceですね。これだ。

というわけで、frameworkやstatic library開発のためのworkspace環境構築しました。

## まずworkspace

こいつを準備する。

ディレクトリを準備して

	$ mkdir FooWork
	
workspaceを格納

	File > New > Workspace

こんな感じ

	$ ls
	TruthRec.xcworkspace

## gitignoreを修正

xcodeprojの要領と同じです。

	
	# OS X
	.DS_Store
	 
	# Xcode
	*.xcodeproj/*
	!*.xcodeproj/project.pbxproj
	*.xcworkspace/*
	!*.xcworkspace/contents.xcworkspacedata
	build/
	*.pbxuser
	!default.pbxuser
	*.mode1v3
	!default.mode1v3
	*.mode2v3
	!default.mode2v3
	*.perspectivev3
	!default.perspectivev3
	xcuserdata
	*.xccheckout
	profile
	*.moved-aside
	DerivedData
	*.hmap
	*.ipa
	 
	# CocoaPods
	Pods

<https://gist.github.com/ae06710/9017101>

ちなみにgithubのgitignoreはこんな感じ。

<https://github.com/github/gitignore/blob/master/Objective-C.gitignore>


## frameworkとデバッグ用projectを作成

[[ios][objectiv-c]frameworkの作成](http://threetreeslight.com/post/76214786264/ios-objectiv-c-framework)に習ってFoo projectを作ります。

パスはFooWork配下です。

デバッグ用アプリは、singleview appを利用してBar projectという名前で作ります。

これもpathはFooWork配下です。

	$ tree -L 1 ./FooWork
	.
	├── Foo
	├── FooWork.xcworkspace
	└── Bar
	
	3 directories, 0 files


それぞれのディレクトリのgit邪魔なんで殺し、workspace用にgitリポジトリ作ります。

	$ rm -rf ./Foo/.git
	$ rm -rf ./Bar/.git
	$ git init
	$ git add .
	$ git commit "Inital Commi"

## workspaceへ追加

	$ open FooWork.xcworkspace
	
`File > Add Files`よりFoo.xcodeprojとBar.xcodeprojを同列に追加します。

## build setting

### Bar projectへframeworkを追加

Bar projectはFoo frameworkを利用するので、

`Foo > Products > Foo.framework`

をBar projectの

`Build Phases > Link Binary With Library`

に追加します。

### Bar frameworkのSearch pathを変更

* thirdpartyのライブラリを入れとくためにvendorディレクトリへのpath
* buildされたframeworkへのpath

の２つを追加


	$(SRCROOT)/vendor
	$(USER_LIBRARY_DIR)/Developer/....
	

### other linker pathを追加

以下のように

	--all_load -Objc


詳しくはこちら。

[[ios][objective-c] static library(.a)やframeworkにおけるカテゴリ利用における注意点](http://threetreeslight.com/post/76303615487/ios-objective-c-static)


## build

schemaの変更 `cmd + ctrl + ]` して、cmd + R


## その他frameworkで気をつけたい事

**他のライブラリを一緒にbuildしちゃだめ。**

frameworkやstatic libraryに他のframeworkを含めてbuildしないように。

特にAWSなどの他のフレームワークでも使う可能性がある物は極力割けましょう。

２重にロードされる事に成るので、ことごとく

	duplicate Syntax

に苦しめられます。

**デバッグ用アプリ内のframework参照先に包むようにしましょう**

`$(SRCROOT)/vendor` にでもぶち込んでいく感じ！



ふぅ。