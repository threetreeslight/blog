+++
date = "2018-07-07T12:00:00+09:00"
title = "Prettify alert notification to slack"
tags = ["slack", "prometheus", "alertmanager"]
categories = ["programming"]
+++

とりあえず通知は飛ぶようになったが、２つ問題がある。

現在の通知

![](https://threetreeslight.com/images/blog/2018/07/2018-07-01-gke-prometheus-slack.png)

1. 通知情報が不足している
1. recover状態が通知されない

これを解決します。

## Notify recover alert

復旧通知をするには `send_resolved` optionをtrueにするだけで済みます。

```yaml
receivers:
- name: slack
  slack_configs:
  - send_resolved: true
```

これはdefaultでtrueにしてよいきもするので、少しだけ掘ってみます。

https://github.com/prometheus/alertmanager/blob/master/config/notifiers.go#L27

```go
	// DefaultSlackConfig defines default values for Slack configurations.
	DefaultSlackConfig = SlackConfig{
		NotifierConfig: NotifierConfig{
			VSendResolved: false,
		},
```

commit messageを読むと、以下のように一般的に使うチャットシステムだし、通知が多いとスパムっぽくなるからとのこと。

> brian-brazil committed on Jan 6, 2016
>
> Don't send resolved to Slack by default.
> Slack is a general chat system, it has no notion of resolved messages. Default it to false to avoid spamming people as we do with all other such systems.

これを気にするのであれば、そもそも連携しない気もしますが、不思議です。

## Customize alert message and format

prometheusからの通知内容を以下の通りカスタマイズします。

alert.rules.yml

```diff
    annotations:
      summary: 'Endpoint {{ $labels.instance }} down'
+       description: '{{ $labels.instance }} of job {{ $labels.job }} has been has been down for more than 10 seconds.'
```

alermanagerのslack通知フォーマットを以下の通りカスタマイズします。

alertmanager.yml

```diff
receivers:
- name: slack
  slack_configs:
  - send_resolved: true
    channel: '#blog'
+   color: '{{ if eq .Status "firing" }}danger{{ else }}good{{ end }}'
+   footer: '{{ template "slack.default.footer" . }}'
+   icon_url: 'https://pbs.twimg.com/profile_images/588945677599780865/mrhc1gSh_400x400.png'
+   pretext: '{{ template "slack.default.pretext" . }}'
+   short_fields: false
+   title: '{{ .Status | toUpper }}{{ if eq .Status "firing" }}:{{ .Alerts.Firing | len }}{{ end }} {{ range .Alerts }}{{ .Annotations.summary }}{{ end }}'
+   text: "{{ range .Alerts }}{{ .Annotations.description }}{{ end }}"
+   title_link: '{{ template "slack.default.titlelink" . }}'
+   username: 'prometheus'
```

監視関連を何回か再起動する試験をしたいので、config mapを更新してpodをscale in -> outするscriptも雑に準備します。

restart_monitor.sh

```sh
#!/bin/sh

kubectl create configmap alertmanager-yml --from-file=prometheus/alertmanager.yml --dry-run -o yaml | kubectl replace configmap alertmanager-yml -f -
kubectl create configmap prometheus-yml --from-file=prometheus/prometheus.yml --dry-run -o yaml | kubectl replace configmap prometheus-yml -f -
kubectl create configmap alert-rules-yml --from-file=prometheus/alert.rules.yml --dry-run -o yaml | kubectl replace configmap alert-rules-yml -f -
kubectl create configmap grafana-ini --from-file=grafana/grafana.ini --dry-run -o yaml | kubectl replace configmap grafana-ini -f -
kubectl create configmap grafana-datasource --from-file=grafana/datasource.yaml --dry-run -o yaml | kubectl replace configmap grafana-datasource -f -

kubectl scale --replicas=0 deployment/monitor

while [ $(kubectl get pods | grep monitor | wc -l) = 1 ]; do
  kubectl get pods
  sleep 1
done

kubectl scale --replicas=1 deployment/monitor
sleep 10

while [ $(kubectl get pods | grep monitor | grep Running | wc -l) = 1 ]; do
  kubectl get pods
  sleep 1
done

echo "restarted"
exit 0
```

## Try it!

Apply

```sh
./scripts/restart_monitor.rb
```

down通知とrecover通知を試します

```sh
% kubectl scale --replicas=0 deployment/blog
deployment.extensions "blog" scaled

% kubectl scale --replicas=1 deployment/blog
deployment.extensions "blog" scaled
```

![](/images/blog/2018/07/2018-07-07-alarm.png)

動いてよかった 😇

