+++
date = "2018-04-30T20:08:00+09:00"
title = "build hugo on ci"
tags = ["hugo", "ci", "circleci"]
categories = ["programming"]
+++

deployに備えてblogのci環境を構築する。

[stackshare - ci](https://stackshare.io/continuous-integration) を見る限りcircleciがshare的にも無難。

とはいえ、使い慣れたツールっていうのも味気ないが、将来的には[concourse ci](https://concourse-ci.org/) に載せ替えるとしてとりあえずはcircleciを利用する。

circleciで準備されたimageを利用するのだが、その中でやれ何かをinstallするとか辛いし時間がもったいない。
速さは正義なので、imageをpullしてcodeをmountし、buildするという流れが望ましい。

## create docker image

まずhugoが稼働するdocker imageをつくる。
世にあるやつがメンテナンスされていないのと、host側の設定をcopyするようなものだったので、動きやすさを含めて自分で作成。

https://hub.docker.com/r/threetreeslight/docker-hugo/

## executer type どうするか？

executerをdockerで動かしたときに、container内にcheck-outしたfileをどうやってmountするか。

circleciを見る限りvolumeを共有することは困難である。そりゃそうだよね。

https://circleci.com/docs/2.0/executor-types/#using-docker

とはいえmachineを使うと Start time が `30-60 sec` という。
このリードタイムは許せない。

## Remote Docker

そこで見つけたのがRemote Dockerという機能

https://circleci.com/docs/2.0/building-docker-images/

> To build Docker images for deployment, you must use a special setup_remote_docker key which creates a separate environment for each build for security. This environment is remote, fully-isolated and has been configured to execute Docker commands. If your build requires docker or docker-compose commands, add the setup_remote_docker step into your .circleci/config.yml:

そう、こういう感じ。

と思って読み進めていくと `Mounting Folders` に悲しい記述が、、、

https://circleci.com/docs/2.0/building-docker-images/#mounting-folders

> It’s not possible to mount a folder from your job space into a container in Remote Docker (and vice versa). But you can use docker cp command to transfer files between these two environments. For example, you want to start a container in Remote Docker and you want to use a config file from your source code for that:

そりゃそうですよね。
workaroundとしてdummyのdocker containerを用意して、そこにファイルをcopyする。そのvolumeを起動したいdocker containerのvolumeとしてmountして利用する方法らしい。

やってみたけどこれは辛い、、、。

```sh
- run: |
    docker create -v /site --name site alpine:3.4 /bin/true
    docker cp $PWD site:/site
    docker run --volumes-from site threetreeslight/docker-hugo:latest
```

素直にmachine上で素直にdocker pullしてbuildすれば良いかもしれない


```sh
  build:
    steps:
      - checkout
      - run: docker run -it --rm -v $PWD:/site threetreeslight/docker-hugo hugo
```

ってmachineのstart time + pullのじ感食うとかもっと嫌だ。

## 最も無難で高速なのは

executor をdockerにして、hugoをcacheしておけば早いよねって話になりそう。

```sh
version: 2
jobs:
  build:
    docker:
      - image: circleci/golang:1.9
    environment:
      HUGO_VERSION: 0.40.1
    steps:
      - checkout
      - run: echo $HUGO_VERSION > ~/HUGO_VERSION
      - restore_cache:
          key: hugo-{{ checksum "~/HUGO_VERSION" }}
      - run:
          name: Install hugo
          command: |
              if [ ! -e ~/hugo ]; then
                mkdir ~/hugo
                cd ~/hugo
                curl -L https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz -o ./hugo_${HUGO_VERSION}_Linux-64bit.tar.gz
                tar xvzf ./hugo_${HUGO_VERSION}_Linux-64bit.tar.gz
              else
                echo "already hugo exists"
              fi
      - save_cache:
          key: hugo-{{ checksum "~/HUGO_VERSION" }}
          paths:
            - ~/hugo
      - run:
          name: build hugo
          command: ~/hugo/hugo
```

## tips: cache keyにenviromentを使うことが出来ない

[Cannot use circle.yml environment variables in cache keys](https://discuss.circleci.com/t/cannot-use-circle-yml-environment-variables-in-cache-keys/10994)

`Environment.HGO_VERSION` とかやっていけたらよいのにいけない。

この問題を解決するためには、ファイルに環境変数を書き出してchecksumを取るというworkaroundをするしかない模様。

