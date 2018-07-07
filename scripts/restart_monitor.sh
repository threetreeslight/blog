#!/bin/sh

kubectl create configmap alertmanager-yml --from-file=prometheus/alertmanager.yml --dry-run -o yaml | kubectl replace configmap alertmanager-yml -f -
kubectl create configmap prometheus-yml --from-file=prometheus/prometheus.yml --dry-run -o yaml | kubectl replace configmap prometheus-yml -f -
kubectl create configmap alert-rules-yml --from-file=prometheus/alert.rules.yml --dry-run -o yaml | kubectl replace configmap alert-rules-yml -f -
kubectl create configmap grafana-ini --from-file=grafana/grafana.ini --dry-run -o yaml | kubectl replace configmap grafana-ini -f -
kubectl create configmap grafana-datasource --from-file=grafana/datasource.yaml --dry-run -o yaml | kubectl replace configmap grafana-datasource -f -

kubectl scale --replicas=0 deployment/monitor

while [ $(kubectl get pods | grep monitor | wc -l) = 1 ]; do
  kubectl get pods
  sleep 1
done

kubectl scale --replicas=1 deployment/monitor
sleep 10

while [ $(kubectl get pods | grep monitor | grep Running | wc -l) = 1 ]; do
  kubectl get pods
  sleep 1
done

echo "restarted"

exit 0
