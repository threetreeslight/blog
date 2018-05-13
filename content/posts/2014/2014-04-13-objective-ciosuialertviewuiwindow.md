+++
date = "2014-04-13T10:25:53+00:00"
draft = false
tags = ["UIWindow", "Objective-c", "objc"]
title = "[Objective-c][iOS]UIAlertView表示時におけるUIWindowの挙動"
+++
UIAlertView表示時に置ける背面のlayerの表示ってどうなっているんでしょうね？

うーん。とりあえず情報収集

## UIWindowの状態

UIWindowのsendEvnetをhookしてUIWindowを獲得して見る。

UIWindowにカテゴリ追加してsendEventをmethodswizzlingする。
その先で以下のコマンドを仕込みます。

	UIWindow *window = [UIApplication shar	edApplication].keyWindow;
	NSArray *windows = [UIApplication sharedApplication].windows;

さて、UIWindowのallocate先を見てみると

UIAlertView表示時 : 

	(lldb) p window
	(UIWindow *) $2 = 0x000000010a02f460

	(lldb) po [window class]
	UIWindow
		
	(lldb) p self
	(UIWindow *) $3 = 0x000000010a081710	

	(lldb) po [self class]
	_UIModalItemHostingWindow
	
	po windows
	<__NSArrayM 0x10a026150>(
	<UIWindow: 0x109f50aa0; frame = (0 0; 320 568); gestureRecognizers = <NSArray: 0x109f51080>; layer = <UIWindowLayer: 0x109f2ba80>>
	)

UIAlertView表示時 : 

	(lldb)p self
	(UIWindow *) $4 = 0x000000010a02f460

	(lldb) po [window class]
	UIWindow

	(lldb)p window
	(UIWindow *) $5 = 0x000000010a02f460

	(lldb) po [self class]
	UIWindow
	


！！

えっ、UIAlertView表示時って、UIWindow二つできてるの！？

しかも、元のUIWindowのクラスが、`_UIModalItemHostingWindow`とかになってる。

つまりそこら辺をhookすればごにょごにょできるようですね。

## `_UIModalItemHostingWindow`って？

オブジェクトの型をチェックすると、もちろん通ります。

	[self isKindOfClass:[UIWindow class]]

だから純粋にclassでhookする事は出来ません。

`_UIModalItemHostingWindow`は、UIWindowを継承しているためです。



## こんな感じで困っている方も居る模様。

[stackoverflow - UIAlertViews, UIActionSheets and keyWindow problems](http://stackoverflow.com/questions/19816142/uialertviews-uiactionsheets-and-keywindow-problems)


