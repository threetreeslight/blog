+++
date = "2018-11-10T12:00:00+09:00"
title = "Istio Traffic Management"
tags = ["kubernates", "k8s", "istio", "traffic"]
categories = ["programming"]
+++

[istio](https://istio.io/) のtraffic managemntするためのresoruceについて学ぶ。

（誤りがあるかもしれない点は了承ください）

# What is Istio?

kubernetes上にservice meshを実現するフレームワークです

# decouples traffic flow and infrastructure scaling

上記に記述されたようにtraffic flowとscalingが切り離されている。

触っているとこれが本当によくできているように感じる。

![](https://istio.io/docs/concepts/traffic-management/TrafficManagementOverview.svg)

以下のようなことが宣言的に設定できるようになる。

- mirraring
- 仮想的なlatencyを付与
- load balancingのweight
- 特定のheader情報のユーザーだけ制御

宣言的に設定できるということは、大分カスタマイズされているということだ。

# Istio Custom Resources

これらのtraffic managementを実現するためにIstioでは以下のcustom resourceを定義している

1. VirtualService
1. DestinationRule
1. ServiceEntry
1. Gateway

外部から通信が会ったときのresourceの流れを簡単に示す。

（ちょっと怪しい）

```yaml
-> Gateway
    -> VirtualService
        -> Service
            -> DistinationRule
                -> Deployment A
                -> Deployment B
                -> Deployment C
                    -> ServiceEntry
```

## VirtualService

VirtualServiceはkubernetes Service へのrequestがあったときに、それをservice mesh内でどのservice およびそのsubsetにroutingするかを定義する。

DistinationRuleで定義されたsubsetを利用して以下のような制御を行うことが可能となる。

- mirraring
- 仮想的なlatencyを付与
- load balancingのweight
- 特定のheader情報のユーザーだけ制御

なお、複数ホスト(kubernetes service)を一つのVirutualServiceとして取り扱うのは、システムマイグレーションを意識してのことだと推察。

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: productpage
spec:
  hosts:
  # FQDNであれば自由に指定できる
  - old.productpage.com
  - productpage
  http:
  # 5%のtrafficはv2に流す
  - route:
    - destination:
        host: productpage
        subset: v1
      weight: 95
    - destination:
        host: old.productpage.com
        subset: v2
      weight: 5
    # 10secでtimeoutする
    timeout: 10s
  # 元のlabelから通信の制御もできる
  - match:
    - sourceLabels:
        app: reviews
        version: v2
  # aliceは500エラー
  - match:
    - headers:
        end-user:
          exact: alice
    fault:
      abort:
        percent: 100
        httpStatus: 500
    route:
    - destination:
        host: productpage
        subset: v1
  # bobは2sec遅延する
  - match:
    - headers:
        end-user:
          exact: bob
    fault:
      delay:
        percent: 100
        fixedDelay: 2s
    route:
    - destination:
        host: productpage
        subset: v1
```

## DestinationRule

VirtualServiceへのRequest(routing) が発生したときに適用されるポリシー

- いわゆるkubernetes service resourceをhostとして取り扱い、circuit breakers, load balancer, TLSのsettingを行う
- kubernetes serviceのrouting先であるdeploymentのcontainer labelを使って、serviceのsubsetを作ることができる
- そのsubsetを用いることでapiのversioning、canary release、通信をミラーしたsmoke testの実施が用意になる

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: productpage
spec:
  # kubernetes service nameを利用して接続先を定義する
  host: productpage
  trafficPolicy:
    tls:
      mode: ISTIO_MUTUAL
  # deploymentのlabelを利用したsubsetの定義
  subsets:
  - name: v1
    labels:
      version: v1
  - name: v2
    labels:
      version: v2
    # simple circit breaker setting
    trafficPolicy:
      connectionPool:
        tcp:
          maxConnections: 100
  # canary subset
  - name: edge
    labels:
      version: edge
```

### ServiceEntry (Egress)

Istio内部でのサービスRequestに対し、十分な制御を行うことがこれでできるようになりました。
しかし、service mesh外部へのrequestにおいては自由にアクセスでき、なおかつTLSやcircit breaker設定ができない状態です。

そのため、ServiceEntry resourceを定義することでIstioの恩恵を得ることができるようになります。

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: bar-foo-ext-svc
spec:
  hosts:
    - bar.foo.com
  http:
  - route:
    - destination:
        host: bar.foo.com
    timeout: 10s
```

なお、推奨はされていないが、特定IPrangeへのアクセスを許可する方法もある。

containerから稼働ホストやInstanceのlabelを逆引きするAPIなどを考えると、使えるのかも知れません。

## Gateway

IstioにおけるゲートウェイはHTTP / TCPトラフィック用のロードバランサの構成。
Kubernetes Ingressとは異なり、Istio GatewayはL4-L6機能（ポートの公開、TLS設定など）のみを設定します。 

定義されたGatewayを用いて、外部からのアクセスをVirtualServiceにroutingします


```yaml
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: bookinfo-gateway
spec:
  selector:
    istio: ingressgateway # use istio default controller
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "*"
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: bookinfo
spec:
  hosts:
  - "*"
  gateways:
  - bookinfo-gateway
  http:
  - match:
    - uri:
        exact: /productpage
    - uri:
        exact: /login
    - uri:
        exact: /logout
    - uri:
        prefix: /api/v1/products
    route:
    - destination:
        host: productpage
        port:
          number: 9080
```

# Management by pilot and envoy

- Istioは各podの通信制御にenvoyを利用する。
- Istioによってenvoyは勝手にpodに付与される（制御可能）
- envoyはpilotからのhealth checkによってdiscoverされる
- envoyの通信状態に変化(cirkit breakerで落ちるなど)するとpilotのapiへその情報を通知し、pilotがその情報を伝搬する

このため、pilotはそれなりにリソースが必要となる。
