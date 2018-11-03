+++
date = "2018-10-08T12:00:00+09:00"
title = "Helm Getting Started"
tags = ["kubernates", "k8s", "helm"]
categories = ["programming"]
+++

helmを雰囲気で使っていたので、この際ちゃんと調べてみようと思う。

## What is helm

helm ( https://helm.sh/ ) とは、CNCF ( https://www.cncf.io/ ) でhostingされているkubernetes上のpackage manager。

Helmは複雑なkubernetesの設定ファイル(spec)をtemplate化されることでpackage化されている。
そうすることで、同じようなyamlを何度も書くような煩雑なspec記述作業から開放されることを目的に作られている（多分）。

> stop the copy-and-paste madness.

という表現がまさにそれを物語っているように思える :thinking:

このtemplate化されたyamlの集合 = package = chart と呼ばれ、localだけではなくgoogleにhostingされているchartも利用することができる。

## How to apply package

```
helm client
-create w/ chart-> tiller(on local OR cluster)
-create w/ chart-> Estanblished package resouces!
```

## What is Chart

もう少しchartについてほってみる。chartは基本的にkubernetes resouceのsetを表現している。

Istioに同梱されているchartを参考に見ていく。

https://github.com/istio/istio/blob/master/install/kubernetes/helm/

### Chart.yaml

Chatの命名やversionなどの定義が記述されている。

versionによってtillerがcustom resouceの作成などできなかったりするので、tillerのversionは大事。

```yaml
apiVersion: v1
name: istio
version: 1.0.1
appVersion: 1.0.1
tillerVersion: ">=2.7.2-0"
description: Helm chart for all istio components
keywords:
  - istio
  - security
  - sidecarInjectorWebhook
  - mixer
  - pilot
  - galley
sources:
  - http://github.com/istio/istio
engine: gotpl
icon: https://istio.io/favicons/android-192x192.png
```

### requirements.yaml

chartに依存するchartを記述する。
その依存をinstallするか制御するcondition parameterなども記述することができる。

例えば、istioのisntallにgrafanaとprometheus一緒に入れるか？など

```yaml
dependencies:
  - name: sidecarInjectorWebhook
    version: 1.0.1
    condition: sidecarInjectorWebhook.enabled
  - name: security
    version: 1.0.1
    condition: security.enabled
  - name: ingress
    version: 1.0.1
    condition: ingress.enabled
  - name: gateways
    version: 1.0.1
    condition: gateways.enabled
  - name: mixer
    version: 1.0.1
    condition: mixer.enabled
  - name: pilot
    version: 1.0.1
    condition: pilot.enabled
  - name: grafana
    version: 1.0.1
    condition: grafana.enabled
  - name: prometheus
    version: 1.0.1
    condition: prometheus.enabled
  - name: servicegraph
    version: 1.0.1
    condition: servicegraph.enabled
  - name: tracing
    version: 1.0.1
    condition: tracing.enabled
  - name: galley
    version: 1.0.1
    condition: galley.enabled
  - name: kiali
    version: 1.0.1
    condition: kiali.enabled
  - name: certmanager
    version: 1.0.1
    condition: certmanager.enabled
```

### values.yaml

requirements.yaml のconditionの初期値など、様々な値が設定される

```yaml
# Common settings.
global:
  # Default hub for Istio images.
  # Releases are published to docker hub under 'istio' project.
  # Daily builds from prow are on gcr.io, and nightly builds from circle on docker.io/istionightly
  hub: docker.io/istio

  # Default tag for Istio images.
  tag: 1.0.2
...
prometheus:
  enabled: true
  replicaCount: 1
  hub: docker.io/prom
  tag: v2.3.1
...
```

また、このvalueはhelm install時に上書きすることもできる

```sh
helm install install/kubernetes/helm/istio \
--name istio --namespace istio-system \
--set prometheus.enabled=false
```

### templates

あとはよくあるkubernetes resourceを `templates/` 配下に入れておけばOK。

Go Template languageが使えるので、valueなどの定義がうまくできると何かと良い。

```yaml
{{- if not .Values.global.omitSidecarInjectorConfigMap }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: istio-sidecar-injector
  namespace: {{ .Release.Namespace }}
  labels:
    app: {{ template "istio.name" . }}
    chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
    release: {{ .Release.Name }}
    heritage: {{ .Release.Service }}
    istio: sidecar-injector
data:
  config: |-
    policy: {{ .Values.global.proxy.autoInject }}
    template: |-
      initContainers:
      - name: istio-init
{{- if contains "/" .Values.global.proxy_init.image }}
        image: "{{ .Values.global.proxy_init.image }}"
{{- else }}
        image: "{{ .Values.global.hub }}/{{ .Values.global.proxy_init.image }}:{{ .Values.global.tag }}"
{{- end }}
        args:
...
```

## Install Helm

以下のQuick Startに則って作業する

https://docs.helm.sh/using_helm/#quickstart


helmがbrewで転がっているので、そちらを利用する

```sh
brew install kubernates-helm
```

helmを利用したいclusterを選択

```sh
% kubectl config current-context
gke_threetreeslight_us-west1-a_blog-cluster
```

helmはtiller containerを通して、pakcageのように設定のinstallを実施することができる。

そのため、tillerが利用する強い権限(cluster-admin)を持つアカウントを事前に作っておいたほうが良い。

```sh
% kubectl -n kube-system create serviceaccount tiller
serviceaccount "tiller" created

kubectl create --save-config clusterrolebinding tiller \
--clusterrole=cluster-admin \
--user="system:serviceaccount:kube-system:tiller"
```

対象のclusterにtiller containerなどをinstallする。

別clusterに別のservice accountを利用している場合のpracticeはあるんだろうか？

```sh
# tillerがcluster内に存在しない場合
$ helm init --service-account tiller
Creating /Users/threetreeslight/.helm
Creating /Users/threetreeslight/.helm/repository
Creating /Users/threetreeslight/.helm/repository/cache
Creating /Users/threetreeslight/.helm/repository/local
Creating /Users/threetreeslight/.helm/plugins
Creating /Users/threetreeslight/.helm/starters
Creating /Users/threetreeslight/.helm/cache/archive
Creating /Users/threetreeslight/.helm/repository/repositories.yaml
Adding stable repo with URL: https://kubernetes-charts.storage.googleapis.com
Adding local repo with URL: http://127.0.0.1:8879/charts
$HELM_HOME has been configured at /Users/threetreeslight/.helm.

Tiller (the Helm server-side component) has been installed into your Kubernetes Cluster.

Please note: by default, Tiller is deployed with an insecure 'allow unauthenticated users' policy.
To prevent this, run `helm init` with the --tiller-tls-verify flag.
For more information on securing your installation see: https://docs.helm.sh/using_helm/#securing-your-helm-installation
Happy Helming!

# tillerがすでにcluster内に存在する場合
$ helm init --client-only
```

Happy Helming! YEAH!

tiller podが立っていますね！よしよし。

```
% kubectl get pods --all-namespaces
NAMESPACE     NAME                                               READY     STATUS    RESTARTS   AGE
...
kube-system   tiller-deploy-9bdb7c6bc-qwlvr                      1/1       Running   0          24s
```

