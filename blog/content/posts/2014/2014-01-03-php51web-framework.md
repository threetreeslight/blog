+++
date = "2014-01-03T16:17:00+00:00"
draft = false
tags = ["rails", "php", "php5.1", "web", "humper", "framework"]
title = "マイグレーションするために涙ながらphp5.1で動くweb framework作った"
+++
## 戦い

訳あってphp5.1で動くフレームワークを涙流しながら作りました。

マイグレーションのためです。オレオレしたかった訳では有りません。マイグレーションするためなのです。

* php5.1
* セッションとグローバル変数によるスタティックおじさん
* apacheととてつもなく仲が良い。
* 無限pearモジュール。
* 手続き型スパゲティ
* テスト書くのも困難な料理。
* とはいえ機能追加は常に。

無情。さすがにコピペ駆動開発はつらい。だめだ。

## 探した

phpをバージョンアップすることもままならないので、

* 挙動を十分に理解できており
* テストが掛ける仕組み
* そこそこRESTfullで
* PHP5.1で動く

まともなフレームワークを探した。頑張って探した。

が、存在しなかった。見つける事すら出来なかった。泣けた。


そういうわけで２−３日間ぐらいで何とか全体をつくり、最低限無いとまずい機能を作りながら追加してマイグレーションするための足がかりを作りました。

## [humper framework](https://github.com/ae06710/humper)作った

rails意識して自分なりに頑張りました。

とはいえまともなメタプロが出来ないPHP5.1、ソース汚い。なんどもphpに切れかけた。

support

* REST API
* ActiveRecord like ORM
* Protect from forgery
* Auth
* I18n
* helper
* Pure PHP Template engine

「このフレームワークの上にマイグレーションで来たら、俺、railsにマイグレーションするんだ。。。」

死亡フラグ？