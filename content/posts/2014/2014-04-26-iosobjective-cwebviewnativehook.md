+++
date = "2014-04-26T06:35:00+00:00"
draft = false
tags = ["webView", "ios", "objective-c", "objc"]
title = "[iOS][objective-c]webViewからの操作をnativeでhookする"
+++
探ったら奇麗なやり方があったので、メモ。

## webViewつくる

	CGRect bounds = [UIScreen mainScreen].bounds;
	UIWebView *wv = [[UIWebView alloc] initWithFrame:bounds];
	wv.scalesPageToFit = NO;
	wv.tag = kWindowTag;
	wv.delegate = self;
	
	NSURL *url = [NSURL URLWithString:@"foobar" ];
	NSURLRequest *urlReq = [NSURLRequest requestWithURL:url];
	[wv loadRequest:urlReq];
	
	UIWindow *window = [UIApplication sharedApplication].keyWindow;
	[window addSubview:wv];

## UIWindowのTagをセット

	static NSInteger const kWindowTag = 9999999;

## webViewのdelegateでload requestをhook

独自に定義した`native://`プロトコルのhyper referenceをhookしてあげるよう定義

	-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
	                                                navigationType:(UIWebViewNavigationType)navigationType
	{
	    // hook when scheme is 'native'
	    if ([ request.URL.scheme isEqualToString:@"native" ]) {
	        [ self invokeNativeMethod: request ];
	        
	        return NO;
	    }
	    return YES;
	}

## `native://` hookのrequest処理をまとめる

	-(void)invokeNativeMethod: (NSURLRequest *)request
	{
	    if ([request.URL.host isEqualToString:@"closeWebView"]) {
	        [self closeWebView];
	    }
	}

## closeWebViewのときは、webView閉じさせるとか

	-(void)closeWebView
	{
	    UIWindow *window = [UIApplication sharedApplication].keyWindow;
	    UIView *viewToRemove = [window viewWithTag:kWindowTag]; 
	    [viewToRemove removeFromSuperview];
	}

	
