+++
date = "2018-09-22T17:00:00+09:00"
title = "Why do we need service mesh?"
tags = ["kubernates", "k8s", "istio", "service mesh", "micro service"]
categories = ["programming"]
+++

最近巷でIstioに代表されるservice meshの話を聞くようになりました。

そんなservice mesh、全く理解できていない。

[Phil Calçado - Pattern: Service Mesh](http://philcalcado.com/2017/08/03/pattern_service_mesh.html) などをヒントに、なぜservice meshというものが必要となってきたのか理解を深めていきます。

コンピューターサイエンスをちゃんとやってきたプログラマーではないので、誤っている可能性は多分にあるので、その点は理解ください。

## [Distributed System](https://en.wikipedia.org/wiki/Distributed_computing)

世の中のサービスの大半は、複雑度の違いはあれど分散システムとして構成されることを前提とされている。

> A distributed system is a system whose components are located on different networked computers, which then communicate and coordinate their actions by passing messages to one other

とあるように、分散システムとは、ネットワーク上の異なるコンピュータ上にコンポーネントが配置されているシステムとして考えて良い。
例えば、AWS上のマネージドサービスを使っていたら分散システムであるといえる。

service A,B が存在し、それが通信してやりとりする分散システムを例になぜ必要となるのか考えを深めていく。

## 牧歌的な分散システム

サービス間はメッセージをやりとりするための、通信のスタックがあり、その通信スタックを経由してservice間の通信を行う

![](http://philcalcado.com/img/service-mesh/4.png)

これで良くない？と思うかもしれないが、分散システムには気をつけなければならないことはとても多い。

### [Fallacies of distributed computing](https://en.wikipedia.org/wiki/Fallacies_of_distributed_computing)

L Peter DeutschやSun Microsystemsの他の人が書いた、「分散アプリケーションを初めて使うプログラマは常に間違っている」という話があるようです。

> [Fallacies of distributed computing](https://en.wikipedia.org/wiki/Fallacies_of_distributed_computing)
>
> 1. ネットワークは落ちない
> 1. 遅延はゼロ
> 1. 無限の帯域
> 1. セキュア
> 1. 変更されないトポロジ
> 1. 一人の管理者
> 1. 転送コストはゼロ
> 1. 均一なネットワーク

一見するととても当たり前のことを書いてあるように見えるのですが、上記に関わる対策がアプリケーションコードとして実装できているか？というと、そうでもありません。

> [The effects of the fallacies](https://en.wikipedia.org/wiki/Fallacies_of_distributed_computing)
>
> 1. 大抵のアプリケーションはnetwork error handingがなされていない。そうすると、
>   1. ネットワークの停止中、アプリケーションは応答パケットを失速させるか無限に待機し、メモリやその他のリソースを恒久的に消費しつづけるます。
>   1. 障害が発生したnetworkが復旧されたとしても、止まっていた操作を再試行できないか、アプリケーションを再起動する必要があります。
> 1. ネットワークレイテンシと、それが引き起こす可能性があるパケットロスを意識できていない場合、開発者は無制限のトラフィックをもっているのとどうぎです。そのため、パケットの損失を大幅に増加させ、帯域幅を無駄に消費します。
> 1. 送信側の帯域幅の上限を無視すると、容易にボトルネックが発生する可能性があります。
> 1. ネットワークセキュリティに対する寛容さは、セキュリティ対策に絶えず適応している悪意のあるユーザーやプログラムの格好の的になります。
> 1. ネットワークトポロジは変更されます。それを理解できないと帯域幅と遅延の両方の問題に直面します。
> 1. 複数の管理者が存在するので、期待するネットワークをいつのまにか通らなくなってしまうかもしれません。
> 1. ネットワークやサブネットを構築し維持するための「隠れた」コストは無視できないものであり、結果的に膨大な不足を避けるために予算内に留意する必要があります。
> 1. システムが同種のネットワークを想定している場合、最初の3つの誤りから生じる同じ問題につながる可能性があります。

現代ではクラウドベンダーによって会計つされている問題も多くあります。

逆に言うと、クラウドベンダーがどのようなネットワーク構成になっているのかをイメージしながらシステムを構築していくことを求められる時代になったと言えるかもしれません。

### マイクロサービスで失敗しないために求められる分散システム要件

さらに以下のようなこのとも求められるマイクロサービス時代。

> [Martin Fowler - MicroservicePrerequisites](https://martinfowler.com/bliki/MicroservicePrerequisites.html)
>
> 1. Rapid provisioning
> 1. Basic monitoring
> 1. Rapid application deployment

上記にくあえ、Phil Calçadoさんがdigitalオーシャン時代以下も必要だったと述べています。

> [Calçado's Microservices Prerequisites](http://philcalcado.com/2017/06/11/calcados_microservices_prerequisites.html)
>
> 1. Easy to provision storage
> 1. Easy access to the edge
> 1. Authentication/Authorisation
> 1. Standardised RPC

APIの標準化とか、マイクロサービスにおける認証認可の問題とかやばいです。

対応は地道にやらなければいけないのですが、 開発者もDevOpsも必要とされる知識やそのメンテナンスに多大な労力を払うことが求められます。

## まず、対策するために必要なこと

対応するためには、以下の２つが分散システムに実装する必要があります。

1. service discovery
1. circuit breakers

![](http://philcalcado.com/img/service-mesh/5.png)

### Service Discovery

> 
> Service discovery is the automatic detection of devices and services offered by these devices on a computer network. 

特定のリクエスを満たすサービスのホストやコンテナを発見・通信先として登録するサービスです。

古典的なservice disovery手法は以下の２つ。

1. DNS
1. load balancer

これで済む場合は全く問題はないのですが、以下のような要件を満たす複雑なサービスディスカバリが求められると対応が困難になってきます。

1. clientの負荷分散
1. staging, productionなどの異なる環境
1. 複数のリージョン、クラウドに散らばる

誰と通信してよいか制御するのが辛い

> TODO: どんな感じに辛くなるのかを想定する

### circuit brakers

[Fallacies of distributed computing](https://en.wikipedia.org/wiki/Fallacies_of_distributed_computing) にあるとおり、生きているように見せかけて死んでいく問題に対策する概念です。

> [Martin Fowler - CircuitBreaker](https://martinfowler.com/bliki/CircuitBreaker.html)
>
> - Remote Requestは、timeoutになるまでhangする
> - その状態で多数のrequestがくるとresourceを食いつぶして死ぬかもしれない

この問題を解決するために、いかのようにcircuit brakers patternを用いて無駄なrequestを送らないようにします。

![](https://martinfowler.com/bliki/images/circuitBreaker/sketch.png)

### 共通する課題

1. 開発者はservice discoveryを意識し、どのように通信元のサービスにその情報を通知するのか考えなければいけない
1. circit brakersは有効だが、同じようなコードを忘れず、書き続ける必要がある

![](http://philcalcado.com/img/service-mesh/6.png)

しかし、責務は分離されたものの、実装は開発者に任されるのは望ましくありません。

そのためのSDKを提供され、各アプリケーションで利用される方針が多く採用されましたが、特に認証・認可で問題がありました。

- サービスごとにリリースサイクルは異なる
- SDK提供する言語でしか効果がない

結果、SDKが揃わず、常に開発者はこれに意識を払わなければいけません

## Welcome to service mesh

この問題を解決するために、service discoveryとcircit braker機能をもった通信をproxyするsidecarアプローチが取られるようになりました。

![](http://philcalcado.com/img/service-mesh/6-a.png)

- Buoyant’s CEO William Morganによって2017年 service meshという言葉爆誕
- だったら、deployされたら勝手に追加すれば良くないか？というのがservice meshの考え方

kubernatesやmethosのようなモダンなresrouce management runtimeの登場、そして利用に後押しされ、service meshの現実的な実装がおいついてきた。

一方で、proxy-to-proxy通信のlayerが独立したということは、その通信先、アクセスの制御が必要となります。

## Envoy、そしてIstio。

enjoy distributed microservice architecture

## ref

- [Phil Calçado - Pattern: Service Mesh](http://philcalcado.com/2017/08/03/pattern_service_mesh.html)
- [wiki - Distributed System](https://en.wikipedia.org/wiki/Distributed_computing)
- [wiki - The effects of the fallacies](https://en.wikipedia.org/wiki/Fallacies_of_distributed_computing)
- [Martin Fowler - MicroservicePrerequisites](https://martinfowler.com/bliki/MicroservicePrerequisites.html)
- [Calçado's Microservices Prerequisites](http://philcalcado.com/2017/06/11/calcados_microservices_prerequisites.html)
- [Martin Fowler - CircuitBreaker](https://martinfowler.com/bliki/CircuitBreaker.html)
- [wiki - service discovery](https://en.wikipedia.org/wiki/Service_discovery)
- [SOTA - Service meshとは何か](https://deeeet.com/writing/2018/05/22/service-mesh/)
- [The mechanics of deploying Envoy at Lyft](https://schd.ws/hosted_files/kccncna17/87/Kubecon%2012%252F17.pdf)
- [Orilly - seeking SRE](http://shop.oreilly.com/product/0636920063964.do)
- [Introducing Istio Service Mesh for Microservices](https://developers.redhat.com/books/introducing-istio-service-mesh-microservices/)
- [The mechanics of deploying Envoy at Lyft](https://schd.ws/hosted_files/kccncna17/87/Kubecon%2012%252F17.pdf)

