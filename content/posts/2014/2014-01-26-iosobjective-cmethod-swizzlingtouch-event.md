+++
date = "2014-01-26T06:09:00+00:00"
draft = false
tags = ["objective-c", "ios", "Method Swizzling", "metaprogramming"]
title = "[ios][objective-c]Method Swizzlingによるtouch event系メソッドの乗っ取りメタプロ"
+++
objective-cには既存クラスのメソッドやプロパティを拡張する事ができる。

そういう黒魔術を使う事が出来るObjective-Cランタイムの幸せ

今回は、touch eventをfoobar クラスで乗っ取ります。


## UIResponderクラスの枠組みを作成

カテゴリ付きUIResponderクラスを作成します。

FOOUIResponder.h

	#import <UIKit/UIKit.h>

	@interface UIResponder(Foo)
	
	@end


FOOUIResponder.m
	
	#import "FOOUIResponder.h"
	#import <objc/runtime.h>
	
	@implementation UIResponder(Foo)
		
	@end


## replaceするtouchBegan:withEventを追加します。

リプレイスされるメソッドを追加

	# replaceされるmethod
	-(void)replacedTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
	{
	    NSLog(@"%@ touchBegin",NSStringFromClass(self.class));
	    [self replacedTouchesBegan:touches withEvent:event];
	}

	# リプレイスをキックするクラスメソッド
	+(void)switchTouchEventMethod
	{
	    [self switchInstanceMethodFrom:@selector(touchesBegan:withEvent:)    To:@selector(replacedTouchesBegan:withEvent:)   ];
	}
	
	# リプレイスメソッド
	+(void)switchInstanceMethodFrom:(SEL)from To:(SEL)to
	{
	    Method fromMethod = class_getInstanceMethod(self,from);
	    Method toMethod   = class_getInstanceMethod(self,to  );
	    method_exchangeImplementations(fromMethod, toMethod);
	}

## 組み込む

AppDelagete.m


	#import "FOOUIResponder.h"
	
	- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
	{
	    
	    [UIResponder switchTouchEventMethod];
	    
	    // Override point for customization after application launch.
	    return YES;
	}
								
