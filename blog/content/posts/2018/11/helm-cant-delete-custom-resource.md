+++
date = "2018-10-13T12:00:00+09:00"
title = "Helm can't delete custom resoruce"
tags = ["kubernates", "k8s", "helm", "custom resource"]
categories = ["programming"]
+++

# Occation

prometheus resourceを削除したく、istioを削除 -> 再インストールしてみると以下のエラーにぶち当たる

```sh
$ kubectl delete -f $HOME/istio.yaml

$ helm install install/kubernetes/helm/istio \
--name istio \
--namespace istio-system \
--set prometheus.enabled=false

Error: customresourcedefinitions.apiextensions.k8s.io "gateways.networking.istio.io" already exists
```

istioを削除してもcustom resourceが消えないようだ。

# Cause

[Helm delete does not clean the custom resource definitions](https://github.com/istio/istio/issues/7688)

> herefore, since they are unmanaged Helm won't delete them. 
> Similar to the installation the users are expected to delete them by executing kubectl delete -f install/kubernetes/helm/istio/templates/crds.yaml -n istio-system.

なっるほど、helmはcustom resourceの削除をちゃんとできないとのこと。


# Uninstall

Istioのdocumentを見たらちゃんとその事書いてあった😇

https://istio.io/docs/setup/kubernetes/helm-install/#uninstall

```sh
% kubectl delete -f install/kubernetes/helm/istio/templates/crds.yaml -n istio-system
customresourcedefinition.apiextensions.k8s.io "virtualservices.networking.istio.io" deleted
customresourcedefinition.apiextensions.k8s.io "destinationrules.networking.istio.io" deleted
customresourcedefinition.apiextensions.k8s.io "serviceentries.networking.istio.io" deleted
customresourcedefinition.apiextensions.k8s.io "gateways.networking.istio.io" deleted
customresourcedefinition.apiextensions.k8s.io "envoyfilters.networking.istio.io" deleted
customresourcedefinition.apiextensions.k8s.io "httpapispecbindings.config.istio.io" deleted
customresourcedefinition.apiextensions.k8s.io "httpapispecs.config.istio.io" deleted
```

OK.


```sh
% helm install install/kubernetes/helm/istio \
--name istio \
--namespace istio-system \
--set prometheus.enabled=false
NAME:   istio
LAST DEPLOYED: Sat Nov  3 20:46:04 2018
NAMESPACE: istio-system
STATUS: DEPLOYED
...
```

これで無事通りました。
