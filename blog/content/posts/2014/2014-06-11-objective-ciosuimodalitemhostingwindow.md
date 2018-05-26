+++
date = "2014-06-11T03:38:00+00:00"
draft = false
tags = ["objc", "objective-c", "ios", "_UIModalItemHostingWindow", "UIWindow", "keyWindow"]
title = "[Objective-c][ios]_UIModalItemHostingWindowから何時解放されるのか"
+++
swift盛んな今も、頑張ってobjective-cやります。

UIAlertView表示時のkeywindowは、一時的に_UIModalItemHostingWindowとなり既存のwindowがkeyWindowから外れてしまいます。

その_UIModalItemHostingWindowから何時解放されるのかを、前に調べた [[Objective-c][iOS]UIAlertView表示時におけるUIWindowの挙動](http://threetreeslight.com/post/82567798020/objective-c-ios-uialertview-uiwindow)に引き続き、をもう少し調べました。

## 仕込み

singleViewApplicationをサンプルで作ります。

AppDelegate上には、以下のように

- viewDidLoadでalertを表示
- viewDidLoad, viewWillApper, viewDidApperそれぞれにおけるkeyWindowとwindowsをロギング

<script src="https://gist.github.com/ae06710/fe42d3ab67e1598a5a56.js"></script>


## 結果
	

![](https://31.media.tumblr.com/7d46988a859594c58d50e4b7d380bcee/tumblr_inline_n6zjcvhtTK1r11648.png)
	
	viewDidLoad ------------------------------------------------
	keyWindow: <_UIModalItemHostingWindow: 0x8f4a000; frame = (0 0; 320 568); gestureRecognizers = <NSArray: 0x8f4a500>; layer = <UIWindowLayer: 0x8f4a180>>
	windows : <_UIModalItemHostingWindow: 0x8f4a000; frame = (0 0; 320 568); gestureRecognizers = <NSArray: 0x8f4a500>; layer = <UIWindowLayer: 0x8f4a180>>
	
	viewWillApper 	------------------------------------------------
	keyWindow: <_UIModalItemHostingWindow: 0x8f4a000; frame = (0 0; 320 568); gestureRecognizers = <NSArray: 0x8f4a500>; layer = <UIWindowLayer: 0x8f4a180>>
	windows : <_UIModalItemHostingWindow: 0x8f4a000; frame = (0 0; 320 568); gestureRecognizers = <NSArray: 0x8f4a500>; layer = <UIWindowLayer: 0x8f4a180>>
	
	viewDidApper ------------------------------------------------
	keyWindow: <UIWindow: 0x8f369a0; frame = (0 0; 320 568); autoresize = W+H; gestureRecognizers = <NSArray: 0x8f37a60>; layer = <UIWindowLayer: 0x8f36e10>>
	windows : <UIWindow: 0x8f369a0; frame = (0 0; 320 568); autoresize = W+H; gestureRecognizers = <NSArray: 0x8f37a60>; layer = <UIWindowLayer: 0x8f36e10>>

上記のように、解放されるのは描写完了時ですね。

同様にviewDidApper時にAlertViewをshowしたら、そのタイミングではUIAlertViewの描写は完了していないので、_UIModalItemHostingWindowがkeyWindowに入れ替わります。