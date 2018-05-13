+++
date = "2013-10-22T15:10:49+00:00"
draft = false
tags = ["mysql", "db", "innodb", "index", "sql", "my.conf", "tuning", "performance"]
title = "mysql（innodb）のチューニングしました"
+++
DBレスポンスの悪い。やばい、どれくらいヤバいって、超ヤバい。クレーム来るぐらい。

全然得意ではないけど、頑張ってチューニングしました。

チューニング方法を切り分けると３つあると考えました。

1. innodbのmysql設定のチューニング
1. indexのチューニング
1. SQLのチューニング

mysql設定のチューニング
----------

#### CPUリソースが問題

CPUのアイドルタイムを見る事で、メモリにあふれてないか調査します。

CPUの利用率を見る事で、CPUパンパンになっていないか調査します。

だめだったら、AWSでハイスペックインスタンス使うか、DBサーバ買い替えましょう。

それが出来ない場合はindexやクエリのチューニングを頑張る。

#### 物理memoryリソースが問題

swap領域にあふれていたらpagingされてます。残念無念。

物理的なメモリ足しましょう。

足せない場合はindexやクエリのチューニングを頑張る。

#### memoryの割当容量が問題

設定ファイルを確認し、memoryの割当領域増やしましょう。

	$ vim my.conf
	innodb_buffer_pool_size = 1332M

物理的な状態を加味し調整必須。

MySQL ABのドキュメントには、搭載メモリの80%とも書かれています。


#### connection数が問題

コネクション数をモニタリングしていたときに、常にぱんぱんな場合

max_connection数がapacheより少ない場合が有ります。その場合はmax_connectionsを調整しましょう。

	$ vim my.conf
	max_connections=512

こんどはmax_connectionsを上げた事が原因で、connection数作成にメモリやcpuが奪われます。それに対応するためには事前にconnectionをキャッシュしておけば良さそう。

	$ vim my.conf
	max_connections=512
	thread_cache=512

ただ、コネクションの維持が異様に長くて、新しいコネクションが作れない事態に陥る事も有ります。そのためには

	$ vim my.conf
	max_connections=512
	thread_cache=512
	
	interactive_timeout=60
	wait_timeout=60	

ただ、待機時間が長くなるサービスで、timeoutを短くするのはナンセンスっぽいです。
（ネトゲで放置系など）

そういうのは適時調整を。

参考：[max_connectionsのチューニング](http://thinkit.co.jp/free/article/0707/2/3/)


indexのチューニング
-----------------

ここは流れで書きます。

#### DBの現状調査

各DBのschema dumpを取得し、どのテーブルにどんなindexが張られているか取得します。

	$ mysql > schema.dump
	
#### クエリの洗い出しと解析

前クエリを対象とした計測用SQLの作成

スロークエリを解析します。

	$ mysqldumpslow -s t /var/log/mysql/mysql-slow.sql

上記コマンドで、実行時間の遅い物から順にレポートされます。

#### index作成と影響調査

主要SQLのexplainでindexが適用されているか否か確認し、必要に応じてindexを作成する。

対象となるSQL箇所は以下の通り

* foreign keyに相当する箇所
* 十分に値が分散するカラムで、where句、order句、having句、group by句で利用するカラム
* countやsumなどの値にindexされていない値が利用されていない場所

特に３つ目は気をつけるべきで、劇的にsqlの実行速度が遅くなります。

select * from employee where id between 100 and 10000 order by age desc

このとき、idにのみindexを張られているとします。

すると、idへの参照を行った後、ageで実体参照を行いソートします。結果としてインデックスと実態テーブルにそれぞれ１回ずつ全文検索を掛けているので、ものすごい遅くなります。

上記と同様の理由で、distinct、outer joinには気をつけないといけません。

indexがパフォーマンスを劣化させます。

SQLのチューニング
----------

#### distinctを避ける

indexと実体テーブルへの検索が発生する恐れが有ります。

#### outer joinやleft joinを避ける

indexが悲しい事になります。

#### viewを使わない

indexが悲しい事になります。

#### 無用なindex利用されていないか調査する

適切なindexが選択されているかexplainを利用して検索して下さい。

不適切なindex（十分な分散値が期待されないindex）が利用されていない場合は、あえて複合キーを張るのもありです。

#### すべてがindex内で完結するクエリーは早い。

糞早いです。美味く使うようにしましょう。countとか(*)でなく(id)でやるとか。

#### limit をつけても where や order by すると意味がない。

あんま意味ないです。

#### <>, !=は全操作が走るので極力避ける。

全操作するのでindexが価値を発揮しません。 INやORを利用するようにしましょう。

#### ORMをうまくりようする

必要に応じてORMでkey取得して、再度APP側からSQL発行するなどDB側のボトルネックを解消しましょう。

とはいえ、N+1問題（親→子関係テーブルへの参照が親１回分無駄に多くなる）ことに十分気をつける必要が有ります。
