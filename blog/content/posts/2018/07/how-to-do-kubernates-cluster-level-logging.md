+++
date = "2018-07-14T14:00:00+09:00"
title = "How to do kubernates cluster-level logging?"
tags = ["k8s", "kubernates", "logging"]
categories = ["programming"]
+++

kubernatesのcluster上でlog集約をどうするべきか考えてみます。

```txt
nginx prometheus grafana
  |       |         |
  -------------------
          |
   ココらへんどうしよう？
          |
  -------------------
  |       |         |
bigquery gcs  papertrail/stackdriver
          |
     spark(data proc)
```

## default logging architecutre on kubernates

まず、kubernates標準ではどのようなログ集約を行っているのか調べます。

> The easiest and most embraced logging method for containerized applications is to write to the standard output and standard error streams.
> ...
> By default, if a container restarts, the kubelet keeps one terminated container with its logs. If a pod is evicted from the node, all corresponding containers are also evicted, along with their logs.

![](https://d33wubrfki0l68.cloudfront.net/59b1aae2adcfe4f06270b99a2789012ed64bec1f/4d0ad/images/docs/user-guide/logging/logging-node-level.png)

1. stdout, stderrに吐はれてnodeにそのログがたまる。
1. `/var/log`, `/var/log/docker` 配下にlogが蓄積し、logrotateして管理している。

シンプルです。

## Cluster-level logging architectures on kubernates

> While Kubernetes does not provide a native solution for cluster-level logging

kubernatesはdefaultでcluster-levelのlogを集約したりする方法を提供していないので、自前でlog aggregateする必要があることがわかります。

ここらへんは各cloud vendorでログ集約アーキテクチャが異なるから無い方針なんでしょうか？ :thinking:

### Approaches

大きく3つの方法で実現方法があります。

1. 各nodeにagentいれて走らせる
    - application -> stdout,stderr <- logger agent -> logging backend
1. podにlogging用side car containerをつけて集約
    - application -> sidecar -> stdout,stderr <- logger agent -> logging backend
    - application -> ssidecar -> logging backend
1. applicationからlog serviceに直接送る
    - application -> logging backend

kubernatesには、log集約のapproachが綺麗にまとまっていたので良いですね！

しかし、docker logdriverで直接送るようなパターンが書かれていないのは、接続先がdownしたときにcontainerが落ちてしまうような事態を避けるためにも推奨していないのでしょう。

## Using a node logging agent

![](https://d33wubrfki0l68.cloudfront.net/2585cf9757d316b9030cf36d6a4e6b8ea7eedf5a/1509f/images/docs/user-guide/logging/logging-with-node-agent.png)

> Using a node-level logging agent is the most common and encouraged approach for a Kubernetes cluster,
> ...
> it doesn’t require any changes to the applications running on the node.
> ...
> However, node-level logging only works for applications’ standard output and standard error.


最も一般的な方法。稼働しているapplicationに一切変更することなく、log aggregateすることができる。

そのかわり、stdout, stderrでしかエラーを出力できない。

## Using a sidecar container with the logging agent: Streaming sidecar container

![](https://d33wubrfki0l68.cloudfront.net/c51467e219320fdd46ab1acb40867b79a58d37af/b5414/images/docs/user-guide/logging/logging-with-streaming-sidecar.png)

> This approach allows you to separate several log streams from different parts of your application,
> some of which can lack support for writing to stdout or stderr.

sidecar container を使うことで、ログストリームを分けることができる。

考えられる使い所としては、applicationでデータを直接送るのではなく、fluentdなりをsidecar containerとして立ててbufferingやretryを制御したいとき良さそうです。

> it’s recommended to use stdout and stderr directly and leave rotation and retention policies to the kubelet.

stdout, stderrを直接使ったほうが良く。自前でローテートとかするとpolicyわかれちゃうもんね。うん。

## Using a sidecar container with the logging agent: Sidecar container with a logging agent

![](https://d33wubrfki0l68.cloudfront.net/d55c404912a21223392e7d1a5a1741bda283f3df/c0397/images/docs/user-guide/logging/logging-with-sidecar-agent.png)

考えられる使い所:

- ロストしてはいけない重要なデータストリームを分ける。
- こうすることで、負荷とかそこらへんがhandleしやすくて良い。
- nodeのscalein/outが激しいのでnode上のログを見ておくのが辛い

Using a node logging agent アプローチと組み合わせて使うことが一般的かな？思う（うちはそう）

### Exposing logs directly from the application

![](https://d33wubrfki0l68.cloudfront.net/0b4444914e56a3049a54c16b44f1a6619c0b198e/260e4/images/docs/user-guide/logging/logging-from-application.png)

applicationとstickeyになるのであまりおすすめしないアプローチだと思います。

とはいえ、いくつかメリットもある？

1. node levelのscalein/outに対して気遣いが不要となる
1. podのscale out/inに対して sidecar containerの終了に係る気遣いが不要となる

リアルタイムにすべてのデータを受け付けられ、落ちないlogging backendがあるのであれば、この方法もありだと思います。

## どのアプローチを採用するか？

https://12factor.net/logs に乗っ取るのであれば、

1. Using a node logging agent アプローチを採用する
1. applicationからログのparse, buffering, retry処理を切り離したいのであれば、Streaming sidecar container を一緒に採用する

## How to GKE -> stackdriver?

GKEのデフォルトでは、logがstackdriverに送られている。

こんな感じ

```txt
I  GET 200 10.31 KB null Go-http-client/1.1 https://grafana.threetreeslight.com/login GET 200 10.31 KB null Go-http-client/1.1 
I  GET 200 26.02 KB null Go-http-client/1.1 https://threetreeslight.com/ GET 200 26.02 KB null Go-http-client/1.1 
I  GET 200 10.31 KB null Go-http-client/1.1 https://grafana.threetreeslight.com/login GET 200 10.31 KB null Go-http-client/1.1 
I  GET 200 26.02 KB null Go-http-client/1.1 https://threetreeslight.com/ GET 200 26.02 KB null Go-http-client/1.1 
```

### 構成を確認する

```sh
% kubectl get deployment,ds,pod --namespace=kube-system
NAME                                          DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deployment.extensions/event-exporter-v0.1.8   1         1         1            1           55d
deployment.extensions/heapster-v1.4.3         1         1         1            1           55d
deployment.extensions/kube-dns                1         1         1            1           55d
deployment.extensions/kube-dns-autoscaler     1         1         1            1           55d
deployment.extensions/kubernetes-dashboard    1         1         1            1           55d
deployment.extensions/l7-default-backend      1         1         1            1           55d

NAME                                      DESIRED   CURRENT   READY     UP-TO-DATE   AVAILABLE   NODE SELECTOR                              AGE
daemonset.extensions/fluentd-gcp-v2.0.9   1         1         1         1            1           beta.kubernetes.io/fluentd-ds-ready=true   55d

NAME                                                   READY     STATUS    RESTARTS   AGE
pod/event-exporter-v0.1.8-599c8775b7-qthr8             2/2       Running   0          41d
pod/fluentd-gcp-v2.0.9-8mm85                           2/2       Running   0          41d
pod/heapster-v1.4.3-f9f9ddd55-n8cnf                    3/3       Running   0          41d
pod/kube-dns-778977457c-68gsl                          3/3       Running   0          41d
pod/kube-dns-autoscaler-7db47cb9b7-p2f8p               1/1       Running   0          41d
pod/kube-proxy-gke-blog-cluster-pool-1-767a6361-7t2r   1/1       Running   0          41d
pod/kubernetes-dashboard-6bb875b5bc-t8r4n              1/1       Running   0          41d
pod/l7-default-backend-6497bcdb4d-8s5lq                1/1       Running   0          41d
```

あっfluetndがdaemonsetで動いている

### GEK logging with fluentd

どのような設定かも確認するしていく

#### daemonset

fluentdはnodeの `/var/log`, `/var/lib/docker/containers/` をmountすることでlogをwatchしている

https://github.com/kubernetes/kubernetes/blob/master/cluster/addons/fluentd-gcp/fluentd-gcp-ds.yaml

```yaml
    spec:
      priorityClassName: system-node-critical
      serviceAccountName: fluentd-gcp
      dnsPolicy: Default
      containers:
      - name: fluentd-gcp
        image: gcr.io/stackdriver-agents/stackdriver-logging-agent:{{ fluentd_gcp_version }}
        volumeMounts:
        - name: varlog
          mountPath: /var/log
        - name: varlibdockercontainers
          mountPath: /var/lib/docker/containers
          readOnly: true
```

#### fluentd conf

https://github.com/kubernetes/kubernetes/blob/master/cluster/addons/fluentd-gcp/fluentd-gcp-configmap.yaml

container input

```yaml
  containers.input.conf: |-
    ...
      @type tail
      path /var/log/containers/*.log
```

sysmte input

```yaml
  system.input.conf: |-
    ...
    # logfile
      path /var/log/startupscript.log
      path /var/log/docker.log
      path /var/log/etcd.log
      path /var/log/kubelet.log
      path /var/log/kube-proxy.log
      path /var/log/kube-apiserver.log
      path /var/log/kube-controller-manager.log
      path /var/log/kube-scheduler.log
      path /var/log/rescheduler.log
      path /var/log/glbc.log
      path /var/log/cluster-autoscaler.log

    # systemd
      filters [{ "_SYSTEMD_UNIT": "docker.service" }]
      pos_file /var/log/gcp-journald-docker.pos

      filters [{ "_SYSTEMD_UNIT": "{{ container_runtime }}.service" }]
      pos_file /var/log/gcp-journald-container-runtime.pos

      filters [{ "_SYSTEMD_UNIT": "kubelet.service" }]
      pos_file /var/log/gcp-journald-kubelet.pos

      filters [{ "_SYSTEMD_UNIT": "node-problem-detector.service" }]
      pos_file /var/log/gcp-journald-node-problem-detector.pos

      pos_file /var/log/gcp-journald.pos
```

output

```yaml
  output.conf: |-
  ...
    <match {stderr,stdout}>
      @type google_cloud
```

### カスタマイズは？

設定変更やカスタマイズは、daemonsetやconfigをいじれば良い

- [GCP - Customizing Stackdriver Logs for Kubernetes Engine with Fluentd](https://cloud.google.com/solutions/customizing-stackdriver-logs-fluentd)
- [kubernates - Logging Using Stackdriver](https://kubernetes.io/docs/tasks/debug-application-cluster/logging-stackdriver/)


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

こういうのもありかも？

```sh
nginx prometheus grafana
  |       |         |
  -------------------
         |||
  node logging agent(fluentd)
         |||
  logging aggregater(fluentd cluster)
          |
  -------------------
  |       |         |
bigquery gcs  papertrail/stackdriver
```

そもそも

1. nodeごとにあるfleutnd設定いじるのって正しいの？
1. nodeにあるfluentdを触ると、配置されるpodによってnodeごとのfluentd負荷が変わっちゃうだろうけど、致し方ないのだろうか？

papertrailやdatadog loggingあたりにつなぎこむんであればnode logging agentをカスタマイズするのありな認識。

## まとめ

1. Using a node logging agent アプローチを採用する
1. applicationからログのparse, buffering, retry処理を切り離したいのであれば、Streaming sidecar container も採用する
1. gcpのstackに乗るんであればstackdriver exportを使ってデータ加工することが望ましい
1. node logging agentの設定カスタマイズは趣味やpapertrailやdatadog loggingなど別基盤に流すときぐらいにしかつかわない

## ref

- [kubernates - Logging Architecture](https://kubernetes.io/docs/concepts/cluster-administration/logging/)
- [docker - logdriver](https://docs.docker.com/config/containers/logging/configure/#configure-the-logging-driver-for-a-container)
- [gcp - export](https://cloud.google.com/logging/docs/export/)
- [github - GoogleCloudPlatform/k8s-stackdriver](https://github.com/GoogleCloudPlatform/k8s-stackdriver)
