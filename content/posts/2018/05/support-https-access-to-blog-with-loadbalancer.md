+++
date = "2018-05-13T22:38:00+09:00"
title = "support https access to blog with loadbalancer"
tags = ["gcp", "https", "loadbalancer"]
categories = ["programming"]
+++

GCPを触れば触るほどmodule化されているんだなぁと関心。

GCS単体ではhttpsアクセス出来ないので、前段にloadbalancerを噛ませてhttpsアクセスできるようにしてみる。

## 構成

GCPのloadbalancerはawsとだいぶ違う。
そのため、全体像を事前に理解しておくために [コンテンツ ベースの負荷分散の作成](https://cloud.google.com/compute/docs/load-balancing/http/content-based-example) をやっておくと良い。

![](https://cloud.google.com/compute/docs/load-balancing/images/lb-content-based-www-video-ipv6.svg?authuser=1)

出典: [コンテンツ ベースの負荷分散の作成](https://cloud.google.com/compute/docs/load-balancing/http/content-based-example)

今回はGCSへ転送するので、backend-serviceではなくbackend bucketを利用します。

```
IP <-> forwarding rule <-> target proxy <-> url-map <-> backend-buckets <-> gcs
```

AWSとだいぶ異なるため、それぞれの構成要素がawsでいうと何に当たるのかをマッピングして説明します。

1. IP
    1. entrypointとなるIP address. gcpから払い出しておく必要がある
    1. AWSのように作成されたloadbalancerに勝手にentrypointが出来るものではなく、IPを払い出し明示的に割り当てる必要がある
1. forwarding rule
    1. 指定されたip, portへのrequestを何処に転送 (target proxy) するか決まったルール
    1. 特定のloadbalancerに必ず紐づくものではない。
    1. AWSでいうとalbのlistenerあたりが近い。また、security groupが無いということ。
1. target proxy
    1. URL マップにリクエストの経路を指定するターゲット HTTP プロキシ。そのため、https access時の認証を行うssl証明書はtarget proxyが保持する
    1. AWSでいうlistenerが近い。
1. url-map
    1. リクエストの URL を解析し、リクエスト URL のホストとパスに基づいて、特定のバックエンド サービスに特定のリクエストを転送。
    1. AWSでいうとtaget groupが近い
1. backend-bucket
    1. url-mapをもとに決定された転送先。
    1. backend-serviceを利用するとインスタンスのhealthcheckまでを責務を持つものに成る。
    1. url-mapとbackend-bucketをあわせることで、awsでいうtarget groupになる。

## Creating Content-Based Load Balancing

gcs bucketにアクセスをつなぐbackend bucketを作成します。
事前に `blog.threetreeslight.com` gcs bucketが作成済みの前提です。

```sh
$ gcloud compute backend-buckets create blog-threetreeslight-bucket --gcs-bucket-name blog.threetreeslight.com
```

URLを解析して接続するbackendを決定するurl mapを作成します。
事前にbackend service/bucketを作成するのは、最低限一つ以上url mapに転送先を設定しておく必要があるためです。

```sh
$ gcloud compute url-maps create blog-threetreeslight-com \
--default-backend-bucket blog-threetreeslight-bucket
```

次にtarget proxy を作成します。
http, https用に作成する必要があります。

なお、httpsをつくるためにssl証明書は作成されている前提です。

```sh
# create ssl-certificate
gcloud compute ssl-certificates create threetreeslight-com \
--certificate [CRT_FILE_PATH] \
--private-key [KEY_FILE_PATH]

# create proxy rule
$ gcloud compute target-http-proxies create blog-threetreeslight-com-proxy \
--url-map blog-threetreeslight-com
$ gcloud compute target-https-proxies create blog-threetreeslight-com-https-proxy \
--url-map blog-threetreeslight-com --ssl-certificates threetreeslight-com
```

これでhttps, http requestをbackend-bucketにproxyする準備が整いました。

入口となるIPとfowarding ruleの作成に入ります。

まず、DNSのendpointに割り当てるIPを作成します。

```sh
$ gcloud compute addresses create blog-threetreeslight-lb-ipv4 \
--ip-version=IPV4 \
--global

$ gcloud compute addresses list
NAME                          REGION  ADDRESS        STATUS
blog-threetreelsight-lb-ipv4          35.190.87.124  IN_USE
```

作成されたIP addressとtarget proxyを利用して、forwarding ruleを作成します。

```sh
$ gcloud compute forwarding-rules create blog-threetreeslight-com-http-rule \
--address 35.190.87.124 \
--global \
--target-http-proxy blog-threetreeslight-com-proxy \
--ports 80

$ gcloud compute forwarding-rules create blog-threetreeslight-com-https-rule \
--address 35.190.87.124 \
--global \
--target-https-proxy blog-threetreeslight-com-proxy \
--ports 443

$ gcloud compute forwarding-rules list
NAME                                 REGION  IP_ADDRESS     IP_PROTOCOL  TARGET
blog-threetreeslight-com-http-rule           35.190.87.124  TCP          blog-threetreeslight-com-proxy
blog-threetreeslight-com-https-rule          35.190.87.124  TCP          blog-threetreeslight-com-proxy
```

あとは作成したIP addressを利用した A recordを追加すればhttps accessができるようになった。

## VPCはどこにいったのか？

[HTTP(S) 負荷分散の設定](https://cloud.google.com/compute/docs/load-balancing/http/?hl=ja) が示すように、gcpではglobalにload balancerが配置される。

こうするとforarding rule <-> gcsまでの通信は一体何で行われるのか？と気になる。

> HTTP(S) 負荷分散は、IPv4 アドレスと IPv6 アドレスのクライアント トラフィックに対応しています。クライアントの IPv6 リクエストはグローバル負荷分散層で終了し、IPv4 経由でバックエンドに送信されます。

また、 [オプション: 要塞ホストを除く外部 IP の削除](https://cloud.google.com/compute/docs/load-balancing/http/content-based-example?authuser=1#optional_removing_external_ips_except_for_a_bastion_host)にて、以下のように記述されている。

> HTTP(S) 負荷分散サービスは、ターゲットの外部 IP ではなく内部 IP を使用します。負荷分散サービスが動作するようになると、負荷分散サービスのターゲットから外部 IP を削除することによってセキュリティを強化でき、中間インスタンスを経由して接続することで、負荷分散されたインスタンスでタスクを実行できるようになります。これで、VPC ネットワーク外部のユーザーは、ロードバランサ経由以外の方法ではアクセスできなくなります。

このことから、GCPにおけるVPCはregion単位ではなく、globalな単位で作用するものだということが分かる。

如何に詳しく書いてあった。
[Google VPC を特徴づける 4 つのキーワード](https://cloudplatform-jp.googleblog.com/2017/07/reimagining-virtual-private-clouds.html)

googleすごすぎる

