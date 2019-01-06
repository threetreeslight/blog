+++
date = "2019-01-05T12:00:00+09:00"
title = "How to ssl access with Google-Managed certificate on GKE"
tags = ["kubernetes", "k8s", "ssl", "GCLB", "GKE"]
categories = ["programming"]
+++

GCPでは2018-10頃よりGCLBにGoogle-Managed certificateを利用できるようになったので、GCLB on GKEで利用できるように設定していく。


## Create Google-Managed Certificate manually

まずはgoogle managed certificateをGCLBに利用するにはどうしたらよいのか、とりあえずマニュアルで使ってみる。

[Google Cloud - Creating a Google-managed SSL certificate resource](https://cloud.google.com/load-balancing/docs/ssl-certificates#create-managed-ssl-cert-resource)

発行される証明書はDV証明書であるため、何かしらの形でDNS recordで確証が取れる必要がある。

このときGoogle Managed Certificateでは以下を満たすことで、GCLBとの疎通確認ができることが証明され証明書のprovisioningを実現する。

![](/images/blog/2019/01/lb-content-based-www-video-ipv6.svg)
from [GCP - Creating Content-Based Load Balancing](https://cloud.google.com/load-balancing/docs/https/content-based-example)

1. domainのDNSレコードは、GCLBのtarget proxyのIPを参照する
1. target proxyはGoogleが管理する証明書リソースを参照する
1. forwarding ruleの作成など、ロードバランサーの設定が完了している

つまり流れとしては以下

1. certificate申請後
1. GCLBの作成
1. httpsのforwarding-ruleを作成する

### Create Certificate

まずはcertificateをapply

```sh
% gcloud beta compute ssl-certificates create test-threetreeslight-com --domains test.threetreeslight.com

% gcloud beta compute ssl-certificates list
NAME                            TYPE     CREATION_TIMESTAMP             EXPIRE_TIME  MANAGED_STATUS
test-threetreeslight-com        MANAGED  2019-01-04T22:43:02.061-08:00               PROVISIONING
    test.threetreeslight.com: PROVISIONING
```


### Create Backend

とりあえず http requestに対してwwwと返すinstanceを準備

```sh
% gcloud compute instances create www \
    --image-family debian-9 \
    --image-project debian-cloud \
    --zone us-central1-b \
    --tags https-tag \
    --metadata startup-script="#! /bin/bash
      sudo apt-get update
      sudo apt-get install apache2 -y
      sudo a2ensite default-ssl
      sudo a2enmod ssl
      sudo service apache2 restart
      echo '<html><body><h1>www</h1></body></html>' | sudo tee /var/www/html/index.html
      EOF"


# create https access firewall
gcloud compute firewall-rules create www-firewall \
    --target-tags https-tag --allow tcp:443

# get instance ip
% gcloud compute instances list

# access test
% curl http://35.232.169.156
<html><body><h1>www</h1></body></html>
```

良い感じ。

### Create GCLB

続いてGCLBに利用するIPを準備し


```sh
% gcloud compute addresses create lb-ip-1 \
    --ip-version=IPV4 \
    --global
```

GCLBより接続するinstance groupを作成


```sh
# create group
% gcloud compute instance-groups unmanaged create www-resources --zone us-central1-b
# add instance
% gcloud compute instance-groups unmanaged add-instances www-resources \
    --instances www \
    --zone us-central1-b

# set firewall
% gcloud compute instance-groups unmanaged set-named-ports www-resources \
    --named-ports https:443 \
    --zone us-central1-b
```

GCLBを作成する

```sh
# create health check
% gcloud compute health-checks create https https-basic-check \
    --port 443

# create GCLB
% gcloud compute backend-services create web-map-backend-service \
    --protocol HTTPS \
    --health-checks https-basic-check \
    --global

# add backend service
% gcloud compute backend-services add-backend web-map-backend-service \
    --balancing-mode UTILIZATION \
    --max-utilization 0.8 \
    --capacity-scaler 1 \
    --instance-group www-resources \
    --instance-group-zone us-central1-b \
    --global

# create url map
% gcloud compute url-maps create web-map \
    --default-service web-map-backend-service

# create target proxy
% gcloud compute target-https-proxies create https-lb-proxy \
    --url-map web-map --ssl-certificates test-threetreeslight-com

# get address
% gcloud compute addresses list
NAME                    ADDRESS/RANGE  TYPE  PURPOSE  NETWORK  REGION  SUBNET  STATUS
lb-ip-1                 35.244.212.19                                          RESERVED

# create forwarding-rules
gcloud compute forwarding-rules create https-content-rule \
    --address 35.244.212.19 \
    --global \
    --target-https-proxy https-lb-proxy \
    --ports 443
```

上記で入手したIP addressにあわせ DNS recordを作成しておく

e.g. `test.threetreeslight.com A 35.244.212.19`

そして暫し待つと・・・

```sh
% gcloud beta compute ssl-certificates list
NAME                            TYPE     CREATION_TIMESTAMP             EXPIRE_TIME                    MANAGED_STATUS
test-threetreeslight-com        MANAGED  2019-01-04T22:43:02.061-08:00  2019-04-04T23:04:09.000-07:00  ACTIVE
    test.threetreeslight.com: ACTIVE
```

うん、いい感じにactiveになった

## 既存Ingressを手動でいじってActivate

要はforwarding ruleを手動でちょいちょいっと追加するかなにかしたらよしなにできるんでは？

適当にhello worldと返すserverを作り

```go
// hello worldをserver
package main

import (
	"fmt"
	"net/http"
)

func helloWorld(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello, world!\n")
}

func main() {
	http.HandleFunc("/", helloWorld)
	http.ListenAndServe(":8080", nil)
}
```

ingressを書く

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: app
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: http-hello
  namespace: sandbox
spec:
  replicas: 1
  selector:
    matchLabels:
      app: http-hello
  template:
    metadata:
      labels:
        app: http-hello
    spec:
      containers:
        - name: http-hello
          image: eu.gcr.io/managed-certs-gke/http-hello:ci_latest
          imagePullPolicy: Always
          ports:
            - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: http-hello
  labels:
    app: http-hello
spec:
  type: NodePort
  ports:
    - port: 8080
  selector:
    app: http-hello
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: test-ingress
  namespace: sandbox
spec:
  backend:
    serviceName: http-hello
    servicePort: 8080
```

certificateを発行して

```sh
% gcloud beta compute ssl-certificates create sandbox-threetreeslight-com --domains sandbox.threetreeslight.com

% gcloud beta compute ssl-certificates list
NAME                            TYPE     CREATION_TIMESTAMP             EXPIRE_TIME                    MANAGED_STATUS
sandbox-threetreeslight-com     MANAGED  2019-01-04T23:58:29.659-08:00                                 PROVISIONING
    sandbox.threetreeslight.com: FAILED_NOT_VISIBLE
```

作成されたingressにhttpsのforntend ruleを追加する

![](/images/blog/2019/01/2019-01-05-sandbox-provisioning.png)

暫し待つとActivateされる

```sh
% gcloud beta compute ssl-certificates list
NAME                            TYPE     CREATION_TIMESTAMP             EXPIRE_TIME                    MANAGED_STATUS
sandbox-threetreeslight-com     MANAGED  2019-01-04T23:58:29.659-08:00  2019-04-06T01:19:22.000-07:00  ACTIVE
    sandbox.threetreeslight.com: ACTIVE
```

Ingressをちょいっと更新して

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: test-ingress
  namespace: sandbox
  annotations:
      ingress.gcp.kubernetes.io/pre-shared-cert: "sandbox-threetreeslight-com"
spec:
  backend:
    serviceName: http-hello
    servicePort: 8080
```

アクセスると

```sh
% curl https://sandbox.threetreeslight.com
Hello, world!
```

いい感じにできました

## Migrating to Google-managed SSL certificates

さて、上記で新規domainに係る通信に追いて、ちょいちょいっと触りこむだけでCertificateを発行しActivateすることができることがわかった。

とはいえ、frontend ruleを追加するということは、若干のdowntimeが生まれてしまうのでは？という懸念が大きい。

良い方法があるのだろうか？と考え [Migrating a load balancer from using self-managed SSL certificates to Google-managed SSL certificates](https://cloud.google.com/load-balancing/docs/ssl-certificates#migrating_a_load_balancer_from_using_self-managed_ssl_certificates_to_google-managed_ssl_certificates) を読み込んでいく。


migrateするためには以下の手順とのこと。

1. Google Managed Certificateを作成
1. Certificate resourceを既存のtarget proxyに追加
1. Google-managed certificateがActiveになるまで待つ
1. self-managed certifcateのtarget proxyを剥がす

うん、だいたいイメージ通り。やってみよう

Certificateの発行

```sh
% gcloud beta compute ssl-certificates create threetreeslight-com --domains threetreeslight.com

% gcloud beta compute ssl-certificates list
NAME                            TYPE     CREATION_TIMESTAMP             EXPIRE_TIME                    MANAGED_STATUS
threetreeslight-com             MANAGED  2019-01-06T01:41:50.348-08:00                                 PROVISIONING
    threetreeslight.com: PROVISIONING
```

Ingressに直接発行したcertificateを追記

```diff
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: lb
  namespace: app
  annotations:
      kubernetes.io/ingress.global-static-ip-name: "blog-gke"
      kubernetes.io/ingress.allow-http: "true"
-      ingress.gcp.kubernetes.io/pre-shared-cert: "threetreeslight-com-2018-12-22"
+      ingress.gcp.kubernetes.io/pre-shared-cert: "threetreeslight-com-2018-12-22, threetreeslight-com"
```

上記のmanaged certificate resourceをaddtional certificateに設定

![](/images/blog/2019/01/2019-01-05-migrate-certificate.png)

こんな感じになる

![](/images/blog/2019/01/2019-01-05-migrate-certificate.png)

暫く待つとactivate

```sh
% gcloud beta compute ssl-certificates list
NAME                            TYPE     CREATION_TIMESTAMP             EXPIRE_TIME                    MANAGED_STATUS
threetreeslight-com             MANAGED  2019-01-06T01:41:50.348-08:00  2019-04-06T02:00:26.000-07:00  ACTIVE
    threetreeslight.com: ACTIVE
```

self-managedのcertificateを外す

```diff
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: lb
  namespace: app
  annotations:
      kubernetes.io/ingress.global-static-ip-name: "blog-gke"
      kubernetes.io/ingress.allow-http: "true"
+      ingress.gcp.kubernetes.io/pre-shared-cert: "threetreeslight-com"
```

Downtimeもなくいい感じ

## GKE上でそのまま使えないの？

[GoogleCloudPlatform/gke-managed-certs](https://github.com/GoogleCloudPlatform/gke-managed-certs) なるものを見つけ、これは、、、と思ったのだが **Work In Progressである**

> Pretty excited to see this out there so maybe I jumped the gun a bit but I can't get it to work with my cluster.
> -- https://github.com/GoogleCloudPlatform/gke-managed-certs/issues/2

と、Issueが立ってしまうぐらい、そのまま動く予感のあるものだった

### ingress-gceへmargeされている

[ingress-gce - Implement support for ManagedCertificate CRD #508](https://github.com/kubernetes/ingress-gce/pull/508) をみるとmergeされているようだ。

直近の [Nov 6, 2018 release](https://github.com/kubernetes/ingress-gce/releases/tag/v1.4.0)には含まれていないようなので、時期にGKE上へリリースされるでしょう。

### [GoogleCloudPlatform/gke-managed-certs](https://github.com/GoogleCloudPlatform/gke-managed-certs) の方針

1. Google Managed Certificateを定義するためのCustomResourceDifinision(CRD)を追加
1. 上記定義に基づいたCertificateの発行や設定処理を行うcontroller deployment と、その操作を行うservice accountを追加

1にて定義されるmanaged certificateは以下。なお、制約として64文字以下のnameであることと、certificateに紐付けられるdomainは1つのみであるということぐらい

```yaml
apiVersion: gke.googleapis.com/v1alpha1
kind: ManagedCertificate
metadata:
  name: threetreeslight-com
spec:
  domains:
    - threetreeslight.com
```

ingressには以下のようにannotationを追加することで処理される見込み

```diff
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: lb
  namespace: app
  annotations:
      kubernetes.io/ingress.global-static-ip-name: "blog-gke"
      kubernetes.io/ingress.allow-http: "true"
+      gke.googleapis.com/managed-certificates: "threetreeslight-com"
spec:
  rules:
  - host: "threetreeslight.com"
    http:
      paths:
      - backend:
          serviceName: blog
          servicePort: 8080
```

## References

- [Google Cloud - Working with Google-managed SSL certificates](https://cloud.google.com/load-balancing/docs/ssl-certificates#managed-certs)
- [GoogleCloudPlatform/gke-managed-certs](https://github.com/GoogleCloudPlatform/gke-managed-certs)
  - [Issue - No frontend configured on load balancer #2](https://github.com/GoogleCloudPlatform/gke-managed-certs/issues/2)
- [ingress-gce - Implement support for ManagedCertificate CRD #508](https://github.com/kubernetes/ingress-gce/pull/508)

