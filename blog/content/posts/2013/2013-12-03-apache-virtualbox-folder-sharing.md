+++
date = "2013-12-03T11:31:36+00:00"
draft = false
tags = ["virtualbox", "apache", "nfs"]
title = "Apache + VirtualBox folder sharingで、静的ファイルがキャッシュされてしまう。"
+++
virtualbox内でapacheを動かし、マウントされているフォルダでソースを管理してると、なぜかcssやjsの更新が適用されないという問題に嵌りました。

* apache上でcacheを行っていない。
* blowerもcacheをdisableにしている

もちろん、ソース自体はちゃんと更新されています。

調べて見るとこんな記事や

> ### [Virtualbox上のApacheでホストマシンと共有している静的ファイル（CSSなど）の更新が検知されない問題を解決する方法](http://tipshare.info/view/4f3481ee4b21227814000001)
>
> Virtualboxの共有フォルダ機能でホストのMacのworkspaceをゲストのCentOSにマウントしてDocumentRootに設定し、開発していたところCSSを変更しても反映されない。

ここから繋がるこんな記事


> ### [how to fix the caching problems with virtualbox folder sharing + apache](http://cantuse.it/2009/01/virtualbox-apache2-strange-caching-issues/)
> 
> We are using a common VirtualBox image for the development of our graduation project. The files reside in our own computer, so the virtual instance only runs the Apache, which pulls the files from our computer and executes them. So for Apache, the files it serves appear to be mounted with NFS (that’s the way virtual systems represent folder sharing)


つまるところ、以下のオプションをhttpd.confの対象のサービス部分に追加してあげれば良い。

	  EnableMMAP Off
	  EnableSendfile Off

enablemmapについて調べると

> [EnableMMAP ディレクティブ](http://oxytricha.princeton.edu/manual/ja/mod/core.html#enablemmap)
> 
> このディレクティブは配送中にファイルの内容を読み込む必要があるときに httpd がメモリマッピングを使うかどうかを制御します。デフォルトでは、 例えば、mod_include を使って SSI ファイルを配送 するときのように、ファイルの途中のデータをアクセスする必要があるときには Apache は OS がサポートしていればファイルをメモリにマップします。
> 
> このメモリマップは性能の向上を持たらすことがあります。 しかし、環境によっては運用上の問題を防ぐためにメモリマッピングを 使用しないようにした方が良い場合もあります:
> 
> マルチプロセッサシステムの中にはメモリマッピングをすると httpd の 性能が落ちるものがあります。
> **NFS マウントされた DocumentRoot では、httpd がメモリマップしている間にファイルが削除されたり 短くなったりしたときに起こるセグメンテーションフォールトのために httpd がクラッシュする可能性があります。**
> これらの問題に当てはまるサーバの設定の場合は、以下のようにして ファイルの配送時のメモリマッピングを使用不可にしてください:

泣いた。