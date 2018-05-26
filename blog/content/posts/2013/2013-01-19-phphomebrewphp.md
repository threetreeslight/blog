+++
date = "2013-01-19T09:26:57+00:00"
draft = false
tags = ["PHP", "homebrew", "brew", "phpenv", "php-build", "version manager"]
title = "[PHP]HomebrewでPHP環境構築してマルチバージョン管理"
+++
<p>brewでphpenvとphp-buildをインストール</p>&#13;
<pre>$ brew tap homebrew/dupes&#13;
$ brew tap josegonzalez/homebrew-php&#13;
&#13;
$ brew install --HEAD phpenv&#13;
$ brew install php-build&#13;
&#13;
.bashrc&#13;
$ vim ~/.bashrc&#13;
+++&#13;
if [ -f $HOME/.phpenv/bin/phpenv ]; then&#13;
export PATH=$PATH:$HOME/.phpenv/bin&#13;
eval "$(phpenv init -)"&#13;
fi&#13;
+++&#13;
</pre>&#13;
<p><br />apacheのインストール <br />httpd-develのライブラリ周りをphpのコンパイルで利用するのでインストールが必要</p>&#13;
<pre>$ mkdir /usr/local/sbin&#13;
$ brew install httpd&#13;
$ vim ./.bashrc&#13;
+ export PATH=/usr/loca/bin:$PATH&#13;
</pre>&#13;
<p><br />その他compileに必要になるライブラリを必要に応じてインストール</p>&#13;
<pre>$ brew install wget&#13;
$ brew install re2c&#13;
$ brew install mcrypt&#13;
</pre>&#13;
<p><br />php install Apachemoduleの生成するようconfigure設定</p>&#13;
<pre>$ vim /usr/local/share/php-build/default_configure_options&#13;
+ --with-apxs2=/usr/local/sbin/apxs&#13;
&#13;
$ php-build --definitions&#13;
$ sudo php-build 5.4.5 ~/.phpenv/versions/5.4.5&#13;
...&#13;
[Success]: Built 5.4.5 successfully.&#13;
&#13;
$ mv /usr/local/Cellar/httpd/2.2.22/libexec/libphp5.so ~/.phpenv/versions/5.4.5&#13;
</pre>&#13;
<p><br />切り替え</p>&#13;
<pre>$ phpenv global 5.4.5&#13;
$ phpenv version&#13;
5.4.5&#13;
$ phpenv rehash&#13;
-&gt; ターミナル再起動&#13;
&#13;
$ php -v&#13;
&#13;
</pre> 