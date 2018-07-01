+++
date = "2018-07-01T22:00:00+09:00"
title = "Alert blog downtime with alertmanager"
tags = ["gcp", "kubernates", "gke", "monitoring", "prometheus", "alertmanager"]
categories = ["programming"]
+++

downtimeの観測ができるようになったので、downtimeがslackに通知されるようにしたいと思います。

そのためにもprometheusのalertingを理解します。

## Alerting

https://prometheus.io/docs/alerting/overview/

Prometheusのalartは２つのパートに分かれている。

- prometheus alert ruleは alert managerに alertを送信する
- alertmanagerは
  - silencing, inhibition, aggregation をしたり
  - その通知を行う

## Alert manager behavior

https://github.com/prometheus/alertmanager

> The Alertmanager handles alerts sent by client applications such as the Prometheus server. It takes care of deduplicating, grouping, and routing them to the correct receiver integrations such as email, PagerDuty, or OpsGenie. It also takes care of silencing and inhibition of alerts.

alertmanagerがどのような動作をするのか追う上で、どのような設定をするのか確認します。

https://prometheus.io/docs/alerting/configuration/

alertmanagerでは以下のような項目の設定をします。

- global
  - route, receiverで指定するglobalな変数
- route
  - 受け取ったalertをどのように集約・抑止などを行い、どのような頻度で通知するのか
- receiver
  - 通知先の設定

例えば、severityに合わせてroutingとreceiverを変更することも容易に可能です。

とりあえず、alermnameごとに集約され、すべての通知はslackに送られるようにします。

以下のnotification examplesを参考にしました。

https://prometheus.io/docs/alerting/notification_examples/

alertmanager.yaml

```yaml
global:
  slack_api_url: xxxx

route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: slack

receivers:
- name: slack
  slack_configs:
  - channel: '#blog'
```

alertmanagerを起動します

```sh
docker run -it --rm -p "9093:9093" -v "$PWD/prometheus/alertmanager.yml:/etc/alertmanager/alertmanager.yml" prom/alertmanager
open http://localhost:9093
```

上記を設定した上で処理します

```sh
curl -XPOST -d'[{"labels":{"alertname":"some alert","serverity":"critical","instance":"example"}}]' http://localhost:9093/api/v1/alerts
```

以下のようにalarm managerに通知が集約されます。

![](/images/blog/2018/07/2018-07-01-local-alertmanager.png)

設定どおりslackに通知されます。

![](/images/blog/2018/07/2018-07-01-local-slack.png)


## alerm with prometheus on local

続いて、prometheusから alertmanagerへの通知を試します。
`blackbox-exporter` でのdown情報をalertmanagerに通知することにします。

blackbox-exporterの `probe_success == 0` をdownとし、通知するようalert ruleを設定します。

alert.rule.yml

```yaml
groups:
- name: alert.rules
  rules:
  - alert: EndpointDown
    expr: probe_success == 0
    for: 10s
    labels:
      severity: "critical"
    annotations:
      summary: "Endpoint {{ $labels.instance }} down"
```

prometheus.ymlにてalertmanagerへの通知設定などを行います

```diff
global:
  scrape_interval:     15s
  evaluation_interval: 15s

  # Attach these extra labels to all timeseries collected by this Prometheus instance.
  external_labels:
    monitor: 'codelab-monitor'

+ alerting:
+   alertmanagers:
+   - static_configs:
+     - targets:
+       - 'alertmanager:9093'

+ rule_files:
+ - alert.rules.yml

scrape_configs:
- job_name: 'prometheus'
  static_configs:
  - targets: ['localhost:9090']

- job_name: 'blackbox'
  metrics_path: /probe
  scrape_interval: 1s
  params:
    module: [http_2xx]  # Look for a HTTP 200 response.
  static_configs:
    - targets:
      - https://down.threetreeslight.com
      - https://threetreeslight.com
  relabel_configs:
    - source_labels: [__address__]
      target_label: __param_target
    - source_labels: [__param_target]
      target_label: instance
    - target_label: __address__
      replacement: blackbox-exporter:9115
```

docker-compose.yaml

```yaml
version: "3"
services:
  prometheus:
    image: prom/prometheus
    volumes:
      - ./prometheus/prometheus-local.yml:/etc/prometheus/prometheus.yml
      - ./prometheus/alert.rules.yml:/etc/prometheus/alert.rules.yml
      - prometheus-data:/prometheus
    depends_on:
      - alertmanager
      - blackbox-exporter
    networks:
      - default
    ports:
      - 9090:9090

  alertmanager:
    image: prom/alertmanager
    networks:
      - default
    volumes:
      - ./prometheus/alertmanager.yml:/etc/alertmanager/alertmanager.yml
    ports:
      - 9093:9093

  blackbox-exporter:
    image: prom/blackbox-exporter:latest
    networks:
      - default
```

立ち上げます

```
docker-compose up prometheus
```

![](/images/blog/2018/07/2018-07-01-local-prometheus-slack.png)


期待通り通知が届きました。

## alerm with prometheus on GKE

上記で作成したalertmanagerとalert rule設定をcofigmapとして作成します

```sh
kubectl create configmap alertmanager-yml --from-file ./prometheus/alertmanager.yml
kubectl create configmap alert-rules-yml --from-file ./prometheus/alert.rules.yml

kubectl get configmap
NAME                 DATA      AGE
alert-rules-yml      1         6s
alertmanager-yml     1         1d
prometheus-yml       1         4h
```

接続先を`localhost` に変更し、 prometheus-yml configmapを更新します

```sh
kubectl create configmap prometheus-yml --from-file=prometheus/prometheus.yml --dry-run -o yaml | kubectl replace configmap prometheus-yml -f -
```

prometheusと同一podにalertmanagerを配置します。

deployment: monitor.yml

```diff
apiVersion: extensions/v1beta1
kind: Deployment
spec:
      ...
      containers:
      - image: prom/blackbox-exporter:latest
        imagePullPolicy: Always
        name: blackbox-exporter
        resources: {}
+       - image: prom/alertmanager:latest
+         imagePullPolicy: Always
+         name: alertmanager
+         ports:
+         - containerPort: 9093
+           protocol: TCP
+         resources: {}
+         volumeMounts:
+         - mountPath: /etc/alertmanager/alertmanager.yml
+           subpath: alertmanager.yml
+           name: alertmanager-yml
      - image: prom/prometheus:latest
        imagePullPolicy: Always
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
        resources: {}
        volumeMounts:
        - mountPath: /etc/prometheus/prometheus.yml
          subPath: prometheus.yml
          name: prometheus-yml
+         - mountPath: /etc/prometheus/alert.rules.yml
+           subPath: alert.rules.yml
+           name: alert-rules-yml
        - mountPath: /prometheus
          name: prometheus-data
        securityContext:
          runAsUser: 0
      ...
      volumes:
+       - name: alertmanager-yml
+         configMap:
+           name: alertmanager-yml
      - name: prometheus-yml
        configMap:
          name: prometheus-yml
+       - name: alert-rules-yml
+         configMap:
+           name: alert-rules-yml
      - name: prometheus-data
        persistentVolumeClaim:
          claimName: prometheus-data
...
```

適用します。

```sh
kubectl apply -f ./kubernates/monitor.yaml
clusterrole.rbac.authorization.k8s.io "monitor" configured
serviceaccount "monitor" unchanged
clusterrolebinding.rbac.authorization.k8s.io "monitor" configured
service "monitor" unchanged
persistentvolumeclaim "prometheus-data" unchanged
persistentvolumeclaim "grafana-data" unchanged
deployment.extensions "monitor" configured
```

監視しているblogを落とします。

```
kubectl scale --replicas=0 deployment/blog
```

届きました。

![](/images/blog/2018/07/2018-07-01-gke-alertmanager.png)

slackへの通知もいい感じ。

![](/images/blog/2018/07/2018-07-01-gke-prometheus-slack.png)

## environmentsについて

slack urlをsecretsで入れたいのだが、うまくいきません。

コードを読んでも確かに環境変数を引いていないようです。

調べてみると、どうやら作者は環境変数は嫌いなので許さんスタイルでした。

https://github.com/prometheus/alertmanager/issues/504

> brian-brazil (Brian Brazil) on Dec 9, 2017
> Finally found the old article I was looking for on environment variables and secrets: http://movingfast.io/articles/environment-variables-considered-harmful

わかります。わかるんですが、public repoでは悩ましいです。

## reference

- [degital ocern - How To Use Alertmanager And Blackbox Exporter To Monitor Your Web Server On Ubuntu 16.04](https://www.digitalocean.com/community/tutorials/how-to-use-alertmanager-and-blackbox-exporter-to-monitor-your-web-server-on-ubuntu-16-04)
