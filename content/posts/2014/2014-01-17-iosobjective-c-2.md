+++
date = "2014-01-17T02:36:00+00:00"
draft = false
tags = ["ios", "capture", "objective-c"]
title = "[iOS][Objective-C]画面をキャプチャする方法"
+++
スクリーンキャプチャを取得したい場合の処理。


## 処理の流れ

1. `UIGraphicsBeginImageContex`で画像をバッファ開始
1. `[app.keyWindow.layer renderInContext:UIGraphicsGetCurrentContext()];`にて画像をレンダリング
1. `UIGraphicsGetImageFromCurrentImageContext();`にてバッファした画像をUIImageに格納
1. `UIGraphicsEndImageContext();`にてバッファ終了。このタイミングでバッファが破棄される。
1. とりあえず`UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil);`に画像を保存

## sampleプロジェクトの準備

とりあえずMaster-detailでいいかな？

## captureクラス

Capture.h

	//
	//  Capture.h
	//
	
	#import <Foundation/Foundation.h>
	
	// use for renderInContext:UIGraphicsGetCurrentContext()
	#import <QuartzCore/QuartzCore.h>
	
	@interface Capture : NSObject
	
	- (void)capture;
	// - (void)captureBy;
	
	@end


Capture.m
	
	#import "Capture.h"
	
	@implementation Capture
	
	- (void) capture
	{
	    NSLog(@"Capturing..........");
	    
	    // begin of generate image
	    CGRect rect = [[UIScreen mainScreen] bounds];
	    BOOL opaque = NO;
	    CGFloat scale = 1.0f;
	    UIGraphicsBeginImageContextWithOptions(rect.size, opaque, scale);
	    
	    // render current window
	    UIApplication *app = [UIApplication sharedApplication];
	    [app.keyWindow.layer renderInContext:UIGraphicsGetCurrentContext()];
	    
	    // get current image
	    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
	    
	    // end of generate image
	    UIGraphicsEndImageContext();
	    
	    // store image to album	    
	    UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil);
	}
	
	@end
	

## MasterViewControllerに組み込む

insertしたときにでもcaptureするよう実装

MasterViewController.m


	#import "Capture.h"

	@interface MasterViewController () {
		...
	    Capture *cap;
	}
	@end

	@implementation MasterViewController

	- (void)viewDidLoad
	{
	    [super viewDidLoad];
		// Do any additional setup after loading the view, typically from a nib.

		...
		
	    // capture initialize
	    cap = [[Capture alloc] init];
	}
	
	- (void)insertNewObject:(id)sender
	{
		...
			    
	    // capture
	    [cap capture];
	}

## P.S.

なお、ステータスバーとかって個人情報になるので、captureしない方が良いんじゃないかな？
