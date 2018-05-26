+++
date = "2018-05-26T15:00:00+09:00"
title = "Automate build image and rolling update on kubernates"
tags = ["gcp", "kubernates", "deploy", "container", "rolling-update"]
categories = ["programming"]
+++

もろもろ環境が整ったところで、ciでのimage build and push と kubernates上で稼働するcotainerのrolling updateを行う。

## Automate image build and push

multi-stage buildを使いたかったので組み込みつつ、ci上でbuildを通すようにした。

dockerfileはこんな感じ。

```dockerfile
FROM alpine:latest AS build
LABEL maintainer "threetreeslight"
LABEL Description="hugo docker image" Vendor="threetreeslight" Version="0.1"

ENV HUGO_VERSION 0.40.1

RUN apk update \
  && apk upgrade \
  && apk add --no-cache ca-certificates curl \
  && update-ca-certificates \
  && cd /tmp \
  && curl -L https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz -o ./hugo_${HUGO_VERSION}_Linux-64bit.tar.gz \
  && tar xvzf ./hugo_${HUGO_VERSION}_Linux-64bit.tar.gz \
  && mv /tmp/hugo /usr/local/bin \
  && rm -rf /var/cache/apk/* \
  && rm -rf /tmp/* /var/tmp/*

COPY ./blog /site
RUN cd /site && mkdir ./public && hugo


FROM nginx:mainline-alpine
LABEL maintainer "threetreeslight"
LABEL Description="threetreeslight's blog image" Vendor="threetreeslight" Version="0.1"

COPY --from=build /site/public /usr/share/nginx/html
COPY ./nginx/blog.conf.tmpl /etc/nginx/conf.d/default.conf
COPY ./nginx/nginx.conf.tmpl /etc/nginx/nginx.conf
```

そうすることでbuildがめっちゃシンプルに、なおかつimageもconpactに！便利！

```yaml
version: 2
jobs:
  build:
    docker:
      - image: circleci/golang:latest
    steps:
      - checkout
      - run: git submodule update --init
      - setup_remote_docker:
          docker_layer_caching: true
      - run:
          name: build and push blog image
          command: |
            IMAGE_NAME=threetreeslight/blog
            docker build -t $IMAGE_NAME:$CIRCLE_SHA1 -t $IMAGE_NAME:latest .

            docker login -u threetreeslight -p $DOCKER_PASS
            docker push $IMAGE_NAME:$CIRCLE_SHA1
            docker push $IMAGE_NAME:latest
```

## rolling update container image

上記で勝手にbuild and pushされるようになったcontainer image。

そのcontainer imageの更新に合わせて、kubernatesで管理されているpodのcontainerも更新されるようにする。

事前にココらへんを読んでおくと良いです。

- [Kubernetes Engine - ステートレス アプリケーションのデプロイ](https://cloud.google.com/kubernetes-engine/docs/how-to/stateless-apps)
- [Kubernetes Engine - ローリング更新を実行する](https://cloud.google.com/kubernetes-engine/docs/how-to/updating-apps)
- [kubernates - Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)

実現したいことと制約は以下の２つ

1. master branchのbuild後、速やかにrolling updateが行われてほしい
1. kubernatesのdeploymentにおいて、yaml上のimage変更なく、rolling updateを行いたい

set commandを使ってkuberneates上のdeploymentに変更を与えつつ、yaml上は `latest` tagのimageを利用しておくのがよさそう。

```bash
$ kubectl set image deployment blog blog=threetreeslight/blog:2dbe31290728920311efcd1992c3a34e2fe0373c

$ watch -n 3 kubectl get pods
Every 3.0s: kubectl get pods                                                                                                                                                                     ae06710-mpb13.local: Sat May 26 17:38:41 2018

NAME                    READY     STATUS              RESTARTS   AGE
blog-7b9cd4b7c7-9ph8f   0/1       Terminating         0          34m
blog-8547868bd8-jmjct   0/1       ContainerCreating   0          2s
```

うん、更新されてる。

流れとしては以下の方針で行く。

1. build
  1. deployment.ymlはmasterなどの固定のimage tagを参照するようにしておく
  1. imageのtagには環境に応じて期待する固定image tagとgit sha1を設定し、pushしておく
1. deploy
  1. kubectlの `set` を利用してrolling updateを発火させる


## set container tag by ci

おおむね行かに書いてあるとおりやれば良い。 `google/cloud-sdk` image 便利！

https://circleci.com/docs/2.0/google-container-engine/


`circleci.yaml` は概ねこんな感じになるだろう

```yaml
...

  # see also https://circleci.com/docs/2.0/google-container-engine/
  deploy:
    docker:
      - image: google/cloud-sdk:latest
    environment:
      GOOGLE_PROJECT_ID: "threetreeslight"
      GOOGLE_COMPUTE_ZONE: "us-west1-a"
      GOOGLE_CLUSTER_NAME: "blog-cluster"
    steps:
      - run:
          name: Store Service Account
          command: echo $GCLOUD_SERVICE_KEY > ${HOME}/gcloud-service-key.json
      - run:
          name: Setup gcloud
          command: |
            gcloud auth activate-service-account --key-file=${HOME}/gcloud-service-key.json
            gcloud --quiet config set project ${GOOGLE_PROJECT_ID}
            gcloud --quiet config set compute/zone ${GOOGLE_COMPUTE_ZONE}
            gcloud --quiet container clusters get-credentials ${GOOGLE_CLUSTER_NAME}

            # modify blog image tag to rolling update
            kubectl set image deployment blog blog=threetreeslight/blog:$CIRCLE_SHA1
```
