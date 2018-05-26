+++
date = "2014-01-27T07:21:25+00:00"
draft = false
tags = ["ios", "objective-c", "appDelegate"]
title = "[iOS][objective-c]ViewControllerからappDelegateインスタンスにアクセスする"
+++
ViewController系からappDelegateインスタンスにアクセスしたくなりました。

appDelegateでしか値を持っていない場合です。

## appDelegateは多分シングルトンかな？

と思って調べたらシングルトンでした。

参考：[画面間でのデータの受け渡しに付いて](http://eien.seesaa.net/article/261740269.html#n1b)

## ではどうやってappDelegateにアクセスするか？


方法としては、UIApplicationからdelegateインスタンスを取得します。

UIApplicationは、こちらを参照

http://iphone-tora.sakura.ne.jp/uiapplication.html



    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    