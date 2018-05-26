+++
date = "2014-01-26T07:45:13+00:00"
draft = false
tags = ["objective-c", "ios", "metaprogramming"]
title = "[iOS][Objective-c]UIWindow(既存クラス)にインスタンス変数を追加"
+++
既存クラスにインスタンス変数を追加するのは、カテゴリを利用する事で実現できます。

カテゴリの考え方と、objective-cランタイムの考え方素敵ですね。rubyの方が好きですが。

特にUIWindowクラスは必ずios appはUIを作成するために持っている基底クラスでもあるので（確かそうだったはず）、このクラスを拡張する事で特殊なInterfaceを１枚かぶせておく事も可能です。

それ以上に使い回したいフックとかも最適。

## UIWindowクラスの枠組みを作成

カテゴリ付きUIWIndowクラスを作成します。

FOOUIWindow.h

	# import <UIKit/UIKit.h>
	
	@interface UIWindow(Foo)
	
	@end


FOOUIWindow.m
	
	#import "FOOUIWindow.h"
	
	@implementation UIWindow(Foo)
		
	@end

## インスタンス変数の追加方法


FOOUIWindow.h

	# import <UIKit/UIKit.h>
	
	@interface UIWindow(Foo)
	@property NSString *bar;
	@end


FOOUIWindow.m
	
	#import "FOOUIWindow.h"
	
	@implementation UIWindow(Foo)
	@dynamic bar;
		
	@end

@dyanmicによって、動的に変数を追加します。

ただ、動的な変数追加の場合、コンパイル時に生成されるアクセサが生成されません。

そのため、getter, setterを用意する必要が有ります。
	
	- (void)setBar:(NSString *)bar
	{
	    objc_setAssociatedObject(self, @"bar", bar, OBJC_ASSOCIATION_RETAIN);
	}
	
	- (NSString *)bar
	{
	    return objc_getAssociatedObject(self, @"bar");
	}
	
## 組み込む

AppDelagete.m

	#import "FOOUIWindow.h"
	
	@implementation AppDelegate
	
	- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
	{
	    self.window.bar = @"aaa";
	    NSLog(@"%@", self.window.bar);

	    // Override point for customization after application launch.
	    return YES;
	}
	
	...
	
	@end

これで動かして見ると、barにアクセスできている事が確認できます。

	
## 参考

* [【Objective-C,iOS】カテゴリでプロパティを追加する方法](http://f-retu.hatenablog.com/entry/2012/11/28/010114)
* [Objective-Cでカテゴリにプロパティを持たせる](http://hikaruworld.bitbucket.org/blog/html/2012/11/29/objective_c_category_add_property.html)
