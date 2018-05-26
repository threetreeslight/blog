+++
date = "2014-02-11T06:19:17+00:00"
draft = false
tags = ["objective-c", "ObjC", "ios", "static library", "framework", ".a"]
title = "[ios][objective-c] static library(.a)やframeworkにおけるカテゴリ利用における注意点"
+++
カテゴリ使ったframeworkを作って、さて組み込もう！とすると怒られる。

こんな感じ（参考のエラー引っ張ってます）
	
	[49296:207] -[NSCFString extString]: unrecognized selector sent to instance 0x3044
	[49296:207] *** Terminating app due to uncaught exception 'NSInvalidArgumentException',
	 reason: '-[NSCFString extString]: unrecognized selector sent to instance 0x3044'
	*** Call stack at first throw:


## 原因

どうやら

> カテゴリが定義されている Static Library を使う場合、リンカフラグに "-ObjC" と "all_load" を設定する必要がある。リンカフラグを設定しない場合 "selector not recognized" 例外が発生しクラッシュする。

との事。

 Objective-Cランタイムによる動的なselector確定とframeworkやStatic Libraryによる実装の問題の模様。
 
 
 official : [Building Objective-C static libraries with categories](https://developer.apple.com/library/mac/qa/qa1490/_index.html)

## 解決策

project > BuilSetting > Linking > Other Linker Flag

にて以下の二つのLinker Flagを付ける

	-all_load
	-Objc
	

これでコンパイルすれば、objcのランタイムによるメソッド確定の検索範囲に含まれるようになります。

（意味合ってるかな？）


## 参考

* [[Mac][iOS] Static Library (7) カテゴリを使う場合の注意点 "-ObjC" と "-all_load"](http://cocoadays.blogspot.jp/2010/11/ios-static-library-7-objc-allload.html)
* [ビルド設定の "Other Linker Flags" に "-ObjC" を設定する意味Add Star](http://d.hatena.ne.jp/shu223/20110426/1304694650)