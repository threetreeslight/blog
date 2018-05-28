+++
date = "2018-05-27T17:00:00+09:00"
title = "Study to collect container metrics with grafana and prometheus"
tags = ["grafana", "prometheus", "monitoring", "monitoring"]
categories = ["programming"]
+++

kubernates環境下へのrolling updateまで自動化なんとなできました。

続いては監視です。

監視するに置いて何が良いのか、何がdefactとなっていくのかを見据えて選定。

## [Cloud Native Computing Foundation](https://www.cncf.io/)

CNCFにはデファクトになるというロジックに則って、どのプロジェクトを採用するか考えてみる

そもそもCNCFとは？

> The Cloud Native Computing Foundation builds sustainable ecosystems and fosters a community around a constellation of high-quality projects that orchestrate containers as part of a microservices architecture.

うん。よくわからない。

個人的にはcontainerを利用したサービス運用に関わる様々なものの標準化の流れを作っている理解です。

その中でmonitoring toolとなるとprometheus。
というわけで、prometheusをmonitoring toolとして利用します。

また、prometheusのweb uiはchart表現力が貧弱なので、chartの表示にはgrafanaを利用していきます。

## [What is prometheus](https://prometheus.io/docs/introduction/overview/)

> Prometheus is an open-source systems monitoring and alerting toolkit originally built at SoundCloud. Since its inception in 2012, many companies and organizations have adopted Prometheus, and the project has a very active developer and user community. It is now a standalone open source project and maintained independently of any company. To emphasize this, and to clarify the project's governance structure, Prometheus joined the Cloud Native Computing Foundation in 2016 as the second hosted project, after Kubernetes.

soundloud によって作らたフルスタックなmonitoring, alert toolです。

[Feature](https://prometheus.io/docs/introduction/overview/)

- 時系列データを持つ多次元データモデル
- (ちょっと癖のある)柔軟なクエリ言語
- 単一のサーバーノードで可動
- プルモデル
- 中間ゲートウェイと通したプッシュもできる
- サービスディスカバリか静的コンフィグ記述によって対象を検出
- グラフ化とダッシュボードのサポート

## Getting start prometheus

dockaer container経由でprometheusを立ち上げてみます。

```sh
% docker run -it --rm -p 9090:9090 quay.io/prometheus/prometheus
% open localhost:9090/graph
```

なるほど、こういう感じ。自身のデータを収集して表示する

query : `rate(prometheus_tsdb_head_chunks_created_total[1m]`

静的なconfig記述によってデータをpullしていきます。

以下のようなコードでprometheus serviceを起動していきます。

[threetreeslight/prometheus-sample](https://github.com/threetreeslight/prometheus-sample)

query : `avg(rate(rpc_durations_seconds_count[5m])) by (job, service)`

![](/images/blog/2018/05/prometheus-target.png)

OKいいかんじ。

Queryするのに時間がかかるので、予め計算ルールを設けてmetricとして保持するようにすることも可能です。

![](/images/blog/2018/05/prometheus-graph.png)

## Grafana

続いてgrafanaと接続します。

以下のようなgrafana serviceを立ち上げてdatasourceにはprometheusを使っています。

[threetreeslight/prometheus-sample](https://github.com/threetreeslight/prometheus-sample)

収集しているコードを獲得できています。

![](/images/blog/2018/05/grafana-dashboard.png)

いい感じ

## [collect docker metrics with prometheus](https://docs.docker.com/config/thirdparty/prometheus/)

docker for macで試しています

Docker deamonのsetting > advancedより以下のように行う

```json
{
  "storage-driver" : "aufs",
  "debug" : true,
  "metrics-addr" : "127.0.0.1:9323",
  "experimental" : true
}
```

そしてprometheusにserviceを追加するとかどうコンテナ数などを確認することができる。
しかし各containerのmetricを取得できていない。

## collect container and node metrics with prometheus

このままだとcontainerとnodeのmetricを使えないので以下を関連hostとして立てます

- containerのmetric収集
  - [google/cadvisor](https://github.com/google/cadvisor)
- nodeのmetric収集
  - [prometheus/node_exporter](https://github.com/prometheus/node_exporter)

`docker-compose.yaml`

```yaml
# docker-compose.yaml

  cadvisor:
    image: google/cadvisor:latest
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:rw
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
      - /dev/disk/:/dev/disk:ro
      - console
    networks:
      - default
    ports:
      - "8080:8080"

  node-exporter:
    image: quay.io/prometheus/node-exporter
    networks:
      - default
    pid: "host"
    ports:
      - "9100:9100"
```

`prometheus.yaml`

```yaml
...

  - job_name: 'container'
    static_configs:
      - targets: ['cadvisor:8080']
        labels:
          group: 'container'

  - job_name: 'host'
    static_configs:
      - targets: ['node-exporter:9100']
        labels:
          group: 'host'

```

## 次回は

こんな感じで概ね仕組みなどは理解できたので、次は以下あたりをやります

- prometheusとgrafanaのデータの永続化のプラクティスを考える
- prometheus、garafanaのcontainerをkubernates上に配置
- DaemonSetを利用したcAdvisor, node-exporterの配置
- kubernatesの機能を利用したservice discovery
