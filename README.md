# Blog

[![CircleCI](https://circleci.com/gh/threetreeslight/blog/tree/master.svg?style=svg)](https://circleci.com/gh/threetreeslight/blog/tree/master)

## Getting started on local

```
# To work enable assets link via docker
export DOCKER_HOST_IP=$(echo $DOCKER_HOST | sed 's/tcp:\/\///g' | sed 's/:.*//g')

$ docker-compose build
$ docker-compose up blog
```

## local develoment utilities

send alert message

```
./scripts/send_alert.sh
```

# GKE

## preparation

attach cluster-admin role to me

```sh
kubectl create clusterrolebinding cluster-admin-binding \
--clusterrole cluster-admin \
--user $(gcloud config get-value account)
```

stop logging for custermize

- [GCP - Customizing Stackdriver Logs for Kubernetes Engine with Fluentd](https://cloud.google.com/solutions/customizing-stackdriver-logs-fluentd)

```sh
gcloud beta container clusters update --logging-service=none blog-cluster
```

## Environment

- GF_SECURITY_ADMIN_PASSWOR
- SLACK_WEBHOOK_URL

## monitor

update

```sh
./scripts/restart_monitor.sh
```

connect

```sh
# prometheus
kubectl port-forward $(kubectl get pod --selector="app=monitor" -o jsonpath='{.items[0].metadata.name}') 9090:9090
# alertmanager
kubectl port-forward $(kubectl get pod --selector="app=monitor" -o jsonpath='{.items[0].metadata.name}') 9093:9093
logs
```

```sh
kubectl logs -f deployment/monitor blackbox-exporter
kubectl logs -f deployment/monitor alertmaanger
kubectl logs -f deployment/monitor prometheus
kubectl logs -f deployment/monitor grafana
```
