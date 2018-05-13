+++
date = "2014-04-27T05:59:31+00:00"
draft = false
tags = ["objective-c", "objc", "ios"]
title = "[Objective-c][iOS]JsonレスポンスからInteger値を取り出す方法"
+++
NSIntegerはプリミティブはオブジェクトではないので、NSDictionaryとの相性が悪い。そのため、`__NSCFNumber`型にparseされています。

そこからNSIngeterを引っ張りだすためには、

	(NSInteger)[jsonResponse[@"id"] intValue]
	
	
こんな感じ。

詳しくは、BOOL値についての記事を参照。

[[Objective-c][iOS]Jsonレスポンスからbool値を取り出す方法](http://threetreeslight.com/post/79966068804/objective-c-ios-json-bool)
