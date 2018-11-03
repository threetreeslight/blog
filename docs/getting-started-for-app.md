# Getting Started for App

## App

Run hugo server

```sh
docker-compose up site
open http://localhost:1313
```

## Infrastructure

Requirement

- Already exists GKE cluster
- Install kubectl,helm and setup
- (options) Install kubectx, kubens

If you haven't create blog-monitoring-system, run follow

```sh
gcloud compute addresses create blog-gke --global
gcloud compute addresses list
```

Apply

- Should `--dry-run` and `--validate` option, before apply.

```
kubectl apply -f kubernetes/app/namespace.yaml
kubectl apply -f kubernetes/app/blog-deployment.yaml
kubectl apply -f kubernetes/app/ingress.yaml
```