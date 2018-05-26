+++
date = "2014-02-04T08:12:16+00:00"
draft = false
tags = ["class", "method", "objective-c", "objc", "ios", "respondsToSelector"]
title = "[ios][objective-c]iosの後方互換のためのmethodとclassの存在チェック"
+++
クラスが無かったり合ったり、methodが無かったり合ったり辛い。

## classの存在是非

	Class foo = NSClassFromString(@"Foo");
	if (foobar != nil) {
		// Available Foo Class
	} else {
		// Unavailable Foo Class
	}

## class methodの存在是非

	if ([Foo respondsToSelector:@selector(bar:)]) {
		// Available Foo class's bar class method
	} else {
		// Unavailable Foo class's bar class method
	}

## instance methodの存在是非

	
	Foo *foo = [[Foo alloc] init];
	if ([foo respondsToSelector:@selector(bar:)]) {
		// Available Foo class's bar instance method
	} else {
		// Unavailable Foo class's bar instance method
	}


## classからinstance methodの存在是非

	if ([Foo instancesRespondToSelector:@selector(bar:)]) {
		// Available Foo class's bar instance method
	} else {
		// Unavailable Foo class's bar instance method
	}