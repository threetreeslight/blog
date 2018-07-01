+++
date = "2018-06-30T15:00:00+09:00"
title = "blog availability monitoring by blackbox exporter"
tags = ["gcp", "kubernates", "gke", "monitoring", "prometheus", "blackbox_exporter"]
categories = ["programming"]
+++

prometheus + grafanaでのmetric収集とvisualizeが大分馴染んできたので、次に [prometheus/blackbox_exporter](https://github.com/prometheus/blackbox_exporter) を利用した死活監視を行います。

## What is blackbox expoter?

> The blackbox exporter allows blackbox probing of endpoints over HTTP, HTTPS, DNS, TCP and ICMP.

`probing` という表現なかなかいいですね。

各種プロトコルを用いて様々なendpointの探査をできるめちゃめちゃ便利です。

## どのようなprobe outputが得られるのか？

存在するエンドポイントと存在しないエンドポイントの両方に通知を送るとどのような結果が得られるのか見てみます。

`blackbox-exporter` を立ち上げる。

```sh
docker run --rm -p 9115:9115 prom/blackbox-exporter:latest
```

存在するエンドポイント

```sh
curl -H 'Accept: application/json' 'http://localhost:9115/probe?module=http_2xx&target=threetreeslight.com'
# HELP probe_dns_lookup_time_seconds Returns the time taken for probe dns lookup in seconds
# TYPE probe_dns_lookup_time_seconds gauge
probe_dns_lookup_time_seconds 0.0028015
# HELP probe_duration_seconds Returns how long the probe took to complete in seconds
# TYPE probe_duration_seconds gauge
probe_duration_seconds 0.2240209
# HELP probe_failed_due_to_regex Indicates if probe failed due to regex
# TYPE probe_failed_due_to_regex gauge
probe_failed_due_to_regex 0
# HELP probe_http_content_length Length of http content response
# TYPE probe_http_content_length gauge
probe_http_content_length 27068
# HELP probe_http_duration_seconds Duration of http request by phase, summed over all redirects
# TYPE probe_http_duration_seconds gauge
probe_http_duration_seconds{phase="connect"} 0.0067953
probe_http_duration_seconds{phase="processing"} 0.1983978
probe_http_duration_seconds{phase="resolve"} 0.004721400000000001
probe_http_duration_seconds{phase="tls"} 0.0192079
probe_http_duration_seconds{phase="transfer"} 0.00015299999999999998
# HELP probe_http_redirects The number of redirects
# TYPE probe_http_redirects gauge
probe_http_redirects 1
# HELP probe_http_ssl Indicates if SSL was used for the final redirect
# TYPE probe_http_ssl gauge
probe_http_ssl 1
# HELP probe_http_status_code Response HTTP status code
# TYPE probe_http_status_code gauge
probe_http_status_code 200
# HELP probe_http_version Returns the version of HTTP of the probe response
# TYPE probe_http_version gauge
probe_http_version 1.1
# HELP probe_ip_protocol Specifies whether probe ip protocol is IP4 or IP6
# TYPE probe_ip_protocol gauge
probe_ip_protocol 4
# HELP probe_ssl_earliest_cert_expiry Returns earliest SSL cert expiry in unixtime
# TYPE probe_ssl_earliest_cert_expiry gauge
probe_ssl_earliest_cert_expiry 1.53397226e+09
# HELP probe_success Displays whether or not the probe was a success
# TYPE probe_success gauge
probe_success 1
```

存在しないエンドポイント

```sh
% curl -H "Accept: application/json" 'http://localhost:9115/probe?module=http_2xx&target=unknown.threetreeslight.com'
# HELP probe_dns_lookup_time_seconds Returns the time taken for probe dns lookup in seconds
# TYPE probe_dns_lookup_time_seconds gauge
probe_dns_lookup_time_seconds 0.034506
# HELP probe_duration_seconds Returns how long the probe took to complete in seconds
# TYPE probe_duration_seconds gauge
probe_duration_seconds 0.034939
# HELP probe_failed_due_to_regex Indicates if probe failed due to regex
# TYPE probe_failed_due_to_regex gauge
probe_failed_due_to_regex 0
# HELP probe_http_content_length Length of http content response
# TYPE probe_http_content_length gauge
probe_http_content_length 0
# HELP probe_http_duration_seconds Duration of http request by phase, summed over all redirects
# TYPE probe_http_duration_seconds gauge
probe_http_duration_seconds{phase="connect"} 0
probe_http_duration_seconds{phase="processing"} 0
probe_http_duration_seconds{phase="resolve"} 0
probe_http_duration_seconds{phase="tls"} 0
probe_http_duration_seconds{phase="transfer"} 0
# HELP probe_http_redirects The number of redirects
# TYPE probe_http_redirects gauge
probe_http_redirects 0
# HELP probe_http_ssl Indicates if SSL was used for the final redirect
# TYPE probe_http_ssl gauge
probe_http_ssl 0
# HELP probe_http_status_code Response HTTP status code
# TYPE probe_http_status_code gauge
probe_http_status_code 0
# HELP probe_http_version Returns the version of HTTP of the probe response
# TYPE probe_http_version gauge
probe_http_version 0
# HELP probe_ip_protocol Specifies whether probe ip protocol is IP4 or IP6
# TYPE probe_ip_protocol gauge
probe_ip_protocol 0
# HELP probe_success Displays whether or not the probe was a success
# TYPE probe_success gauge
probe_success 0
```

この結果から `probe_success` を利用することで期待するmetricを収集できることがわかります。

時々 `probe_http_status_code` でやりましょうという記事をみかけるのだけど、なんでだろう？

## prometheus + blacbox-exporter

次いでprometheusからblackbox-exporterのscriping用endpointを叩くようにする。

このとき、`blackbox-expoter` の設定はdefaultでいい感じのmodule定義がなされているので特に変更することはしない。

prometheus dockerfile

```yaml
FROM prom/prometheus

COPY prometheus.yml /etc/prometheus/prometheus.yml
```

prometheus.yaml

```yaml
global:
  scrape_interval:     15s
  evaluation_interval: 15s

scrape_configs:
- job_name: 'blackbox'
  metrics_path: /probe
  # とりあえず1秒間隔で収集してみる
  scrape_interval: 1s
  params:
    module: [http_2xx]
  static_configs:
    - targets:
      - https://unknown.threetreeslight.com
      - https://threetreeslight.com
  relabel_configs:
    - source_labels: [__address__]
      target_label: __param_target
    - source_labels: [__param_target]
      target_label: instance
    - target_label: __address__
      replacement: blackbox-exporter:9115
```

docker-compose

```yaml
version: "3"
services:
  prometheus:
    build:
      context: .
      dockerfile: ./prometheus/Dockerfile
    volumes:
      - prometheus-data:/prometheus
    depends_on:
      - blackbox-exporter
    networks:
      - default
    ports:
      - 9090:9090

  blackbox-exporter:
    image: prom/blackbox-exporter:latest
    networks:
      - default
    ports:
      - 9115:9115

volumes:
  prometheus-data:
    driver: local
```

metricが期待通り収集できているか確認する

target

![](/images/blog/2018/06/2018-06-30-local-prometheus-target.png)

graph

![](/images/blog/2018/06/2018-06-30-local-prometheus-graph.png)

期待通り収集できていることがわかる

## k8s上に配置する

deployment にblackbox exporterを追加する

monitor.yaml

```diff
      containers:
      - image: threetreeslight/blog-prometheus:latest
        name: prometheus
        readinessProbe:
          httpGet:
            path: /graph
            port: 9090
          periodSeconds: 10
          initialDelaySeconds: 0
          failureThreshold: 10
          successThreshold: 1
        ports:
        - containerPort: 9090
          protocol: TCP
        volumeMounts:
        - mountPath: /prometheus
          name: prometheus-data
        securityContext:
          runAsUser: 0
+      - image: prom/blackbox-exporter:latest
+        name: blackbox-exporter
```

localでやったのとほぼ同様にprometheus設定を追加する。

このとき、 `__address__` の接続先は同一pod内に配置するため、`localhost:9115` とする。

(この手の違いが面倒だなぁと時節感じるのですが、 ここらへんはminikubeでやっているのだろうか？ )

prometheus.yaml

```diff
+- job_name: 'blackbox'
+  metrics_path: /probe
+  params:
+    module: [http_2xx]  # Look for a HTTP 200 response.
+  static_configs:
+    - targets:
+      - https://threetreeslight.com
+      - https://grafana.threetreeslight.com/login
+  relabel_configs:
+    - source_labels: [__address__]
+      target_label: __param_target
+    - source_labels: [__param_target]
+      target_label: instance
+    - target_label: __address__
+      replacement: localhost:9115
```

apply

```
% kubectl apply -f ./kubernates/monitor.yaml
```

## metric

収集できている模様

```
% kubectl port-forward $(kubectl get pod --selector="app=monitor" -o jsonpath='{.items[0].metadata.name}') 9090:9090
% open http://localhost:9090
```

target

![](/images/blog/2018/06/2018-06-30-gke-prometheus-target.png)

graph on grafana

![](/images/blog/2018/06/2018-06-30-gke-grafana-graph.png)


思った以上につまりどころもなく簡単でした。

どちらかというと次に行ったprometheusのalert設定あたり、概念を理解するのに少し時間がかかりました。

# reference

- [prometheus/blackbox-exporter - example](https://github.com/prometheus/blackbox_exporter/blob/master/example.yml)
- [degital ocern - How To Use Alertmanager And Blackbox Exporter To Monitor Your Web Server On Ubuntu 16.04](https://www.digitalocean.com/community/tutorials/how-to-use-alertmanager-and-blackbox-exporter-to-monitor-your-web-server-on-ubuntu-16-04)

