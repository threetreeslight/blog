# App Infrastructure

## Getting Started

If you haven't create blog-monitoring-system, run follow

```sh
gcloud compute addresses create blog-gke --global
gcloud compute addresses list
```

Apply

- Should `--dry-run` and `--validate` option, before apply.

```sh
kubectl apply -f kubernetes/app/*
```

## Other Usage

Manually update blog container

```sh
docker build -t threetreeslight/blog:latest .
docker push threetreeslight/blog:latest
```

Show logs

```sh
# show all container log on app namespace
stern "" -n app --tail 1
# show all container logs
stern "" --all-namespaces tail 1
```
