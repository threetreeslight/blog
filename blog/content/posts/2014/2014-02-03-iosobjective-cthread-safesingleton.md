+++
date = "2014-02-03T02:24:37+00:00"
draft = false
tags = ["singleton", "thread safe", "objective-c", "ios"]
title = "[ios][objective-c]thread safeなsingletonの作成"
+++
単純にinstance化するのではなく、dispatch_once_tを利用する事で、thread safeにsingleton化できる。
	
	+(MyClass *)singleton {
	 static dispatch_once_t pred;
	 static MyClass *shared = nil;
	 
	 dispatch_once(&pred, ^{
	  shared = [[MyClass alloc] init];
	 });
	 return shared;
	}

参考：[Singletons: You're doing them wrong](http://cocoasamurai.blogspot.jp/2011/04/singletons-your-doing-them-wrong.html)