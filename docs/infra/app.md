# Getting Started for App

## App

Run hugo server

```sh
docker-compose up site
open http://localhost:1313
```

## Infrastructure

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
stern "*" -n app --tail 1
```
