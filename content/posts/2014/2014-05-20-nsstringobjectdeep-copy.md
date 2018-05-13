+++
date = "2014-05-20T11:38:23+00:00"
draft = false
tags = ["objective-c", "ios", "nsstring"]
title = "NSStringがobjectなのにdeep copyしてもアドレスは変わらない"
+++
これ超キモいけど、動きとして納得できる部分もある。

immutableなリテラルって中身を変えるような事って出来ないからかな？


## サンプル

Foo Class作ってcopyする場合と、NSString着くってcopyする場合の違いを見る。


Foo.h

	#import <Foundation/Foundation.h>
	
	@interface Foo : NSObject
	
	@property (nonatomic, strong, readwrite) NSString *msg;
	
	- (id)initWithMsg:(NSString *)msg;
	
	@end

Foo.m
	
	#import "Foo.h"
	
	@implementation Foo
	
	- (id)initWithMsg:(NSString *)msg
	{
	    self = [super init];
	    if (self != nil) {
	        self.msg = msg;
	    }
	    return self;
	}
	- (id)copyWithZone:(NSZone *)zone
	{
	    id copiedObject = [[[self class] allocWithZone:zone]
	                            initWithMsg:[NSString stringWithString:self.msg]
	                      ];
	    
	    
	    return copiedObject;
	}
	
	@end
	

ViewController.m

	#import "ViewController.h"
	#import "Foo.h"
	
	@interface ViewController ()
	@property (nonatomic, copy, readwrite) Foo *foo;
	@end
	
	@implementation ViewController
	
	- (void)viewDidLoad
	{
	    [super viewDidLoad];
	    
	    // Fooオブジェクト
	    Foo *localFoo = [[Foo alloc] initWithMsg:@"foo"];
	    NSLog(@"localFoo : %p", localFoo);
	    self.foo = localFoo;
	    NSLog(@"self.foo : %p", self.foo);

	    // NSStringオブジェクト	    
	    NSString *msg = @"foo";
	    NSLog(@"msg : %p", msg);
	    NSString *copiedMsg = [msg copy];
	    NSLog(@"msg : %p", copiedMsg);
	    NSString *stringWithMsg = [NSString stringWithString:msg];
	    NSLog(@"msg : %p", stringWithMsg);
	    
	    NSLog(@"hogehoge");
	    
	}
	
	@end


## LOGを見ると

	2014-05-20 17:55:19.893 Foo[88286:60b] localFoo : 0x8f53fa0
	2014-05-20 17:55:19.898 Foo[88286:60b] self.foo : 0x8e569e0
	2014-05-20 17:55:19.899 Foo[88286:60b] msg : 0x473c
	2014-05-20 17:55:19.900 Foo[88286:60b] msg : 0x473c
	2014-05-20 17:55:19.901 Foo[88286:60b] msg : 0x473c


NSStringのこの動き、キモいけど正しいんだろう