+++
date = "2014-03-09T12:25:00+00:00"
draft = false
tags = ["nginx", "send_file", "send_data", "proxy_temp_path"]
title = "[ngix]大容量ファイルをsend_file / send_dataできない"
+++
nginxで大容量ファイルをsendしたらなぜか80KBで切られる。

ふーむ。

## ログを見て見るとこんな感じ


	2014/03/08 06:23:27 [crit] 12390#0: *1 open() "/var/lib/nginx/tmp/proxy/1/00/0000000001" failed (13: Permission denied) while reading upstream, client: 192.168.33.1, server: *.foobar.local, request: "GET /foo/5 HTTP/1.1", upstream: "http://127.0.0.1:5000/foo/5", host: "foobar.local"

ほほぉ、permission Errorとな。

みてみると。

	$ ls -la | grep nginx
	drwx------   3 nginx nginx 4096 Mar  2 12:36 nginx

なるほど、こりゃ書き込めませんな。サーバーの独自管理者で行っている故。

中身を見てみるとこんな構成に。

	$ sudo ls -lR /var/lib/nginx | grep nginx
	/var/lib/nginx:
	drwx------ 7 nginx nginx 4096 Mar  2 12:36 tmp
	/var/lib/nginx/tmp:
	drwx------ 2 vagrant nginx 4096 Mar  2 12:36 client_body
	drwx------ 2 vagrant nginx 4096 Mar  2 12:36 fastcgi
	drwx------ 7 vagrant nginx 4096 Mar  8 06:10 proxy
	drwx------ 2 vagrant nginx 4096 Mar  2 12:36 scgi
	drwx------ 2 vagrant nginx 4096 Mar  2 12:36 uwsgi
	/var/lib/nginx/tmp/client_body:
	/var/lib/nginx/tmp/fastcgi:
	/var/lib/nginx/tmp/proxy:
	drwx------ 3 nginx nginx 4096 Mar  8 06:09 1
	drwx------ 3 nginx nginx 4096 Mar  8 06:09 2
	drwx------ 3 nginx nginx 4096 Mar  8 06:09 3
	drwx------ 3 nginx nginx 4096 Mar  8 06:10 4
	drwx------ 3 nginx nginx 4096 Mar  8 06:10 5
	/var/lib/nginx/tmp/proxy/1:
	drwx------ 2 nginx nginx 4096 Mar  8 06:0
	
どうやら `/var/lib/nginx/tmp/proxy`上に大容量ファイルをsendする場合はtemporaryしている模様。

## ドキュメントを調べてみる

[HttpProxyModule - proxy_temp_path](http://wiki.nginx.org/HttpProxyModule#proxy_temp_path)

> This directive works like client_body_temp_path to specify a location to buffer large proxied requests to the filesystem.

なるほど。

解決策としては

1. chownしちゃう
2. 別pathを指定したげる。

ただ、当該ディレクトリのpermissionを変更するようなoptionが無い。事を考えると、1.って簡単だけど余りエレガンスじゃないよね？


## でもみんな

解決策1でやってる。

[13: Permission denied while reading upstream using Nginx](http://www.nginxtips.com/13-permission-denied-while-reading-upstream-using-nginx/)


[Permission denied while reading upstream](http://serverfault.com/questions/235154/permission-denied-while-reading-upstream)

[nginx on Ubuntu: Permission denied](http://stackoverflow.com/questions/18714902/nginx-on-ubuntu-permission-denied)


というわけでした。