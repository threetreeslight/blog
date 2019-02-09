+++
date = "2019-02-09T12:00:00+09:00"
title = "How to monitor kubernetes node cpu with prometheus"
tags = ["cpu", "monitoring", "linux", "prometheus", "kubernetes", "k8s"]
categories = ["programming"]
+++

仮想環境化におけるCPU Utilizationについて理解が浅いポイントが有ったので、改めて理解を深める。

なお、CPU Schedulerなどには触れない。

## CPU Utilization on virtual machine

仮想環境におけるCPU使用率は、総CPU利用時間に対するCPU利用時間がどれぐらいであるか？というものである。

具体的には以下の内容で表現される

> Consumed CPU time = CPU User Time + CPU Nice Time + CPU System Time
>
> All CPU time = Consumed CPU Time + CPU Idel Time + iowait Time + CPU Steal Time
>
> CPU Utilization = Consumed CPU Time / All CPU Time

Utilizationが `1 - CPU Idel Time / All CPU Time` でないことも大切。

## About each CPU time

### CPU User Time and System Time

まず、Linuxのシステムメモリはユーザー空間とカーネル空間に分けられる。

ユーザー空間はユーザープロセス(カーネル以外のその他全てのプロセス)のメモリ位置のセットであり、その空間で実行されるプログラムで消費されたCPU時間をユーザー時間と呼ぶ。

一方のカーネル空間も同様に、カーネルが実行するメモリ位置のセットであり、その空間で実行されるプログラムのCPU時間をシステム時間と呼ぶ。

### CPU Nice Time

優先度（nice値）設定されたユーザプロセス実行によるCPU時間の割合。

基本的にUser Timeのsubsetとしてみて良いものだが、優先度が低い（niceが高い）場合は実行を中断されるプログラムであるため、別枠のCPU時間として計上されているんだろうと一旦理解。

### CPU Idel Time

CPUが使用されていない時間の割合

### iowait Time

I/O待ちによるCPUが使用されていない時間の割合

### CPU Steal Time

ゲストOSがCPU割り当て待ちとなった時間の割合

CPU Stolenが頻発するとどのような影響があるのか？

- CPU利用率の高いアプリケーションにとっては、Idel Timeがゼロになりがち
- そのため、CPUのアイドル率を見る監視は不適切ということになる
- 結果として一定のアプリケーションのパフォーマンスを維持することが困難になる

## Node

各nodeのCPU使用率は、 `process_cpu_seconds_total` が良さそう。

このとき、host以外のprocess_cpu_seconedが返されるので、kubernetes-nodes jobが収集するものに限定すること。

e.g. prometheusに収集される `process_cpu_seconds_total` element

```sh
process_cpu_seconds_total{beta_kubernetes_io_arch="amd64",beta_kubernetes_io_fluentd_ds_ready="true",beta_kubernetes_io_instance_type="g1-small",beta_kubernetes_io_os="linux",cloud_google_com_gke_nodepool="small",cloud_google_com_gke_os_distribution="cos",failure_domain_beta_kubernetes_io_region="us-west1",failure_domain_beta_kubernetes_io_zone="us-west1-a",instance="gke-blog-cluster-small-c43c7079-0tgd",job="kubernetes-nodes",kubernetes_io_hostname="gke-blog-cluster-small-c43c7079-0tgd"}
process_cpu_seconds_total{instance="10.56.0.11:9093",job="istio-policy"}
process_cpu_seconds_total{instance="10.56.4.2:9093",job="pilot"}
process_cpu_seconds_total{instance="10.56.4.4:9093",job="galley"}
process_cpu_seconds_total{instance="10.56.4.8:9093",job="istio-telemetry"}
process_cpu_seconds_total{instance="35.199.155.107:443",job="kubernetes-apiservers"}
process_cpu_seconds_total{instance="localhost:9090",job="prometheus"}
```

grafanaの設定

```sh
sum(rate(process_cpu_seconds_total{job="kubernetes-nodes"}[$interval])) by ( instance ) * 100
```

## Container

基本はcontainer別にCPU利用率を割り当てていることを前提に考えると、containerごとに出すことが望ましい。
このため、 cAdvisorで収集される `container_cpu_usage_seconds_total` を利用する。

e.g. `container_cpu_usage_seconds_total` element

```sh
container_cpu_usage_seconds_total{beta_kubernetes_io_arch="amd64",beta_kubernetes_io_fluentd_ds_ready="true",beta_kubernetes_io_instance_type="g1-small",beta_kubernetes_io_os="linux",cloud_google_com_gke_nodepool="small",cloud_google_com_gke_os_distribution="cos",container_name="blog",cpu="total",failure_domain_beta_kubernetes_io_region="us-west1",failure_domain_beta_kubernetes_io_zone="us-west1-a",id="/kubepods/besteffort/podcf1472fd-2c41-11e9-a36f-42010a8a00fb/1a3eebed2d163359cdde8aae6121734e8b73db117af5da0f82a921859d4f8e43",image="threetreeslight/blog@sha256:601ee799e015387f9ccbe37c4ed7666a9f37d4528bf8eb0e60ab59a8c79bc5f0",instance="gke-blog-cluster-small-c43c7079-0tgd",job="kubernetes-cadvisor",kubernetes_io_hostname="gke-blog-cluster-small-c43c7079-0tgd",name="k8s_blog_blog-7b8b7c884f-zjgqj_app_cf1472fd-2c41-11e9-a36f-42010a8a00fb_0",namespace="app",pod_name="blog-7b8b7c884f-zjgqj"}
```

grafanaの設定はnamespaceとcontainer nameで区切ることで異なるnamespace & 同一container_nameが混ざらないように

```sh
sum(rate(container_cpu_usage_seconds_total{name=~".+"}[$interval])) by (namespace,container_name) * 100
```

# References

- [stackoverflow - User CPU time vs System CPU time?](https://stackoverflow.com/questions/4310039/user-cpu-time-vs-system-cpu-time)
- [LINFO - Kernel Space Definition](http://www.linfo.org/kernel_space.html)
- [詳解システムパフォーマンス](https://www.amazon.co.jp/dp/4873117909)
- [Linux OSリソースのパフォーマンス分析(2) ～ CPUとメモリの使用状況を分析してみよう](https://codezine.jp/article/detail/9167)
- [Datadog - Understanding AWS stolen CPU and how it affects your apps](https://www.datadoghq.com/blog/understanding-aws-stolen-cpu-and-how-it-affects-your-apps/)
- [YKST - CPU使用率は間違っている](https://yakst.com/ja/posts/4575)
