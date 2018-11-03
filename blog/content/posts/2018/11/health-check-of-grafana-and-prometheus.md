+++
date = "2018-11-03T12:00:00+09:00"
title = "Health check of prometheus and grafana"
tags = ["kubernates", "k8s", "context", "namespace"]
categories = ["programming"]
+++

Prometheusとgrafanaのhealth checkのpath、なんかしっくりこなかったので調べてみた

## Prometheus

health check endpoint実装されてた

https://github.com/prometheus/prometheus/blob/47a673c3a0d80397f715105ab6755db2aa6217e1/web/web.go#L303

```go
	router.Get("/-/healthy", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		fmt.Fprintf(w, "Prometheus is Healthy.\n")
	})
	router.Get("/-/ready", readyf(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		fmt.Fprintf(w, "Prometheus is Ready.\n")
	}))
```

揉めずにサクッとはいっていた模様。`/-/ready` が先にあったからかな？

[Add `/-/healthy` and `/-/ready` endpoints #2831](https://github.com/prometheus/prometheus/issues/2831)

### deployment

シンプルになった 😇

```yaml
livenessProbe:
  httpGet:
    path: /-/healthy
    port: 9090
readinessProbe:
  httpGet:
    path: /-/ready
    port: 9090
```

## Grafana

[Grafana 4.3](http://docs.grafana.org/guides/whats-new-in-v4-3/#health-check-endpoint)で `/api/health` endpointが提供されていた。

https://github.com/grafana/grafana/blob/e78c1b4abc7eda7a065e390dc04b7a0c0435268c/pkg/api/http_server.go#L250

```go
func (hs *HTTPServer) healthHandler(ctx *macaron.Context) {
	notHeadOrGet := ctx.Req.Method != http.MethodGet && ctx.Req.Method != http.MethodHead
	if notHeadOrGet || ctx.Req.URL.Path != "/api/health" {
		return
	}

	data := simplejson.New()
	data.Set("database", "ok")
	data.Set("version", setting.BuildVersion)
	data.Set("commit", setting.BuildCommit)
```

ぼちぼちコメントがある。それなりにこまっていたということだろうか？ぼちぼちコメントが有る。

grafanaのiconが帰ってくるかどうかでwork aroundしているひともいるぐらい。

アクセスすると認証前だったらlogin画面に飛ばされたり、そもそもそのログイン画面がちょいと重かったりする（所感）

[Monitoring Grafana #3302](https://github.com/grafana/grafana/issues/3302)

### deployment

シンプルになった 😇

```yaml
readinessProbe:
  httpGet:
    path: /api/health
    port: 3000
```

## 総論

health check先が提供されていると良いよね

