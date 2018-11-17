+++
date = "2018-11-03T12:00:00+09:00"
title = "How to request healthcheck of service resouce with istio"
tags = ["kubernates", "k8s", "istio", "probe", "healthcheck"]
categories = ["programming"]
+++

Istioを使ってserviceを稼働させるとまずハマったのが、kubernetes service resourceからのlivenessProbeおよびreadinessProbeが通らなくなるという事象。

この問題にぶつかる人は多い様子。

- [istio issues - Liveness Readiness Probe Istio #2628](https://github.com/istio/istio/issues/2628)
- [istio faq - security/k8s-health-checks](https://istio.io/help/faq/security/#k8s-health-checks)

# Requirement

Istioはマイナーバージョンが変わるだけでCustom Resourceがなくなったりするので、本記事のkubernetesとistioのversionを記述する

- kubernetes master version: 1.10.9-gke.5
- Node version: 1.10.9-gke.5
- Istio version: 1.0.3

# Istio導入前のprobe設定

blogに利用するnginxに `/healthy` endpointを切って

```conf
server {
    listen       8080;

    ...

    location /healthy {
        default_type text/plain;
        return 200 'ok';
    }
```

blogのdeploymentは`/healthy` を叩くだけ。

```yaml
...
readinessProbe:
  httpGet:
    path: /healthy
    port: 8080
...
```

istioを稼働させるとpod内でのreadinessProbeは通るのだが、serviceからのhealthcheckが一切通らなくなる。

# 原因

これはsidecarとして可動しているenvoyがkubeletからのHTTP/TCP requestを拒否しているから他ならない。

> ### [istio issues - Liveness Readiness Probe Istio #2628](https://github.com/istio/istio/issues/2628)
>
> Do the FAQ have answer?
>
> How can I use Kubernetes liveness and readiness for service health check with Istio Auth enabled?
>
> If Istio Auth is enabled, http and tcp health check from kubelet will not work since they do not have Istio Auth issued certs.
> A workaround is to use a liveness command for health check, e.g., one can install curl in the service pod and curl itself within the pod.
> The Istio team is actively working on a solution.
>
> An example of readinessProbe:

```yaml
livenessProbe:
exec:
  command:
  - curl
  - -f
  - http://localhost:8080/healthz # Replace port and URI by your actual health check
initialDelaySeconds: 10
periodSeconds: 5
```

うーんアグレッシブ。

Issueを眺めていると、特定のportだけIstio Authを落とすことができるようだ。


> https://github.com/istio/istio/issues/2628#issuecomment-358145100
>
> Ah, it is in our FAQ:
>
> Starting with release 0.3, you can use service-level annotations to disable (or enable) Istio Auth for particular service-port. The annotation key should be auth.istio.io/{port_number}, and the value should be NONE (to disable), or MUTUAL_TLS (to enable).
>
> Example: disable Istio Auth on port 9080 for service details.
> So, the solution is to keep your health check on a different port than your main service, and in your service definition exempt the health check port from mTLS using the annotation "auth.istio.io/<SERVICE PORT>: NONE"
> 
> Feel free to re-open if there're other aspects of the question not answered, or if you hit more issues with the same.


```yaml
kind: Service
metadata:
name: details
labels:
  app: details
annotations:
  auth.istio.io/9080: NONE
```

# 解決策

1. 特定portにおけるTCP, HTTP通信を許可するようistio authを許可する
    - この方法を取るときは、通常のサービス感通信では利用しないポートを開けておくことが求められる
1. pod内でcurlを叩くことによって解決する

see also https://istio.io/help/faq/security/#k8s-health-checks

1がスマートに見えるけどセキュリティ的な配慮はどうあるべきだろうか？
また、imageにcurl入れる必要があるのもいまいちにも感じる。
