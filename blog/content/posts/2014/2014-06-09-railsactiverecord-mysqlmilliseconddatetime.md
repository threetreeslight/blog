+++
date = "2014-06-09T02:27:03+00:00"
draft = false
tags = ["rails", "mysql", "activerecord", "millisecond", "datetime"]
title = "[rails]activeRecord + mysqlにてmillisecondを含むdatetime型を扱う"
+++
mysql 5.6.4よりmillisecondを扱う事が出来るようになった。

mysql2 adopterを見ても、動作する事が分かる。

[MySQL 5.6 with microsecond precision #324](https://github.com/brianmario/mysql2/issues/324)


## millisecondを適用

datetime型については、後方互換のためデフォルトは秒までしか取得しない。

そのため、millisecondまで適用する事を明示的に宣言する必要が有る。


	SQL> ALTER TABLE books MODIFY COLUMN published_at DATETIME(6);

reference

- [11.3.1 The DATE, DATETIME, and TIMESTAMP Types](http://dev.mysql.com/doc/refman/5.6/en/datetime.html)


## migrationの宣言

こんな感じで適用されます。

	$ vim db/migrate/xxxxx_hoge.rb
	
	change_column :books, :published_at, limit: 6
	
	$ rake db:migrate
	$ rails db
	SQL> desc books;
	
	...	
	| published_at     | datetime(6)  | YES  | MUL | NULL    |
	...     
	
ここらへんのPRで追加されています。

reference


- [
New issue
MySQL 5.6 Fractional Seconds #14359](https://github.com/rails/rails/pull/14359/files#diff-95d3dfc38be7275845454d444b0826f9R678)
- [
New issue
MySQL 5.6 Fractional Seconds #14359](https://github.com/rails/rails/pull/14359)


## ただ、Edge versionのみ

[MySQL 5.6 Fractional Seconds #14359](https://github.com/rails/rails/pull/14359/files)

のPRは、以下のバージョンのリリースに含まれていないため、基本的には使えないと思った方が良さそうです。

- rails4.1.1
- rails4.1.2rc

残念
