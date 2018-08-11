+++
date = "2018-07-15T14:00:00+09:00"
title = "Custermize node logging agent on GKE"
tags = ["k8s", "kubernates", "GKE", "logging"]
categories = ["programming"]
draft = "true"
+++

## stackdriver -> gcs, bqすればよいのでは？

```sh
nginx prometheus grafana
  |       |         |
  -------------------
         |||
  node logging agent(fluentd)
         |||
      stack driver
          |
      cloud pubsub
          |
  -------------------
  |       |         |
bigquery gcs  papertrail/stackdriver
```

## concern data lost on fluentd

node logging agentであるfluentdを終了するときにはいくつか気をつけなければいけないことがある

### buffer lost

fluentd containerを単純にSTOPすると以下のような問題があります。

1. SIGTERMがcontainerに送られる
1. container内で稼働するfluentdにSIGTERMが伝搬する
1. fluentdがmemory bufferのflushを試みる
1. **失敗してもretryしない**

この問題を解決するためには以下のような処理をする必要がある。

1. データの受付を停止
1. bufferのflushが完了していることを確認
1. 終了 :innocent:

see also: [Fluentd's Signal Handling](https://docs.fluentd.org/v0.12/articles/signals)

### forwarder data lost

直接データを送信している場合は、接続先のfluentdがdownしても問題ない状態を作らなければいけない

1. service discoveryを行い、生存しているlogging agentに自動で再接続されなければいけない
1. retryが適切になされなければいけない
1. その間、可能であれば処理が継続できなければい

### tips: how to resolve

fluentdのHA構成にておくことで、送信元の問題の解決も比較的容易である。

![](https://docs.fluentd.org/images/fluentd_ha.png)

see also: [Fluentd High Availability Configuration](https://docs.fluentd.org/v1.0/articles/high-availability)

### On Kubernates

kubernatesでは以下の戦略が一般的なので、flushさえ問題なくできれば大丈夫。

1. stdout, stderrに出力したデータをnodeに蓄積する
1. nodeに蓄積されたデータをnode logging agentが監視し、tailでデータを見る
1. tailではposがあるのでそこらへんは気にせず投げられる。

## tailの挙動を確認する

fluent.conf

```conf
<source>
  @type tail
  @id input_tail
  format json
  time_key time
  path /var/log/sample/*
  pos_file /var/log/sample/sample.log.pos
  time_format %Y-%m-%dT%H:%M:%S.%N%Z
  tag @sample
  read_from_head true
</source>

<match **>
  @type stdout
</match>
```

docker-compose.yaml

```yaml
version: "3"
services:
  fluentd:
    image: fluent/fluentd:latest
    volumes:
      - ./fluentd/sample:/var/log/sample
      - ./fluentd/etc:/fluentd/etc
```

testing

```sh
docker-compose up fluentd

echo '{ "foo": "foo" }' >> fluentd/sample/foo
fluentd_1            | 2018-07-21 05:12:29.158290300 +0000 @sample: {"foo":"foo"}

docker-compose down fluentd
docker-compose up fluentd

echo '{ "bar": "bar" }' >> fluentd/sample/foo
fluentd_1            | 2018-07-21 05:13:08.576539100 +0000 @sample: {"bar":"bar"}
```

期待通りfooが再度読まれるようなことがない。

- [input plugin - tail](https://docs.fluentd.org/v0.12/articles/in_tail)
- [output plugin - stdout](https://docs.fluentd.org/v0.12/articles/out_stdout)

## remote_syslog


```fluentd
<source>
  @type tail
  @id input_tail
  format json
  time_key time
  path /var/log/sample/*
  pos_file /var/log/sample/sample.log.pos
  time_format %Y-%m-%dT%H:%M:%S.%N%Z
  tag sample
  read_from_head true
</source>

<filter **>
  @type stdout
</filter>

<match **>
  @type remote_syslog
  @id papertrail
  host logs7.papertrailapp.com
  port 45121
  severity info
  program sample

  protocol tcp
  timeout 20
  timeout_exception true
  tls true
  ca_file /etc/papertrail-bundle.pem
  keep_alive true
  keep_alive_cnt 9
</match>
```

dockerfile

```dockerfile
FROM fluent/fluentd:v1.2.2

RUN apk --no-cache --update add \
    curl \
  && curl -sL -o /etc/papertrail-bundle.pem https://papertrailapp.com/tools/papertrail-bundle.pem \
  && fluent-gem install fluent-plugin-remote_syslog -v 1.0.0
```

https://papertrailapp.com/systems/88784915130b/events

![]()

## export already settings

以下のrepoを使うこともできるが、すでにfluentd daemonsetが動いているので、設定を吐き出すことにする

- [GoogleCloudPlatform/k8s-stackdriver](https://github.com/GoogleCloudPlatform/k8s-stackdriver)
- [GoogleCloudPlatform/container-engine-customize-fluentd](https://github.com/GoogleCloudPlatform/container-engine-customize-fluentd)
- [kubernetes/kubernetes - fluentd-gcp](https://github.com/kubernetes/kubernetes/blob/master/cluster/addons/fluentd-gcp/README.md)

既存設定を書き出す

```sh
# daemonset
% kubectl get ds --namespace kube-system | grep fluentd | awk '{ print $1 }'
fluentd-gcp-v2.0.9

% kubectl get ds fluentd-gcp-v2.0.9 --namespace kube-system -o yaml > fluentd/fluentd-gcp-ds.yaml
fluentd-gcp-v2.0.9

# fluentd conf
% kubectl get cm  --namespace kube-system | grep fluentd | awk '{ print $1 }'
fluentd-gcp-config-v1.2.2

kubectl get cm fluentd-gcp-config-v1.2.2 --namespace kube-system -o yaml > fluentd/fluentd-gcp-configmap.yaml
```

## enable logging customize

logging serviceを停止する

> Prerequisites
> If you’re using GKE and Stackdriver Logging is enabled in your cluster, you cannot change its configuration, because it’s managed and supported by GKE. However, you can disable the default integration and deploy your own. Note, that you will have to support and maintain a newly deployed configuration yourself: update the image and configuration, adjust the resources and so on. To disable the default logging integration, use the following command:

```
gcloud beta container clusters update --logging-service=none blog-cluster
```

## custome

- https://github.com/dlackty/fluent-plugin-remote_syslog

Dockerfile

```dockerfile
FROM gcr.io/google-containers/fluentd-gcp:2.0.9

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    curl \
  && curl -sL -o /etc/papertrail-bundle.pem https://papertrailapp.com/tools/papertrail-bundle.pem \
  && fluent-gem install fluent-plugin-remote_syslog -v 1.0.0
```

build and publish image script

```sh
timestamp=`date +%Y%m%d%H%M%S`

docker build -t threetreeslight/fluentd-gcp:$timestamp -f ./fluentd/Dockerfile .
docker tag threetreeslight/fluentd-gcp:$timestamp threetreeslight/fluentd-gcp:latest

echo "\nimage name is threetreeslight/fluentd-gcp:$timestamp\n"

docker push threetreeslight/fluentd-gcp:$timestamp
docker push threetreeslight/fluentd-gcp:latest
```

daemonset

```diff
apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  name: fluentd-gcp-v2.0.9
  namespace: kube-system
spec:
  template:
    spec:
      containers:
      - env:
        - name: FLUENTD_ARGS
          value: --no-supervisor -q
-        image: gcr.io/google-containers/fluentd-gcp:2.0.9
+        image: threetreeslight/fluentd-gcp:20180721153509
        imagePullPolicy: IfNotPresent
```

```sh
kubectl apply -f ./fluentd/fluentd-gcp-ds.yaml
```

https://papertrailapp.com/systems/88784915130b/events


```sh
% kubectl apply -f ./fluentd/fluentd-gcp-csutom-configmap.yaml
% kubectl apply -f ./fluentd/fluentd-gcp-custom-daemonset.yaml

% kubectl get deployment,daemonset,pod --namespace=kube-system
NAME                                         DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deployment.extensions/heapster-v1.4.3        1         1         1            1           63d
deployment.extensions/kube-dns               1         1         1            1           63d
deployment.extensions/kube-dns-autoscaler    1         1         1            1           63d
deployment.extensions/kubernetes-dashboard   1         1         1            1           63d
deployment.extensions/l7-default-backend     1         1         1            1           63d

NAME                                      DESIRED   CURRENT   READY     UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
daemonset.extensions/fluentd-gcp-v2.0.9   1         1         1         1            1           <none>          1m

NAME                                                   READY     STATUS    RESTARTS   AGE
pod/fluentd-gcp-v2.0.9-58c9j                           2/2       Running   0          1m
pod/heapster-v1.4.3-5ff458865f-gsqvd                   3/3       Running   0          7d
pod/kube-dns-778977457c-68gsl                          3/3       Running   0          48d
pod/kube-dns-autoscaler-7db47cb9b7-p2f8p               1/1       Running   0          48d
pod/kube-proxy-gke-blog-cluster-pool-1-767a6361-7t2r   1/1       Running   0          48d
pod/kubernetes-dashboard-6bb875b5bc-t8r4n              1/1       Running   0          48d
pod/l7-default-backend-6497bcdb4d-8s5lq                1/1       Running   0          48d
```

```
    <match **>
      @type copy

      <store>
        @type google_cloud

        detect_json true
        enable_monitoring true
        monitoring_type prometheus
        detect_subservice false
        buffer_type file
        buffer_path /var/log/fluentd-buffers/kubernetes.system.buffer
        buffer_queue_full_action block
        buffer_chunk_limit 1M
        buffer_queue_limit 2
        flush_interval 5s
        max_retry_wait 30
        disable_retry_limit
        num_threads 2
      </store>

+      <store>
+        @type remote_syslog
+        host <host>
+        port <port>
+        severity info
+        program ${tag[0]}
+
+        protocol tcp
+        timeout 20
+        timeout_exception true
+        tls true
+        ca_file /etc/papertrail-bundle.pem
+        keep_alive true
+        keep_alive_cnt 9
+      </store>
+    </match>
```

CrashLoopBackOff :sob:

```
2018-07-21 07:29:00 +0000 [error]: unexpected error error="Plugin is not a module"
```

fluentd-0.12.40なのか、、、

```
kubectl scale --replicas=0 daemonset/fluentd-gcp-v2.0.9 --namespace=kube-system
```


## ref

- [kubernates - Logging Architecture](https://kubernetes.io/docs/concepts/cluster-administration/logging/)
- [docker - logdriver](https://docs.docker.com/config/containers/logging/configure/#configure-the-logging-driver-for-a-container)
- [gcp - export](https://cloud.google.com/logging/docs/export/)
- [github - GoogleCloudPlatform/k8s-stackdriver](https://github.com/GoogleCloudPlatform/k8s-stackdriver)
- [GCP - Customizing Stackdriver Logs for Kubernetes Engine with Fluentd](https://cloud.google.com/solutions/customizing-stackdriver-logs-fluentd)
- [kubernates - Logging Using Stackdriver](https://kubernetes.io/docs/tasks/debug-application-cluster/logging-stackdriver/)
