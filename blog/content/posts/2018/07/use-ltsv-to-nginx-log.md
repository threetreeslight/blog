+++
date = "2018-07-07T17:00:00+09:00"
title = "Use LTSV to nginx access_log"
tags = ["nginx", "ltsv", "log"]
categories = ["programming"]
+++

GKE上でのblog運用や監視が大分形になってきました。

## 次に目指すところ

ここから以下のようなデータパイプラインとログの分析基盤を作って行きたいと思います。

```text
nginx prometheus grafana
  |       |         |
  -------------------
          |
    fluentd cluster
          |
  -------------------
  |       |         |
bigquery gcs    papertrail
          |
     spark(data proc)
```

TODOは以下のようなイメージです。

1. nginx logをLTSVに変える
1. 自前のfluentd clusterを準備する
1. fluentd clusterからbigquery, gcs, papertrailにfunoutするようにする
1. nginx, prometheus, grafanaなどの稼働するcontainerのlog driverを上記で準備したものに変える
1. google analyticsのデータをembulkを利用した定期バッチで GCSやbigqueryにpertitioningされた形で格納する
1. 上記のログを元に、spark(data proc)を回していい感じに分析できるようにする
1. mllibを使って遊ぶ

今回はその中での一つ目に着手します。

## What ltsv

改めてltsvについてまとめます。

http://ltsv.org/

> Labeled Tab-separated Values (LTSV) format is a variant of Tab-separated Values (TSV). 
> you can parse each line by spliting with TAB (like original TSV format) easily, and extend any fields with unique labels in no particular order.

大分昔の記事ですが、 [naoya - LTSV FAQ - LTSV って何? どういうところが良いの?](http://d.hatena.ne.jp/naoya/20130209/1360381374) を参考にするとその利点がイメージしやすいと思います。

textはパースしにくいし、かといってjsonでquotationでくくり続けるの辛かったりもするし、tabで区切ると楽だよという主観です。

## Use LTSV on nginx

```diff
-    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
-                      '$status $body_bytes_sent "$http_referer" '
-                      '"$http_user_agent" "$http_x_forwarded_for"';
+    log_format ltsv "time:$time_local"
+                    "\thost:$remote_addr"
+                    "\tforwardedfor:$http_x_forwarded_for"
+                    "\treq:$request"
+                    "\tstatus:$status"
+                    "\tsize:$body_bytes_sent"
+                    "\treferer:$http_referer"
+                    "\tua:$http_user_agent"
+                    "\treqtime:$request_time"
+                    "\tcache:$upstream_http_x_cache"
+                    "\truntime:$upstream_http_x_runtime"
+                    "\tvhost:$host";

-    access_log    /dev/stdout;
+    access_log    /dev/stdout ltsv;
```

## access log

before

```txt
nginx_1              | 172.19.0.1 - - [07/Jul/2018:07:26:55 +0000] "GET / HTTP/1.1" 200 26354 "-" "curl/7.54.0"
```

after

```txt
time:07/Jul/2018:07:31:38	+0000	host:172.19.0.1	forwardedfor:-	req:GET / HTTP/1.1	status:200	size:26354referer:-		ua:curl/7.54.0	reqtime:0.000	cache:-	runtime:-	vhost:localhost
```

lltsvを使った抽出も容易です。

```sh
echo 'time:07/Jul/2018:07:31:38        +0000   host:172.19.0.1 forwardedfor:-  req:GET / HTTP/1.1      status:200      size:26354referer:-             ua:curl/7.54.0  reqtime:0.000   cache:- runtime:-       vhost:localhost' | lltsv -k time
time:07/Jul/2018:07:31:38
```

## why error_log cannot apply log format

ここでnginx access_logはformat指定できるものの、error_logにfomratが適用できないのはどんなkeyとvalueかわからないからかな？

https://docs.nginx.com/nginx/admin-guide/monitoring/logging/

### access_log

https://github.com/nginx/nginx/blob/master/src/http/modules/ngx_http_log_module.c

- http, streamでmodule化されている
- access_logで利用できる変数がそれぞれ定義されている
- 標準ログにどのようなものを出力させるかはユーザーに一任されている

### error_log

https://github.com/nginx/nginx/blob/master/src/core/ngx_log.c

- coreに含まれている
- errorは引き渡されたerror levelとmessageを処理して出力するだけ


