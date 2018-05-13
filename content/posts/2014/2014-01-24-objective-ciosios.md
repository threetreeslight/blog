+++
date = "2014-01-24T04:23:15+00:00"
draft = false
tags = ["GCD", "thread", "ios", "objective-c", "dipatch", "Timer", "NSTimer", "performSelectorInBackground", "detachNewThreadSelector", "dispatch_get_global_queue"]
title = "[objective-c][ios]iosで非同期もしくは平行処理する方法"
+++
objective-cにて非同期やる方法を調べた結果をまとめます。

## GCDのglobal queueにdispatchして処理する

参考：[awslabs / aws-sdk-ios-samples - Running the S3Uploader Sample](https://github.com/awslabs/aws-sdk-ios-samples/tree/master/S3_Uploader)

こんな感じで、global queueをもってきて、そこにぶち込んで処理する

	- (void)processGrandCentralDispatchUpload:(NSData *)imageData
	{
	    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	    dispatch_async(queue, ^{
	
	        // Upload image data.  Remember to set the content type.
	        S3PutObjectRequest *por = [[[S3PutObjectRequest alloc] initWithKey:PICTURE_NAME
	                                                                  inBucket:[Constants pictureBucket]] autorelease];
	        por.contentType = @"image/jpeg";
	        por.data        = imageData;
	
	        // Put the image data into the specified s3 bucket and object.
	        S3PutObjectResponse *putObjectResponse = [self.s3 putObject:por];
		}
	
	}


## background threadで処理する


参考：[awslabs / aws-sdk-ios-samples - Running the S3Uploader Sample](https://github.com/awslabs/aws-sdk-ios-samples/tree/master/S3_Uploader)

NSObjectのperformSelectorInBackgroundにて、対象の処理をbackgroundで処理させる事が出来る。
	
	- (void)processBackgroundThreadUpload:(NSData *)imageData
	{
	    [self performSelectorInBackground:@selector(processBackgroundThreadUploadInBackground:)
	                           withObject:imageData];
	}

## NSThredによるbackground処理

こんな感じ。

	[NSThread detachNewThreadSelector:@selector(aSelector)　toTarget:aTerget　withObject:anAugument];

NSThredはautoreleasepoolへの処理を書かないといけません。

参考：[NSThread Class Reference](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSThread_Class/Reference/Reference.html)

参考：[ARC のメモリ解放タイミングを調べた](http://qiita.com/amay077/items/95a4139e6f553d8a56a1)


## NSTimerを使ったタイマーにて処理する

一定時間毎に処理を実行したいときはNSTimerを利用します。

インスタンス作ると即発します。

    NSTimer *foobar = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                     target:self
                                                   selector:@selector(foo)
                                                   userInfo:nil
                                                    repeats:YES];
	
	// 状態
	[foobar isValid]
	
	// 無効化（再発火しません）
	[foobar invalidate]
	
	// fire
	[foobar fire]


参考：[NSTimer Class Reference](https://developer.apple.com/library/ios/documentation/cocoa/reference/foundation/Classes/NSTimer_Class/Reference/NSTimer.html#//apple_ref/occ/clm/NSTimer/scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:)



