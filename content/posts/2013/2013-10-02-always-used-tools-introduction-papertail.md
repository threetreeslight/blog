+++
date = "2013-10-02T01:32:00+00:00"
draft = false
tags = ["loggaly", "papertail", "log", "hook"]
title = "Always used tools introduction: papertail"
+++
あまりネタが無い時用です。

監視と言えば、

* 死活監視
* リソース監視
* パフォーマンス監視

の３種類が基本ですが、ログをhookしてごにょごにょしたい事ってありますよね。
そんなときに、使えるのがコレ。

[papertail](https://papertrailapp.com/)

競合としては[Loggaly](http://www.loggly.com/)などが挙げられます。

* 特定のキーワードをhookしてnotificationできる。
* リアルタイムにログをキーワード検索できる。
* 容量超えた分は、S3に保存してくれる。

これだけでも使わない必要は無いです。
しかも無料プランで上記はすべて使えます。

有料プランでは、リアルタイムログ検索できる対象ログの期間が延びるイメージです。

webサーバーの容量を気にする事も無く、ログサーバー立てる必要もない。
便利なので是非。