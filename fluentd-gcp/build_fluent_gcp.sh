#!/bin/sh

set -eo pipefail

timestamp=`date +%Y%m%d%H%M%S`

docker build -t threetreeslight/fluentd-gcp:$timestamp ./fluentd-gcp
docker tag threetreeslight/fluentd-gcp:$timestamp threetreeslight/fluentd-gcp:latest

echo "\nimage name is threetreeslight/fluentd-gcp:$timestamp\n"

docker push threetreeslight/fluentd-gcp:$timestamp
docker push threetreeslight/fluentd-gcp:latest

echo "\nUpdate fluentd-gcp image to threetreeslight/fluentd-gcp:$timestamp\n"

kubectl set image ds/fluentd-gcp-v2.0.9 --namespace=kube-system fluentd-gcp=threetreeslight/fluentd-gcp:$timestamp
kubectl rollout status ds/fluentd-gcp-v2.0.9 --namespace=kube-system
