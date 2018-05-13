+++
date = "2013-12-02T09:40:19+00:00"
draft = false
tags = ["papertrail", "log", "logging", "rails", "centos"]
title = "herokuでおなじみpapertrailをsakuraで使う。"
+++
いちいちサーバーの中に入ってlogを見るなんて辛い。iphoneからsshとか悲しくなる。ログの場所なんて全app分毎回覚えている必要が有るなんて拷問。

しかも、ザックザック検索したい。

というわけでherokuでおなじみpapertrailをさくらサーバーに導入したいと思います。

まず、登録
--------

[papertrail](https://papertrailapp.com)

system log
----------

[https://papertrailapp.com/systems/setup](https://papertrailapp.com/systems/setup)

システムログ吐き出しサービスを調査。

* rsyslog
* syslog-ng
* syslog
* Other

だいたいrsyslogじゃないかな？

こんな感じで探す。

	$ ls -d /etc/*syslog*
	
/etc/rsyslog.confを見ると、rsyslog.d配下のconfファイルを読み込むようになっている。

というわけで、papertrailに吐き出す様設定を追加。

	$ vim /etc/rsyslog.d/papertrail.conf
	$ sudo /etc/init.d/rsyslog restart
	
おっけー。


application log
---------------

application logを送る設定します。

gemいれるだけ。

	$ sudo gem install remote_syslog
	
試しにアプリのログを食べさせる様動かします。

	$ remote_syslog -p 123456 /path/to/access_log
	
うん。飛んでる。

configuration
-------------

食べさせるファイルは細かく分けたいよねってことで、configureを設定。

参考：[ remote_syslog / examples / log_files.yml.example](https://github.com/papertrail/remote_syslog/blob/master/examples/log_files.yml.example)

以下のように食べさせます。nginxの場合などよしなに。

	files: 
	  - /var/log/httpd/access_log
	  - /var/log/httpd/error_log
	  - /opt/misc/*.log
	  - /var/log/mysqld.log
	  - /var/run/mysqld/mysqld-slow.log
	destination:
	  host: logs.papertrailapp.com
	  port: 12345   # NOTE: change to your Papertrail port
	  
auto-boot
---------

自動起動周りとプロセス吐き出し設定。
	
	$ cd ~
	$ git clone git@github.com:papertrail/remote_syslog.git 
	$ sudo cp examples/remote_syslog.init.d /etc/init.d/remote_syslog
	$ sudo chmod 755 /etc/init.d/remote_syslog
	$ sudo ln -s /etc/init.d/remote_syslog /etc/rc3.d/S30remote_syslog
	$ sudo chmod 777 /etc/rc3.d/S30remote_syslog

とりあえずこんな感じで食べさせられました。

その他
-----

secureなメッセージ転送(TLS)や、log rotationまわりはまた今度。




