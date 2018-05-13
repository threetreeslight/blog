+++
date = "2013-09-06T07:17:00+00:00"
draft = false
tags = ["php", "pdo", "mysql", "mysql_connect", "unix_socket"]
title = "mysqlに接続するときはunix_socketに注意"
+++
妙なところで詰まったのでメモ。

mysqlはあまり使ってこなかったので、ちょっと衝撃。

端的に言うと、デフォルトのunix_socketは　`/tmp/socket`にあるんだけど、今回boxen経由でmysqlをいれているため、そんなところにファイルは作ってくれない。

で、phpでmysql_connectやpdoを使う場合にココで引っかかったというわけです。

mysqlのunix socketを調べる方法
---
***

	$ mysqladmin version
	mysqladmin  Ver 8.42 Distrib 5.5.20, for osx10.8 on i386
	Copyright (c) 2000, 2011, Oracle and/or its affiliates. All rights reserved.
	
	Oracle is a registered trademark of Oracle Corporation and/or its
	affiliates. Other names may be trademarks of their respective
	owners.
	
	Server version          5.5.20
	Protocol version        10
	Connection              Localhost via UNIX socket
	UNIX socket             /opt/boxen/data/mysql/socket
	Uptime:                 23 days 3 hours 13 min 4 sec
	
	Threads: 1  Questions: 3085  Slow queries: 0  Opens: 70  Flush tables: 1  Open tables: 30  Queries per second avg: 0.001

案の定、`/opt/boxen/data/mysql/socket`にある。

#### pdo

こんなException吐いたら、

	[PDOException]
	SQLSTATE[HY000] [2002] No such file or directory

unix_socketが問題

	> $dbh = new PDO('mysql:host=localhost;unix_socket=/opt/boxen/data/mysql/socket;dbname=hogehoge', 'root', 'root', array());

#### mysql_connect

こんなwarningでたら

	Warning: mysql_connect(): No such file or directory in php shell code on line 

やっぱりunix_socketが問題

	> $link = mysql_connect('localhost:/opt/boxen/data/mysql/socket', 'root', 'root')

という感じでした。
