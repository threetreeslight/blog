+++
date = "2013-11-13T03:15:00+00:00"
draft = false
tags = ["elasticsearch"]
title = "第２回elasticsearch勉強会に行ってきた。"
+++
宮川さんのポットキャストでelasticsearchネタが出ており、興味を持ったため、第２回勉強会に行ってきました。

かなり面白そう。こんどガッツリ腰を据えていじろう。

## elasticsearchのRouting機能

資料  [elasticsearchのRouting機能](http://blog.johtani.info/images/entries/20131112/About_es_routing.pdf)

### メモした内容

elasticsearch google group

* [elasticsearch group](https://groups.google.com/forum/#!forum/elasticsearch-jp)

index

* shard数はindexを作成したタイミングでしか作れない。
* document数が増えたときに後から分割するって出来ない。
* 分割できないから結構割り切ったシャーリングするよ。

routing 

* idの非効率な処理をurlパラメータくっつけて登録すると便利

scaleout

* indexを増やす方向でscaleoutする、なのでshard数によるスケールは出来ない。
* 1index辺りのshard数は変わらないけど、node単位は増やせるよね。

上記部分について@johtaniさんからcomment頂きました。ありがとう御座います！

> あー、若干誤解を招く言い方だったかなぁ。shardを増やすスケールもありますが、最初にシャード数決めないとダメって意味でした。 RT @ae06710: elasticsearchの勉強会行ってきた。 http://t.co/97NwkPAIq3 少し腰据えてしっかりやろう。

## aliasで

複数indexに帯する検索を挙げる事が出来る

## Elasticsearch試行錯誤

資料

* [Elasticsearch trial and error by pisatosh](https://speakerdeck.com/pisatoshi/elasticsearch-trial-and-error)

mBaaSにおけるDBとして利用されているとの事。すげい。

### メモした内容
マルチテナントのために

* indexを分割する事で対応しました。

DBのように使うから

* 即時反映したいけど結構時間がかかる。
* 改善するためにレプリカの数を減らした。replicationのオーバーヘッドが減るけど、冗長性でトレードオフ

routingつかって

* 検索性能を挙げました。
* 意図したshardに放り込めて幸せ。

backupは

* elastic search登録と一緒にmysqlへぶっこむ。
* indexのbackupは取らなかった。データはmysqlにぶち込む。
* elasticesarchでindex壊れたら怖いから、とりあえず経験のあるmysqlにしたという経緯。

dynamic mappingの苦労話

* mBaaSで自由自在に情報を含められるのでそのまま使うと危険だよ。定義ファイルが膨れ上がったり。データ型がconflectしたりとか。
* ちなみに、、、スキーマフリーは少人数で楽だけど、大人数だと大爆発
* あらかじめマピング定義を全て定義しておくのおすすめ.

ちなみに、elasticsearchの中の人曰く

* mappingそんなおっきくならない設計思想。普通はスキーマ決まってるよねっていう前提。

toolたち

* [elasticsearch-head](http://mobz.github.io/elasticsearch-head/)
* [bigdesk for elasticsearch](http://bigdesk.org/)
* [sence json](https://chrome.google.com/webstore/detail/sense/doinijnbnggojdlcjifpdckfokbbfpbo)
* [elasticsearch test](https://github.com/tlrx/elasticsearch-test)

unit testは？　

* elasticsearchのnode clientを立ち上げて、テストデータ配備して、終了後に終了するようふつうにやる。

その他Tips

* クラスタ名は変更しよう！
* あとbackup周りは1.0からサポートされるよ！

参考 : [Snapshot/Restore in Elasticsearch 1.0 by Elasticsearch Inc](https://speakerdeck.com/elasticsearch/restore-in-elasticsearch-1-dot-0)


## Kibana入門

資料：[Kibana入門 by Yusuke Mito](https://speakerdeck.com/y310/kibanaru-men)

### メモした内容

* もともとlogstashで集めたツールを可視化するために作られたツール。今ではelasticsearch公式ツール。
* クライアントだけで動よやっほい。

利用するとき

* サーバーサイドが無くてデータどうするの？ー＞作ったdashbord情報もelasticsearchに保存しちゃうアクロバティックさがすごい。
* だから何気なくリロードは危険。保存してない場合なくなっちゃう。

elasticsearch

* indexはindex templateをつかって快適に生成
* m1.leargeでindexが10GB/dayになると、elasticsearchが詰まって死ぬので気をつけよう。そうするとfluentdがバッファオーバーフロー。死ぬ


情報収集

* [elasticsearch / kibana](https://github.com/elasticsearch/kibana)
* [elasticsearch本家ブログ](http://www.elasticsearch.org/blog)

Tips(質疑など)

* elasticsearchにはtimezone(locale)と年月日までしっかり指定してあげないと悲しくなる。
* 指定しないと、UTCで前日分換算でindexが生成されたり、dynamic mappingの所為で途中で方が変わって検索できなくなったりしちゃう後悔発生。
* json使えばkibana使えるので、無理矢理json作って渡すだけでもいける。


## elasticsearch+kibanaでjdbcつないでつかう

資料：[ElasticSearch+Kibanaでログデータの検索と視覚化を実現するテクニックと運用ノウハウ](http://www.slideshare.net/y-ken/elasticsearch-kibnana-fluentd-management-tips)

* jdbc riverを使うと、mysqlやhadoop(tesuredata)でわいわいできる
* jdbc river0.90.6で動かないので要注意。ぷるりく中。



## LT: fluent-plugin-kibana-server

資料：[fluent-plugin-kibana-server](https://gist.github.com/repeatedly/7427856)

* fluentdの中でkibana動さくさくっと動く。


## LT: Auth Plugin

資料：[codelibs / elasticsearch-auth](https://github.com/codelibs/elasticsearch-auth)


* Authをさくっと出来るように



世の中すごい人がいっぱい居る。