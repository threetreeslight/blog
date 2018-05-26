+++
date = "2014-04-19T14:10:11+00:00"
draft = false
tags = ["RDS", "AWS", "sakura", "mysql", "VPC", "security"]
title = "サクラVPS内のmysqlからRDSへの移行"
+++
サクラVPSとかでごにょごにょしていたサーバー群をそろそろAWSに移行します。

その段取りを順を追ってメモしてきます。

## RDS - ParameterGroup, OptionsGroup

RDSのmysqlはシステムのデフォルト値をconfigに適用してしまうので、UTF8を利用するためには、新たにparameter groupを作成する必要が有ります。

グループ作って

![RDS_ParameterGroup](https://31.media.tumblr.com/ad75c247635abea7ac781674c7727722/tumblr_inline_n4a77za5Kx1r11648.png)

設定

![RDS_ParameterGroup_detail](https://31.media.tumblr.com/9fc9b157517df6c794324712b941b455/tumblr_inline_n4a78jFOZB1r11648.png)

InnoDBのチューニングを考えると、合わせてOptionsGroupも作っておく事をお勧めします。

ここら辺はCLIでやるのもあり。

## RDS - Instance

とりあえず作る。その際に気にしたポイントは以下の通り

[Amazon RDS for MySQL](http://aws.amazon.com/jp/rds/mysql/)

* 月１メンテナンスが強制的に入るかもしれない。
* InnoDBが安定
* メンテナンス時もfailoverしてくれるので、エンドユーザーに提供しているサービスならMulti-AZ必須
	* [Multi-AZ 配置](http://aws.amazon.com/jp/rds/multi-az/)
* ストレージ容量は無停止でアップできるので小さく5GBでスタート
* ディスクへのIOがそんなになさそうならm1.small

![RDS_instance](https://31.media.tumblr.com/520573ac56a30deebd857cf3e53c4ef2/tumblr_inline_n4a79rt7xe1r11648.png)

## VPC

exportしたDB Dumpimportしたいので、外部からのアクセスを許可するために、VPCのセキュリティグループを編集。

RDSにはdefaultセキュリティグループが適用されているはずなので、そこにmysqlのアクセスを所定のIPのみ通してあげます。

![VPC_securityGroup](https://31.media.tumblr.com/46a3960107782f486a5937e4297de72c/tumblr_inline_n4a7a9PHxm1r11648.png)

これで、

	$ mysql -h foo.bar.rds.amazonaws.com -u foo -p -P3306	
	Enter password:
	Welcome to the MySQL monitor.  Commands end with ; or \g.
	Your MySQL connection id is 24
	Server version: 5.6.13-log MySQL Community Server (GPL)
	
	Copyright (c) 2000, 2011, Oracle and/or its affiliates. All rights reserved.
	
	Oracle is a registered trademark of Oracle Corporation and/or its
	affiliates. Other names may be trademarks of their respective
	owners.
	
	Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
	
	mysql> 

通る事を確認。

### dumpを食わせる

後は、mysqlのdumpを食わせてあげれば終了です。


	$ mysqldump -h foo.bar.rds.amazonaws.com -u foo -p -P3306 -d bar < ./dump.sql
	
	