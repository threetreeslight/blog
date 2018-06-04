+++
date = "2018-06-17T10:00:00+09:00"
title = "How to monitor node and container metrics on kubernates"
tags = ["gcp", "kubernates", "monitoring", "cAdvisor", "kubelet"]
categories = ["programming"]
+++

kubernatesそのものや、kubernates上で稼働するnodeやcontainerを監視するのにとりあえずprometheusとやってしまっていたが、どのようなmetricを取得できるのか？ちゃんと知ったほうが良さそう。

そのためにも、 [kubernates - Tools for Monitoring Compute, Storage, and Network Resources](https://kubernetes.io/docs/tasks/debug-application-cluster/resource-usage-monitoring/) を読み進めていく。

## Heapster

Kubernatesは [Heapster](https://github.com/kubernetes/heapster)を使ってログや各イベントの収集を行っているようだ。

ただ、当のHeapsterは以下の通りDeprecatedとなっている。

> DEPRECATED: Heapster is deprecated.
> Consider using metrics-server and a third party metrics pipeline to gather Prometheus-format metrics instead.
> See the deprecation timeline for more information on support.
> We will not be adding any new features to Heapster.

どうやらheapsterは廃止となり、prometheus formatのeventを処理するthird partyのメトリクス収集パイプラインを使うことを推奨しているようだ。
とはいえ、本ドキュメントを読んでどのような機構でmetric収集すべきか理解することは意味があるので読み進める。

Heapsterは各nodeに配置されたkubeletとcadvisorからデータを収集している。

イメージとしてはこんな感じ

```
Heapster <- kubelet <- cadvisor
```

これは、node_exporterやcAdvisorをdeamonsetとして各コンテナに配置する必要はすでにないことを意味する。

## cAdvisor

> In Kubernetes, cAdvisor is integrated into the Kubelet binary.
> cAdvisor auto-discovers all containers in the machine and collects CPU, memory, filesystem, and network usage statistics.
> cAdvisor also provides the overall machine usage by analyzing the ‘root’ container on the machine.

container metricを取得するagentです。

https://github.com/google/cadvisor

cAdvisorはkubeletにintegrateされており、自身の所属するnode上で稼働するcontainerを発見し、cpuやmemoryなどのmetricを収集することができます。

## kubelet

> The Kubelet acts as a bridge between the Kubernetes master and the nodes.
> It manages the pods and containers running on a machine.
> Kubelet translates each pod into its constituent containers and fetches individual container usage statistics from cAdvisor.
> It then exposes the aggregated pod resource usage statistics via a REST API.

kubelet は kubernates masterとnodeをつなぐagentです。
master nodeのapiを通して各containerやnodeのmetricを収集します。

nodeのmetric収集ってkubeletが集めている認識で良いかは不安。

## service desicovery

各node, service, pod, ingressなどのdiscoveryはすべてkubernates上で行われます。

それに対応したservice discovery apiはprometheusにimplementされています。
便利！

https://github.com/prometheus/prometheus/blob/master/discovery/kubernetes/node.go

