# Blog

[![CircleCI](https://circleci.com/gh/threetreeslight/blog/tree/master.svg?style=svg)](https://circleci.com/gh/threetreeslight/blog/tree/master)

## TODO

- [ ] Use istio for blog
- [ ] Apply kubernates yamls automatically by `kubectl apply -f ./kubernates --prune` on circleci, when yaml has changed
- [ ] Apply kubernates secret automatically
- [ ] host statis site on busy box and share volume. nginx mount this. we'll use nginx conf by configmap
- [ ] Change arrangement strategy of blog pod to place each host. Because I want to reduce downtime when cluster upgrade.

## Archtecture Overview

![](/docs/architecture.png)

https://drive.google.com/file/d/1cD5BMx5KF-GnfHX4Rya_XkNtKMQQiY6c/view?usp=sharing

## Getting Started

Run hugo server

```sh
docker-compose up site
open http://localhost:1313
```

## ToC

- [Getting Started for Infra](docs/getting-started-for-infra.md)
  - [app](docs/infra/app.md)
  - [monitoring-system](docs/infra/monitoring-system.md)
  - [istio-system](docs/infra/istio-system.md)
- blog-cluster
  - [workload](https://console.cloud.google.com/kubernetes/workload?authuser=0&project=threetreeslight&workload_list_tablesize=50&workload_list_tablequery=%255B%257B_22k_22_3A_22is_system_22_2C_22t_22_3A10_2C_22v_22_3A_22_5C_22false_5C_22_22_2C_22s_22_3Atrue%257D_2C%257B_22k_22_3A_22metadata%252FclusterReference%252Fname_22_2C_22t_22_3A10_2C_22v_22_3A_22_5C_22blog-cluster_5C_22_22_2C_22s_22_3Atrue%257D%255D)
  - [service](https://console.cloud.google.com/kubernetes/discovery?authuser=0&project=threetreeslight&service_list_tablesize=50&service_list_tablequery=%255B%257B_22k_22_3A_22is_system_22_2C_22t_22_3A10_2C_22v_22_3A_22_5C_22false_5C_22_22_2C_22s_22_3Atrue%257D_2C%257B_22k_22_3A_22metadata%252FclusterReference%252Fname_22_2C_22t_22_3A10_2C_22v_22_3A_22_5C_22blog-cluster_5C_22_22%257D%255D)

## Other usage

```console
$ gcloud auth list
$ kubectl config current-context
```
