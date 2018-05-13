+++
date = "2013-09-18T13:04:00+00:00"
draft = false
tags = ["binary", "mysql", "install"]
title = "mysql binary install"
+++
訳あって5.0.45のmysqlをインスコする必要が有りましたので、vagrant+chefで環境作りました。

[MySQL Product Archives](http://downloads.mysql.com/archives.php)

[2.16. Installing MySQL on Unix/Linux Using Generic Binaries](http://dev.mysql.com/doc/refman/5.0/en/binary-installation.html)

素のやり方は以下。

User作成

    $ groupadd mysql
    $ useradd -g mysql mysql


バイナリ落としてインストール

    $ cd /usr/local
    $ wget http://downloads.mysql.com/archives/mysql-5.0/mysql-5.0.45-linux-i686.tar.gz
    $ tar zxvf mysql-5.0.45-linux-i686.tar.gz
    $ ln -s /usr/local/mysql-5.0.45-linux-i686 mysql
    $ cd mysql
    $ chown -R mysql .
    $ chgrp -R mysql .

db作る

    $ scripts/mysql_install_db --user=mysql
    $ chown -R root .
    $ chown -R mysql data


conf設定

    $ cp support-files/my-medium.cnf /etc/my.cnf
    $ bin/mysqld_safe --user=mysql &

init.d

    $ cp support-files/mysql.server /etc/init.d/mysql.server


動くかな？


    $ mysql
    mysql>


ok