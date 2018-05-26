+++
date = "2013-06-01T07:44:52+00:00"
draft = false
tags = ["yahoo", "google", "adwords", "conversion tracking"]
title = "yahoo, googleにおけるリスティングのconversionトラッキングについて"
+++

yahooプロモーション広告とgoogle adwordsを併用している場合、それぞれでconversion tracking用タグを発行して、埋め込む事が有ると思いますが、両者が競合しているっぽいです。

### google adwords
***

googleが発行するconversion.jsの処理

1. google変数（グローバル変数）を食べて、imgもしくはiframeタグをDOMに埋め込む
2. global変数を初期化（nil）


### yahoo プロモーション広告
***

yahooプロモーション広告のconversion.jsをロードす

1. yahoo変数（グローバル変数）をgoogle変数（グローバル変数）に食べさせる。
2. googleのconversion.jsをロードしてscriptタグとして埋め込む
3. 以下google adwordsのconversion.jsの処理が実行される


### それによって
***

google adwordsの初期化処理や、yahooプロモーションの変数埋め込み処理が非同期に実施されるため、非常に不安。

とりあえず月曜日にでもgoogleのサポセンに聞いてみる。
