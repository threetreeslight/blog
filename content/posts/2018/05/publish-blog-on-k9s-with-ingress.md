+++
date = "2018-05-19T18:00:00+09:00"
title = "publish blog on k9s with ingress"
tags = ["gcp", "kubanetis", "k9s", "container", "ingress", "https"]
categories = ["programming"]
+++

gcs上での展開が完了したのと、gcpでのloadbalancingも含めて大体わかってきたので、このblogをgkeを利用してcotnainer運用してみようと思う

## 構成

多分こんな感じになるだろうと考えて作業

forwarding rule <-> target proxy <-> url-map <-> backend-service <-> node ip <-> pod

## Create blog image

展開するためのcontaienrを作成する。

まずはnginxまわりを設定

### nginx.conf

volumeを圧迫しないように、error_log, access_logを `/dev` つなぎこむ

```
user  nginx;
worker_processes  1;

error_log  stderr info;
pid        /var/run/nginx.pid;

events {
    worker_connections  1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log    /dev/stdout;
    sendfile        on;
    keepalive_timeout  65;

    include /etc/nginx/conf.d/*.conf;
}
```

### blog.conf

8080 portでアクセスを受けるようにする

```
server {
    listen       8080;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }

    error_page   404              /404.html;
    error_page   500 502 503 504  /50x.html;

    location = /(404|50x).html {
        root   /usr/share/nginx/html;
    }
}
```

### dockerfile

confをcopyしつつ、buildしたblog contatentsを固める

```docker
FROM nginx:mainline-alpine

COPY ./public /usr/share/nginx/html
COPY ./nginx/blog.conf.tmpl /etc/nginx/conf.d/default.conf
COPY ./nginx/nginx.conf.tmpl /etc/nginx/nginx.conf
```

build and publish

```
docker build -t threetreeslight/blog
docker push threetreelsight/blog
```

## Prepare to use gke

まずk9sを操作するためには[kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)を利用するのでそれを入れる

これはgcp cliを利用していれることができる


```sh
# https://kubernetes.io/docs/tasks/tools/install-kubectl/
$ brew install kubectl
```

また、実際にk9sを触ってみる[quick start](https://cloud.google.com/kubernetes-engine/docs/quickstart) があるので、これを触っておくと良い。

## create cluster, pods

blogを公開するためのclusterを作成する

```sh
% gcloud container clusters create blog-cluster --no-enable-autorepair
WARNING: Starting in Kubernetes v1.10, new clusters will no longer get compute-rw and storage-ro scopes added to what is specified in --scopes (though the latter will remain included in the default --scopes). To use these scopes, add them explicitly to --scopes. To use the new behavior, set container/new_scopes_behavior property (gcloud config set container/new_scopes_behavior true).
Creating cluster blog-cluster...done.
Created [https://container.googleapis.com/v1/projects/threetreeslight/zones/us-west1-a/clusters/blog-cluster].
To inspect the contents of your cluster, go to: https://console.cloud.google.com/kubernetes/workload_/gcloud/us-west1-a/blog-cluster?project=threetreeslight
kubeconfig entry generated for blog-cluster.
NAME          LOCATION    MASTER_VERSION  MASTER_IP       MACHINE_TYPE   NODE_VERSION  NUM_NODES  STATUS
blog-cluster  us-west1-a  1.8.10-gke.0    35.199.155.107  n1-standard-1  1.8.10-gke.0  3          RUNNING
```

clusterの認証情報を渡す

```sh
% gcloud container clusters get-credentials blog-cluster
Fetching cluster endpoint and auth data.
kubeconfig entry generated for blog-cluster
```

これでkubectlの操作を上記で作成したclusterに対して実行できるようになります。


## create deployment

続いてdeploymentを作成する。docker-composeやECSでいうtaskが近い。

```yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  labels:
    app: blog
  name: blog
  namespace: default
  selfLink: /apis/extensions/v1beta1/namespaces/default/deployments/blog
spec:
  replicas: 1
  selector:
    matchLabels:
      app: blog
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
    type: RollingUpdate
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: blog
    spec:
      containers:
      - image: threetreeslight/blog:latest
        imagePullPolicy: Always
        name: blog
        ports:
        - containerPort: 8080
          protocol: TCP
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      terminationGracePeriodSeconds: 30
```

上記で作成したdeploymentをkubectlに適用します

```
% kubectl apply -f blog-pod.yaml
% kubectl get po,deploy
NAME                        READY     STATUS    RESTARTS   AGE
pod/blog-8547868bd8-brpsr   1/1       Running   0          9h

NAME                         DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deployment.extensions/blog   1         1         1            1           2d
```

うん、podが1つ稼働していることがわかります。

このdeploymentに対し、外部に公開しアクセスできるようにしてみます。

```sh
$ kubectl expose deployment blog --type "LoadBalancer"
$ kubectl get service blog

NAME      TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)        AGE
blog      LoadBalancer   10.59.242.212   35.233.232.33   80:32439/TCP   52s
```

上記のようにexternal-ipが割り当てられます。
これはexpose commandを通して公開用loadbalancerが作成されたことがわかります。

なんて便利。

一旦個々まで

アクセスしてみる。loadbalancerで経由でアクセスできることがわかったので一旦削除する


```
kubectl expose deployment blog --target-port=8080 --type=NodePort
```

GKEはclusterに直接loadbalancerを接続して公開できるのね

## support https

`expose type "loadbalancer"` では、http forwarding ruleしか作られないことがみるとわかります。

こうするとhttpsでアクセスが出来ません。

loadbalancerにおけるbackend serivceから後ろは以下のような処理になっているイメージです。

```
backend service <-> cluster_ip:port <-> pods
```

1. bakcend serviceによって特定cluster ipの特定port宛に通信がproxyされる
1. cluster_ip, portの情報を元にk9sはどのservice(port)にproxyすればよいか決定される
1. proxyされた通信はserviceとdyanmic port mappingされたpodsにproxyされる
  1. replicaが2以上のときはどんなルールでproxyされるかはdeploymentに記述できる（と思う）

そのため、あくまでexposeの処理は、`cluster_ip:port` の割り当てまでに留め、loadbalancerの設定は別で行う必要が考えられます。

ここで必要となってくるのがingressです。


## Ingressを利用したloadbalancerの作成

[ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)とは？

> Ingress は、外部 HTTP(S) トラフィックを内部サービスにルーティングするためのルールと設定の集合をカプセル化する Kubernetes リソースです。

です。

[Ingress での HTTP 負荷分散の設定](https://cloud.google.com/kubernetes-engine/docs/tutorials/http-balancer)をやっておくと良いです。


まずは、DNS record、およびloadbalancerのエンドポイントとして利用するipを払い出します。

```
% gcloud compute addresses create blog-gke --global
% gcloud compute addresses list
NAME                          REGION  ADDRESS        STATUS
blog-gke                              35.201.67.24   RESERVED
```

続いて、blog serviceをnodeport modeでexposeします。



```sh
% kubectl expose deployment blog --target-port=8080 --type=NodePort
% kubectl get po,deploy,service
NAME                        READY     STATUS    RESTARTS   AGE
pod/blog-8547868bd8-brpsr   1/1       Running   0          9h

NAME                         DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deployment.extensions/blog   1         1         1            1           2d

NAME                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
service/blog         NodePort    10.59.253.98   <none>        8080:31453/TCP   10h
```

clusteripとportの割り当てができている。良い。

続いてingress resourceの作成をします。httpsアクセスをしたいので、[登録されているtls証明書を設定](https://kubernetes.io/docs/concepts/services-networking/ingress/#tls)します。

blog-ingress.yaml

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: blog
  annotations:
    kubernetes.io/ingress.global-static-ip-name: blog-gke
spec:
  tls:
  - secretName: threetreeslight-com
  backend:
    serviceName: blog
    servicePort: 8080
```

適用します

```sh
% kubectl apply -f blog-ingress.yaml
% kubectl get ingress blog
NAME      HOSTS     ADDRESS        PORTS     AGE
blog      *         35.201.67.24   80, 443   10h
```

80, 443 portが公開され、addressも作成たexternal ipが設定されていることがわかります。




## のこり

- log driverはdefaultでstackdriverかな？
  - podsにfluentdかましてpub/subに送る感じにして、そこからbigqueryにデータを飛ばすように仕様
  - 普通に考えたらstackdriver -> bigqueryとかでいけそうだけど
- nginxとblog fileを持つstatic file containerを分離して
  - 1 hostに1 blog file containerしか動かないようにcontaienrの配置戦略を調整
  - nginx containerはstatic file contaienrをmountするように配置するとvolume sizeを削減できる
  - やる意味いっさいないけど





https://kubernetes.io/docs/concepts/services-networking/ingress/#tls
