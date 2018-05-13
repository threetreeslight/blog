+++
date = "2013-01-02T03:19:00+00:00"
draft = false
tags = ["Apache", "mbstrinr", "php", "MAMP"]
title = "[Mac]MacでフォルトもしくはMAMPでのPHP設定"
+++
<p>次の仕事でphpの作業をしなければ行けなくなったのでphpについて学習。</p>&#13;
<p><br />とりあえず環境は、macでフォルトのapacheとphpで。</p>&#13;
<p><strong>PHP</strong> </p>&#13;
<p>1. apacheのphpモジュールをonにする</p>&#13;
<pre>$ vim /etc/apache2/httpd.conf&#13;
&#13;
+ LoadModule php5_module libexec/apache2/libphp5.so&#13;
&#13;
</pre>&#13;
<p>2. エラーを吐くようphp.iniの設定</p>&#13;
<pre>$ sudo cp /etc/php.ini.default /etc/php.ini&#13;
$ sudo vim /etc/php.ini&#13;
&#13;
display_errors = On&#13;
display_startup_errors = On&#13;
&#13;
</pre>&#13;
<ul><li>MAMP上のphp設定ファイル（confの中じゃない）<br />/Applications/MAMP/bin/php/php5.4.4/conf/php.ini </li>&#13;
</ul><p>3. マルチバイト言語を使えるようにphp.iniの設定</p>&#13;
<pre>$ sudo vim /etc/php.ini&#13;
&#13;
date.timezone = Asia/Tokyo&#13;
&#13;
mbstrinr.language = Japanese&#13;
mbstring.internal_encoding = UTF-8&#13;
mbstring.http_input = pass&#13;
mbstring.http_output = pass&#13;
mbstring.detect_order = auto&#13;
mbstring.substitute_character = none;&#13;
&#13;
</pre>&#13;
<p>4. apache再起動</p>&#13;
<pre>$ sudo apachectl graceful&#13;
&#13;
</pre>&#13;
<p>5. 検証</p>&#13;
<pre>$ cd ~/hogeUser/sites&#13;
$ vim ./php/index.php&#13;
&#13;
<!--?php 

echo "It's Work!"

? -->&#13;
</pre>&#13;
<p>http://localhost/hogeUser/php/</p>&#13;
<p><br />-&gt; It's Work!と表示されればおk！</p>&#13;
<p><br /><br />MAMPの場合</p>&#13;
<ul><li>作ったファイルのディレクトリパスをApacheのDocument rootに設定</li>&#13;
<li>http://localhost:8888/へアクセス</li>&#13;
</ul>&#13;
<p><br />P.S.</p>&#13;
<p>mysqlのターミナルログイン</p>&#13;
<p>/Applications/MAMP/Library/bin/mysql -u root -p</p> 