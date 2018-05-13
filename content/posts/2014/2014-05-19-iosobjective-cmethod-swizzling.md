+++
date = "2014-05-19T10:28:00+00:00"
draft = false
tags = ["ios", "objective-c", "runtime", "swizzling", "metaprogramming"]
title = "[iOS][objective-c]method swizzlingの実行タイミングについて"
+++
method swizzlingの実行タイミングはシビアだなー。

特に既存クラスを拡張し、iOSのオブジェクトのライフサイクルに関わる場合など、実行タイミングを任意で行うと、実行メソッドをランタイムが決定する際に怒られる。

## UIViewControllerの`viewWillApper:`をswizzlingする例


UIViewController+Foo.h

	#import <UIKit/UIKit.h>
	
	@interface UIViewController (Foo)
	
	+ (void)swizzlingMethodViewWillApper;
	
	@end
	

UIViewController+Foo.m

	#import "UIViewController+RPRIS.h"	
	#import <objc/runtime.h>
	
	@implementation UIViewController (Foo)
	
	+ (void)swizzlingMethodViewWillApper
	{
	    Method originalMethod = class_getInstanceMethod(self, viewWillApper:);
	    Method swizzledMethod   = class_getInstanceMethod(self, foo_viewWillApper:);
	    method_exchangeImplementations(originalMethod, swizzledMethod);
	}
	
	- (void)foo_viewWillAppear:(BOOL)animated
	{
	    [self foo_viewWillAppear:animated];
	    NSLog(@"swizzled viewWillApper Yeah!!");
	}
		
	@end


AppDelegate.m

	#import "AppDelegate.h"
	#import "UIViewController+Foo.h"

	@implementation AppDelegate
	
	- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
	{
	    [UIViewController swizzlingMethodViewWillApper]	 
	    return YES;
	}
								
すると、そんなの無いって怒られてしまう。

	FooSample`boolParamHandler at NRMethodProfiler.m:772:
	0x1000b30d9:  pushq  %rbp
	0x1000b30da:  movq   %rsp, %rbp
	0x1000b30dd:  pushq  %r15
	0x1000b30df:  pushq  %r14
	0x1000b30e1:  pushq  %rbx
	0x1000b30e2:  pushq  %rax
	0x1000b30e3:  movl   %ecx, %r15d
	0x1000b30e6:  movq   %rsi, %r14
	0x1000b30e9:  movq   %rdi, %rbx
	0x1000b30ec:  movb   $0x0, -0x19(%rbp)
	0x1000b30f0:  movb   $0x0, -0x1a(%rbp)
	0x1000b30f4:  leaq   -0x19(%rbp), %rcx
	0x1000b30f8:  leaq   -0x1a(%rbp), %r8
	0x1000b30fc:  callq  0x1000b2a9f               ; beginMethod at NRMethodProfiler.m:788
	0x1000b3101:  movzbl %r15b, %edx
	0x1000b3105:  movq   %rbx, %rdi
	0x1000b3108:  movq   %r14, %rsi
	0x1000b310b:  callq  *%rax
	0x1000b310d:  movzbl -0x1a(%rbp), %ecx
	
とはいえ、mail関数に入れるとかは圧倒的にお行儀が悪い。


## じゃぁ初期化タイミングだよね

初期かタイミングという事に成ると、intializeかloadが出てくる。

	+ (void)load

ランタイムに追加された全てのクラスとカテゴリで、それぞれれライブラリロード時に１度ずつ呼びされる。

実行順序も、カテゴリが補完するクラスよりも後にカテゴリのloadが実行される。

	+ (void)initialize

全てのクラスでクラスが使われる前に一度だけ遅延呼び出しで呼び出される。当然、クラス単位なのでoverride可能である。


上記をふまえるとloadが適切だと分かる。

## なので

以下のようにloadタイミングで実行する事にすれば良い


	#import <UIKit/UIKit.h>
	
	@interface UIViewController (Foo)
	
	+ (void)load;
	
	@end
	

UIViewController+Foo.m

	#import "UIViewController+RPRIS.h"	
	#import <objc/runtime.h>
	
	@implementation UIViewController (Foo)
	
	+ (void)load
	{
	    Method originalMethod = class_getInstanceMethod(self, viewWillApper:);
	    Method swizzledMethod   = class_getInstanceMethod(self, foo_viewWillApper:);
	    method_exchangeImplementations(originalMethod, swizzledMethod);
	}
	
	- (void)foo_viewWillAppear:(BOOL)animated
	{
	    [self foo_viewWillAppear:animated];
	    NSLog(@"swizzled viewWillApper Yeah!!");
	}
		
	@end

AppDelegate.m

	#import "AppDelegate.h"
	#import "UIViewController+Foo.h"

	@implementation AppDelegate
	
	- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
	{ 
	    return YES;
	}
	
## 参考

* [Method Swizzling - 
Written by Mattt Thompson](http://nshipster.com/method-swizzling/)
