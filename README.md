# Blog

[![CircleCI](https://circleci.com/gh/threetreeslight/blog/tree/master.svg?style=svg)](https://circleci.com/gh/threetreeslight/blog/tree/master)

## Getting started

```
# To work enable assets link via docker
export DOCKER_HOST_IP=$(echo $DOCKER_HOST | sed 's/tcp:\/\///g' | sed 's/:.*//g')

$ docker-compose build
$ docker-compose up blog
```

# GKE

## Environment

- GF_SECURITY_ADMIN_PASSWOR
- SLACK_WEBHOOK_URL

## monitor

create configmap

```sh
kubectl create configmap alertmanager-yml --from-file prometheus/alertmanager.yml
kubectl create configmap prometheus-yml --from-file prometheus/prometheus.yml
kubectl create configmap alert-rules-yml --from-file prometheus/alert.rules.yml
kubectl create configmap grafana-ini --from-file grafana/grafana.ini
kubectl create configmap grafana-datasource --from-file grafana/datasource.yaml
```

update configmap ( maximum latency is 80sec )

```
kubectl create configmap alertmanager-yml --from-file=prometheus/alertmanager.yml --dry-run -o yaml | kubectl replace configmap alertmanager-yml -f -
kubectl create configmap prometheus-yml --from-file=prometheus/prometheus.yml --dry-run -o yaml | kubectl replace configmap prometheus-yml -f -
kubectl create configmap alert-rules-yml --from-file=prometheus/alert.rules.yml --dry-run -o yaml | kubectl replace configmap alert-rules-yml -f -
kubectl create configmap grafana-ini --from-file=grafana/grafana.ini --dry-run -o yaml | kubectl replace configmap grafana-ini -f -
kubectl create configmap grafana-datasource --from-file=grafana/datasource.yaml --dry-run -o yaml | kubectl replace configmap grafana-datasource -f -
```

update monitor by manual

```
watch -n 1 'kubectl get pod'

# scale down
kubectl scale --replicas=0 deployment/monitor
# scale up
kubectl scale --replicas=1 deployment/monitor
```

connect

```
# prometheus
kubectl port-forward $(kubectl get pod --selector="app=monitor" -o jsonpath='{.items[0].metadata.name}') 9090:9090
# alertmanager
kubectl port-forward $(kubectl get pod --selector="app=monitor" -o jsonpath='{.items[0].metadata.name}') 9093:9093
```

logs

```
kubectl logs -f deployment/monitor blackbox-exporter
kubectl logs -f deployment/monitor alertmaanger
kubectl logs -f deployment/monitor prometheus
kubectl logs -f deployment/monitor grafana
```

## Utilities

send alert message

```
./scripts/send_alert.sh
```
