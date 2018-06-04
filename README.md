# Blog

[![CircleCI](https://circleci.com/gh/threetreeslight/blog/tree/master.svg?style=svg)](https://circleci.com/gh/threetreeslight/blog/tree/master)

## Getting started

```
# To work enable assets link via docker
export DOCKER_HOST_IP=$(echo $DOCKER_HOST | sed 's/tcp:\/\///g' | sed 's/:.*//g')

$ docker-compose build
$ docker-compose up blog
```

## monitoring

Build and push images

```
docker build -t threetreeslight/blog-prometheus:latest -f ./prometheus/Dockerfile .
docker push threetreeslight/blog-prometheus:latest

docker build -t threetreeslight/blog-grafana:latest -f ./grafana/Dockerfile .
docker push threetreeslight/blog-grafana:latest
```

connect prometheus

```
kubectl port-forward $(kubectl get pod --selector="app=monitor" -o jsonpath='{.items[0].metadata.name}') 9090:9090
```

logs

```
kubectl logs deployment/monitor prometheus
```
