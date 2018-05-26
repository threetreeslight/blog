+++
date = "2014-01-31T15:22:25+00:00"
draft = false
tags = ["Timer", "NSTimer", "CADisplayLink", "objective-c", "ios"]
title = "[ios][objective-c]Timer系クラス"
+++
調べてたら２種類合った。泣きたい。

## CADisplayLink

[CADisplayLink Class Reference](https://developer.apple.com/library/ios/documentation/QuartzCore/Reference/CADisplayLink_ClassRef/Reference/Reference.html)

Displayの描写にシンクロさせるタイマー機能

その際のframe rateはfarameIntervalを設定する事で変更する事が出来る。


> A CADisplayLink object is a timer object that allows your application to synchronize its drawing to the refresh rate of the display.
> 
> Your application creates a new display link, providing a target object and a selector to be called when the screen is updated. Next, your application adds the display link to a run loop.
	
	// Creating Instances
	+ displayLinkWithTarget:selector:
	
	// Scheduling the Display Link to Send Notifications
	– addToRunLoop:forMode:
	– removeFromRunLoop:forMode:
	– invalidate
	
	// Configuring the Display Link
	   duration  property
	   frameInterval  property
	   paused  property
	   timestamp  property
  

## NSTimer

[NSTimer Class Reference](https://developer.apple.com/library/ios/documentation/cocoa/reference/foundation/Classes/NSTimer_Class/Reference/NSTimer.html#//apple_ref/occ/clm/NSTimer/scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:)

一定時間毎に処理を実行したいときはNSTimerを利用。インスタンス作ると即発します。

> You use the NSTimer class to create timer objects or, more simply, timers. A timer waits until a certain time interval has elapsed and then fires, sending a specified message to a target object. For example, you could create an NSTimer object that sends a message to a window, telling it to update itself after a certain time interval.

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


