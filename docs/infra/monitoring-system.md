# Monitoring System

## Getting Started

Requirement

- Already exists GKE cluster
- Install kubectl, helm and setup
- (options) Install kubectx, kubens, stern

If you haven't create blog-monitoring-system, run follow

```sh
gcloud compute addresses create blog-monitoring-system --global
gcloud compute addresses list
```

If you haven't create crepto key

```sh
# create blog keyring
gcloud kms keyrings create blog --location global
# create monitor key
gcloud kms keys create monitor --location global --keyring blog --purpose encryption
# show list
gcloud kms keys list --location global --keyring blog
```

Create or Update monitoring-system resouces

```sh
# Update config & restart deployment
./bin/monitor apply_config
# Apply kubernetes spec
./bin/monitor apply_spec
# Restart pod
./bin/monitor restart
# Stop pod
./bin/monitor stop
# start pod
./bin/monitor start
```

## Usage

Deploy secret

```sh
# encrypt
kubesec encrypt -i --key projects/threetreeslight/locations/global/keyRings/blog/cryptoKeys/monitor ./kubernetes/monitoring-system/secret.yaml

# edit encripted file
kubesec edit -if ./kubernetes/monitoring-system/secret.yaml

# decrypt and apply
kubesec decrypt ./kubernetes/monitoring-system/secret.yaml | kubectl apply -f -
```

Lookup console

```sh
# prometheus
kubectl port-forward $(kubectl get pod --selector="app=monitor" --namespace monitoring-system -o jsonpath='{.items[0].metadata.name}') 9090:9090
open http://localhost:9090

# alertmanager
kubectl port-forward $(kubectl get pod --selector="app=monitor" --namespace monitoring-system -o jsonpath='{.items[0].metadata.name}') 9093:9093
logs
open localhost:9093
```

Exec command in container

```
# in grafana
kubectl exec -it $(kubectl get pod --selector="app=monitor" --namespace monitoring-system -o jsonpath='{.items[0].metadata.name}') --container grafana -- /bin/sh
```

Show logs

```sh
# Use starn
stern "*" -n monitoring-system --tail 1

# Use kubectl logs
kubectl logs -f deployment/monitor blackbox-exporter --monitoring-system
kubectl logs -f deployment/monitor alertmaanger
kubectl logs -f deployment/monitor prometheus
kubectl logs -f deployment/monitor grafana
```

## local develoment utilities

send alert message

```
./scripts/send_alert.sh
```


