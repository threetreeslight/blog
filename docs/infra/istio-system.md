# Istio

## Getting started

Requirement

- Already exists GKE cluster
- Install kubectl, helm and setup

Download Istio and prepare

- https://istio.io/docs/setup/kubernetes/download-release/

Install Istio to cluster with disable prometheus

```sh
helm install install/kubernetes/helm/istio \
--name istio \
--namespace istio-system \
--set certmanager.enabled=false \
--set grafana.enabled=false \
--set grallary.enabled=false \
--set kaili.enabled=false \
--set prometheus.enabled=false \
--set tracing.enabled=false \
--set servicegraph.enabled=false
```
