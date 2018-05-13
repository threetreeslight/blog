+++
date = "2014-04-14T08:31:00+00:00"
draft = false
tags = ["ios", "objc", "objective-c"]
title = "[objective-c][iOS]applicationDidEnterBackgroundが２回呼ばれる"
+++
掲題の通り、サンプルアプリでapplicationDidEnterBackgroundが２回呼ばれる事象が起こりました。


んん！？

## 調べる


[UIApplicationDelegate Protocol Reference](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIApplicationDelegate_Protocol/Reference/Reference.html#//apple_ref/occ/intfm/UIApplicationDelegate/applicationDidEnterBackground:)

> In iOS 4.0 and later, this method is called instead of the applicationWillTerminate: method when the user quits an app that supports background execution. You should use this method to release shared resources, save user data, invalidate timers, and store enough app state information to restore your app to its current state in case it is terminated later. You should also disable updates to your app’s user interface and avoid using some types of shared system resources (such as the user’s contacts database). It is also imperative that you avoid using OpenGL ES in the background.
> 
> Your implementation of this method has approximately five seconds to perform any tasks and return. If you need additional time to perform any final tasks, you can request additional execution time from the system by calling beginBackgroundTaskWithExpirationHandler:. In practice, you should return from applicationDidEnterBackground: as quickly as possible. If the method does not return before time runs out your app is terminated and purged from memory.
> 
> You should perform any tasks relating to adjusting your user interface before this method exits but other tasks (such as saving state) should be moved to a concurrent dispatch queue or secondary thread as needed. Because it's likely any background tasks you start in applicationDidEnterBackground: will not run until after that method exits, you should request additional background execution time before starting those tasks. In other words, first call beginBackgroundTaskWithExpirationHandler: and then run the task on a dispatch queue or secondary thread.
> 
> The app also posts a UIApplicationDidEnterBackgroundNotification notification around the same time it calls this method to give interested objects a chance to respond to the transition.
> 
> For more information about how to transition gracefully to the background, and for information about how to start background tasks at quit time, see iOS App Programming Guide.

うーん。原因分からん。

## 解決策としては

処理をしたいオブジェクトのstate管理をして処理を制御するぐらいしか思いつかない。


## 参考

* [stackoverflow - applicationDidEnterBackground is called twice on iOS7](http://stackoverflow.com/questions/20535382/applicationdidenterbackground-is-called-twice-on-ios7)
* [stackoverflow - Is applicationDidEnterBackground ALWAYS called before applicationWillTerminate?](http://stackoverflow.com/questions/13727826/is-applicationdidenterbackground-always-called-before-applicationwillterminate)
* [iOSアプリの状態遷移について](http://takesita.seesaa.net/archives/201211-1.html)