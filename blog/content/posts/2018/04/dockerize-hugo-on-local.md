+++
date = "2018-04-29T15:00:00+09:00"
title = "Dockerize hugo on local"
tags = ["hugo", "docker", "blog"]
categories = ["programming"]
+++

blogをtumblerから[hugo](https://github.com/gohugoio/hugo) に移す。

それにともない、まずはlocal開発環境のdockerize。

## ちょっとはまったところ

そりゃそうだよねってところなのですが

1. dinghy(docker-machine)経由でアクセスするので、assetsの表示を直す
1. hugoの組み込みサーバーはlocalhostをdefaultでbindしている

ここらへんはbaseURLとbindを指定することで解決。

```yaml
# docker-compose.yml

version: "3"
services:
  blog:
    build:
      context: .
    volumes:
      - .:/app
    ports:
      - "1313:1313"
    command: ["hugo", "server", "--baseURL=http://${DOCKER_HOST_IP}:1313", "--bind=0.0.0.0"]
```

watcherが期待通り動いていないので、そこは後日
