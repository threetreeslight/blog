+++
date = "2014-01-26T12:40:18+00:00"
draft = false
tags = ["objective-c", "ios", "UIView", "drawRect", "setNeedsDisplay"]
title = "[ios][objective-c]UIViewの強制的な更新"
+++
場合に寄って、UIViewを強制的に更新したい場合が有ります。

そのためにもdrawRectの動きを理解する必要が有ります。

drawRect

* このメソッドはビューの描画を更新する。
* UIViewを一つの要素と扱う。
* 一つの要素の単位で再描画される。
* 描画のキャッシュ(pixels)がされる。
* 更新が必要な場合に呼び出される。

## 強制的に更新するメソッド

setNeedsDisplay/setNeedsDisplayInRect

* drawRectを呼び出す予約をする。

display

* 即座にdrawRectを呼び出す。

## 参考

* [UIView の drawRect と setNeedsDisplay の関係](http://blog.f60k.com/uiview_drawrect_setneedsdisplay/)