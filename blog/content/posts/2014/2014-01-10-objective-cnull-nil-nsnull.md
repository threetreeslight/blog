+++
date = "2014-01-10T04:07:00+00:00"
draft = false
tags = ["objective-c", "NSNull", "nil", "NULL"]
title = "objective-cにはNULL, nil, NSNullがあるのね。"
+++
びっくりした。メソッドの引数がNULLだったり、nilだったりでてきて焦った。

## NULL

私たちが良く知るCのNULL。ヌルポだしてたあいつです。

引数がポインタの場合コイツですね。

## nil

>nilはnullオブジェクトを表し、オブジェクトが未初期化である ことや、クリアされた状態であることを表わすのに使用されます(また、Nilはnullクラス オブジェクトを表します)。他の言語と異なり、Objective-Cでは、nilにメッセージを 送信することが許されています。そのときの返却値は、返却値の型がid型のメッセージ の場合はnilを返し、intのような単純なC言語の型の場合は0を返します。structの ような複合型の場合の返却値は未定義です。nilとNilはともに(id)0と 定義されています。

nilはオブジェクト型に合わせて適切なNULL値を返してくれるオブジェクト。

引数がオブジェクトの場合、コイツですね。


## NSNull

NSNullはクラスであり、Nullを表すオブジェクト。

オブジェクトのためポインタが存在します。

NS系のarrayやdictionary(hash)にメモリ領域が確保されていない何も示さないNULLは利用できません。

そういうときにはコヤツを使います。

じゃぁMutable系でcapacityメソッド指定してinitializeした領域には何が入っているのか？

これはnullじゃなかったはず。何が入っているか分からない物が入っているはずです。だったかな？


## 比較表

一部[こちら](http://blog.objc.jp/?p=1433)より拝借させて頂きました。

	NSLog(@"%u",NULL == nil);
	// 1: nilがNULLを返します。
	
	NSLog(@"%u",NULL == [NSNull null]);
	// 0: NSNullのポインタが参照されているので違います。
	
	NSLog(@"%u",nil == [NSNull null]);
	// 0: nilはNULLを返し、NSNullのポインタが参照されているので違います。
	
	NSLog(@"%u",[[NSNull null] isEqual:nil]);
	// 0: isEqualはもちろん違う。
	
	NSLog(@"%u",[[NSNull null] isEqual:NULL]);
	// 0: isEqualはもちろん違う。

## 参考

* [nilとNSNullの違いとNSNullをnilのように振る舞うようにする](http://qiita.com/yimajo/items/c9338a715016e7a812b1)
* [Objective-CでのNullの扱いについて調べてみた](http://blog.objc.jp/?p=1433)
* [Objective-CのnilとNULLの違いって何？](http://akisute.com/2009/05/objective-cnilnull.html)
* [nilとは何ですか](http://www.libjingu.jp/trans/clocFAQ-j.html#objects-nil)

あってる？

## P.S.

懐かしやC。

７年前ぐらいの記憶をたぐり寄せねば。