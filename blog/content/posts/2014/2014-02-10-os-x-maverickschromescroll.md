+++
date = "2014-02-10T03:36:19+00:00"
draft = false
tags = ["Mavericks", "os x 10.9", "chrome", "scroll"]
title = "[OS X Mavericks]chromeのscrollがいきなり効かなくなる"
+++
調べて見るとあるあるの模様。

chrome側も認識していて、issueも上がっているがOSサイドの問題みたい。

[Issue 310649:	OSX Maverick: Scrolling stops working when using the mouse gesture to switch to the previous page](https://code.google.com/p/chromium/issues/detail?id=310649)

暫定的な解決ほほうとしては、PRAMをクリアするとの事

[Apple Support - NVRAM／PRAM をリセットする](http://support.apple.com/kb/ht1379?viewlocale=ja_JP)


参考

* [Mac OS X Mavericks Chromeでページスクロールができない不具合がある](http://nasimeya.blog.fc2.com/blog-entry-760.html)