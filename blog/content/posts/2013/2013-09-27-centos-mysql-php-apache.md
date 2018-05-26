+++
date = "2013-09-27T13:21:06+00:00"
draft = false
tags = ["php", "centos", "migration", "apache", "httpd", "mysql"]
title = "centos, mysql, php, apacheで動いている既存環境の情報をぶっこ抜くでござる"
+++
色々な方法を試したり迷ったりしたけど、やっと同じ環境が動いたので、そのためにどこから情報引っ張ったかをメモ。

chef書き終えた記念カキコ。

OS編
----

とりあえずバージョンぐらいは確認しておく。

	$ cat /etc/redhat-release >> ~/yum.log
	
yumとりあえずぶっこ抜く。
	
	$ yum list installed >> ~/yum.log
	$ scp hoge@192.168.0.1:~/yum.log


mysql編
-------

バージョン調べる

	$ mysql -v >> ~/mysql_version.log
	$ scp hoge@192.168.0.1:~/mysql.log

ソースかyumか調べる。

	$ which mysql >> ~/mysql.log
	$ yum list installed | grep mysql >> ~/mysql.log
	
	
設定ファイルと今までのlogぶっこぬく

	$ scp hoge@192.168.0.1:/etc/my.cnf
	$ scp hoge@192.168.0.1:~/mysql.log


php編
-----

バージョン調べる

	$ php version >> ~/php.log

ソースかyumか調べる。

	$ which php >> ~/php.log
	$ yum list installed | grep php >> ~/php.log

まず`php -i`ぶっこぬく。

	$ php -i >> ~/php.log
	$ scp hoge@192.168.0.1:~/php_*.log

pear, peclのリストぶっこぬく。

	$ sudo pecl list >> ~/php.log
	$ sudo pear list >> ~/php.log

php.iniとlog全部もってくる

	$ scp hoge@192.168.0.1:/etc/php.ini	
	$ scp hoge@192.168.0.1:~/php.log
	

apache編
--------

バージョン調べる

	$ httpd -v >> ~/httpd.log

source コンパイルかyumか調べる。

	$ which httpd >> ~/httpd.log
	$ yum list installed | grep httpd >> ~/httpd.log
	$ yum list installed | grep mod >> ~/httpd.log

とりあえずscpでconf全部と、設定ログもってくる

	$ scp -r hoge@192.1589.0.1:/etc/httpd	
	$ scp hoge@192.168.0.1:~/httpd.log
