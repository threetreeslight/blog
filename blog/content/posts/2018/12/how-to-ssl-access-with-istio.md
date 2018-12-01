+++
date = "2018-12-01T12:00:00+09:00"
title = "How to ssl access with istio"
tags = ["kubernates", "k8s", "ssl", "cert-manager", "istio"]
categories = ["programming"]
+++

IstioにおけるSSL通信のためにcert-managerを使ったほうが良いと謎の理解をしていて危うかったので、isitoのtraffic flowを改めて理解し

1. どのようにSSL通信する方法があるのか
1. 今回はどのような方法でアプローチするか

をまとめていく。

## Istio Traffic Flow

Istioがpublic internetを用いて通信するときは、公式ドキュメントにもある通り以下のような図となる。

![](/images/blog/2018/12/ServiceModel_RequestFlow.svg)

基本的にgatewayとServiceEntry resourceで通信を制御している。

ただ、これだけだと「ん？SSL通信どうするの？まったくわからん」という状態。

## Istio Service and Gateway resource

Istioの構成をより詳しく見ていくと、デフォルトでは以下のような流れであるようだ。

```sh
Public Internet -request-> service(type: loadbalancer) -gateway-> ...
```

### なぜこの構成なのか？

昔はingress controllerで処理されていたようだが、いまはserviceとして定義されている。

つまり、serviceのtypeを変更できるということ。こうすることで

1. serviceのtypeを `nodeport` なりにすることで既存loadbalancerからつなぎこむことができる
1. service meshへはhttpでアクセスすることができる

### Chart definision

helmの定義を見ていく。

https://github.com/istio/istio/blob/1.0.4/install/kubernetes/helm/istio/charts/ingress/templates/service.yaml

```yaml
apiVersion: v1
kind: Service
metadata:
  name: istio-ingress
  namespace: {{ .Release.Namespace }}
  labels:
    chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
    release: {{ .Release.Name }}
    heritage: {{ .Release.Service }}
    istio: ingress
  annotations:
    {{- range $key, $val := .Values.service.annotations }}
    {{ $key }}: {{ $val }}
    {{- end }}
spec:
{{- if .Values.service.loadBalancerIP }}
  loadBalancerIP: "{{ .Values.service.loadBalancerIP }}"
{{- end }}
  type: {{ .Values.service.type }}
{{- if .Values.service.externalTrafficPolicy }}
  externalTrafficPolicy: {{ .Values.service.externalTrafficPolicy }}
{{- end }}
  selector:
    istio: ingress
  ports:
    {{- range $key, $val := .Values.service.ports }}
    -
      {{- range $pkey, $pval := $val }}
      {{ $pkey}}: {{ $pval }}
      {{- end }}
    {{- end }}
---
```

Ingress chart values

https://github.com/istio/istio/blob/1.0.4/install/kubernetes/helm/istio/values.yaml#L191

```yaml
#
# ingress configuration
#
ingress:
  enabled: false
  replicaCount: 1
  autoscaleMin: 1
  autoscaleMax: 5
  service:
    annotations: {}
    loadBalancerIP: ""
    type: LoadBalancer #change to NodePort, ClusterIP or LoadBalancer if need be
    # Uncomment the following line to preserve client source ip.
    # externalTrafficPolicy: Local
    ports:
    - port: 80
      name: http
      nodePort: 32000
    - port: 443
      name: https
    selector:
      istio: ingress
```

なるほど、SSL通信するにはいくつかの方法が取れそうだ

## SSL access methotology with ingress

1. SSL対応したIngressからのIstioにつなぎこむ
  1. cloud provider ingress (cloud vendorの提供するloadbalancer)
  1. nginx ingress
1. Istio serviceをloadbalancer typeで稼働させ、証明書を設定する

次にそれぞれの場合どのように設定していくのかを見ていく

### cloud provider ingress

ingress切ってTLS証明書を設定する

https://cloud.google.com/kubernetes-engine/docs/concepts/ingress

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: lb
  namespace: ingress
  annotations:
      kubernetes.io/ingress.global-static-ip-name: <global_ip_name>
      ingress.gcp.kubernetes.io/pre-shared-cert: <cert_name>
spec:
  rules:
  - host: <your_domain_name>
    http:
      paths:
      - backend:
          serviceName: ingress
          servicePort: 8080
```

### nginx ingress

ここは別途まとめる

ざっくりとは以下を見ると良さそう

> Quick-Start using Cert-Manager with NGINX Ingress
> https://github.com/jetstack/cert-manager/blob/master/docs/tutorials/quick-start/index.rst

### Istio service

[Securing Gateways with HTTPS](https://istio.io/docs/tasks/traffic-management/secure-ingress/) を見ていくと、どこでhttps通信の複合をしているのか見えてくる

SSL通信の副業処理を行うのはistio gatewayになる。

このため、

1. SSL通信のためのcertificateはistio-system namespace (isitoが稼働するnamespace) にsecret resourceとして配置する
1. その `secretName` は `istio-ingressgateway-certs` とでなければいけない

> The secret must be called istio-ingressgateway-certs in the istio-system namespace, or it will not be mounted and available to the Istio gateway.

とあるが、 `secretName` は以下を変更できそう :eyes:

https://github.com/istio/istio/blob/1.0.4/install/kubernetes/helm/istio/values.yaml#L214

```yaml
gateways:
  enabled: true
  ...
  istio-ingressgateway:
    secretVolumes:
    - name: ingressgateway-certs
      secretName: istio-ingressgateway-certs
      mountPath: /etc/istio/ingressgateway-certs
    - name: ingressgateway-ca-certs
      secretName: istio-ingressgateway-ca-certs
      mountPath: /etc/istio/ingressgateway-ca-certs
```

以下のようにsecret登録すれば良い

```sh
$ kubectl create -n istio-system secret tls istio-ingressgateway-certs --key httpbin.example.com/3_application/private/httpbin.example.com.key.pem --cert httpbin.example.com/3_application/certs/httpbin.example.com.cert.pem
se
```

Gateway上で以下のようなtlsを設定をしておけばOK

```sh
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: mygateway
spec:
  selector:
    istio: ingressgateway # use istio default ingress gateway
  servers:
  - port:
      number: 443
      name: https
      protocol: HTTPS
    tls:
      mode: SIMPLE
      serverCertificate: /etc/istio/ingressgateway-certs/tls.crt
      privateKey: /etc/istio/ingressgateway-certs/tls.key
    hosts:
    - "httpbin.example.com"
```

## どれが良いのか？

正直わからないが以下のような感じ？

1. loadbalancerで高負荷をさばくことがない
  1. nginx ingress
1. 高負荷をさばいたりするなら
  1. cloud provider ingress
1. gatewayでhttps通信をしたい場合
  1. isito service with loadbalancer type
