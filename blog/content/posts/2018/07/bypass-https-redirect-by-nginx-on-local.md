+++
date = "2018-07-07T15:00:00+09:00"
title = "Bypass https redirect by nginx on local"
tags = ["nginx", "docker", "entrykit"]
categories = ["programming"]
+++

現在のblogでは以下のようなredirect処理を追加しています。

```sh
    # redirect http to https
    if ($http_x_forwarded_proto = "http") {
        rewrite  ^/(.*)$  https://$host/$1 redirect;
    }
```

これは以下を目的としています。

1. 鍵をnginxで管理せず、GCPのloadbalancerで管理する。
1. また、https通信の複合処理はGCPで行い、そこから後ろはhttpでアクセスしたい。
1. このとき、blogはhttps通信しか許可しない。
1. そのため、ユーザーのrequest時のprotocolがhttpであるかどうかnginxで判断し、httpの場合はhttpsにredirectする

localでわざわざ証明書を準備して作業するのもとても面倒。つまり

```
＿人人人人人人人＿
＞　localで邪魔　＜
￣Y^Y^Y^Y^Y^Y^Y^￣
```

## bypass redirect ideas

bypassするには以下のような方法がわかりやすいのですが、それぞれに問題があります。

1. local用のconf + dockerfileを分ける
  - 管理が手間ですし、本番設定ファイルとの乖離が発生するリスクが十二分にあります
1. 環境変数を使ってredirectしないよう処理を分岐する
  - nginxのperl moduleもしくはlua moduleを利用しなければnginxで環境変数を利用することができない

そういえば自社でやっている方法やれば良いですね、環境変数とentrykitを利用してconfを制御するようにします。

## templating by entrykit

[entrykit](https://github.com/progrium/entrykit) は以下のようなツールです。

> Entrypoint tools for elegant containers.
> Entrykit takes common tasks you might put in an entrypoint start script and lets you quickly set them up in your Dockerfile. It's sort of like an init process, but we don't believe in heavyweight init systems inside containers. Instead, Entrykit takes care of practical tasks for building minimal containers.

端的にいうと、template renderingからprehookでcontainer起動時に何か処理するなど行う事ができます。

templateの処理には以下のような関数を利用することが出来ます

- [sigil: github.com/gliderlabs/sigil/builtin](https://godoc.org/github.com/gliderlabs/sigil/builtin)
- [Go - Package template](https://golang.org/pkg/text/template)

nginx.conf.tmpl を以下のように修正します。 DEBUG環境変数が与えられているときはredirect処理を提供しません。

```diff
+   {{ if var "DEBUG" }}
+   {{ else }}
    # redirect http to https
    if ($http_x_forwarded_proto = "http") {
        rewrite  ^/(.*)$  https://$host/$1 redirect;
    }
+   {{ end }}
```

build image

```diff
+ ENV ENTRYKIT_VERSION 0.4.0
+ RUN apk add --no-cache --virtual build-dependencies curl tar \
+   && curl -SLo entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz https://github.com/progrium/entrykit/releases/download/v${ENTRYKIT_VERSION}/entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz \
+   && tar xvzf entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz \
+   && rm entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz \
+   && apk del --purge build-dependencies \
+   && mv entrykit /bin/entrykit \
+   && chmod +x /bin/entrykit \
+   && entrykit --symlink

COPY --from=build /site/public /usr/share/nginx/html
COPY ./nginx/blog.conf.tmpl /etc/nginx/conf.d/default.conf.tmpl
COPY ./nginx/nginx.conf.tmpl /etc/nginx/nginx.conf.tmpl

+ ENTRYPOINT [ \
+   "render", "/etc/nginx/conf.d/default.conf", "--", \
+   "render", "/etc/nginx/nginx.conf", "--" \
+   ]
```

docker-compose.yaml

```diff
  nginx:
    build:
      context: .
      dockerfile: Dockerfile
+    environment:
+      DEBUG: 1
    ports:
      - 8888:8080
```

少し幸せになれました。
