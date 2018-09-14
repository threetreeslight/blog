+++
date = "2018-00-00T17:00:00+09:00"
title = "What is kubernates PVC"
tags = ["gcp", "kubernates", "prometheus", "monitoring"]
categories = ["programming"]
draft = "true"
+++

kubernates monitoring with prometheus and grafana

# GEK上に展開

以下のようなmonitoring用のdeploymentを作る

```yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  labels:
    app: monitoring
  name: monitoring
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: monitoring
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: monitoring
    spec:
      containers:
      - image: prom/prometheus
        imagePullPolicy: Always
        name: prometheus
        ports:
        - containerPort: 9090
          protocol: TCP
        resources: {}
        volumeMounts:
        - mountPath: /prometheus
          name: prometheus-data
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
      - image: threetreeslight/blog-grafana
        imagePullPolicy: Always
        name: grafana
        ports:
        - containerPort: 3000
          protocol: TCP
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      terminationGracePeriodSeconds: 30
      volumes:
      - name: "prometheus-data"
        persistentVolumeClaim:
          claimName: prometheus-data
```

pod間の通信はカジュアルにできるのでdatasource.yamlは楽

grafana: datasource.yaml

```yaml
apiVersion: 1
datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
```

prometheus + grafanaが立ち上がり、grafanaがdatasourceとして利用できていることがわかる。

kubernates


# のこり

- 既存ingressでroutingしてgrafana, prometheusに通信が届かない。悲しい。serviceは公開しているのに、、、
  - ここに3時間かけてしまったのが誤算
- gke上でadviser, node exporterの通信してmetric収集
- prometheusのvolumeデータの永続化のプラクティスを考えること

そして

- prometheusのrepoにkubernetesどんな方針でやるのが良いのか書いてあった :sob:
  - https://github.com/prometheus/prometheus/blob/master/documentation/examples/prometheus-kubernetes.yml


https://kubernetes.io/docs/tutorials/stateful-application/mysql-wordpress-persistent-volume/

```sh
kubectl create secret generic mysql-pass --from-literal=password=YOUR_PASSWORD
kubectl get secrets
```

https://console.cloud.google.com/net-services/loadbalancing/details/http/k8s-um-default-blog--4d11d049f1b33652?project=threetreeslight&authuser=1
https://console.cloud.google.com/kubernetes/list?project=threetreeslight&authuser=1

https://cloud.google.com/kubernetes-engine/docs/tutorials/http-balancer?authuser=1

https://kubernetes.io/docs/concepts/services-networking/connect-applications-service/
https://github.com/prometheus/prometheus/blob/master/documentation/examples/prometheus-kubernetes.yml

https://kubernetes.io/docs/concepts/cluster-administration/logging/
https://kubernetes.io/docs/tutorials/stateful-application/mysql-wordpress-persistent-volume/





sample kubernates
https://github.com/bakins/minikube-prometheus-demo/blob/master/prometheus-deployment.yaml
https://github.com/xiaoping378/k8s-monitor/tree/master/manifests


```
level=error ts=2018-06-09T10:14:07.288615826Z caller=main.go:218 component=k8s_client_runtime err="github.com/prometheus/prometheus/discovery/kubernetes/kubernetes.go:353: Failed to list *v1.Node: nodes is forbidden: User \"system:serviceaccount:default:default\" cannot list nodes at the cluster scope: Unknown user \"system:serviceaccount:default:default\""

level=error ts=2018-06-09T10:14:07.291011002Z caller=main.go:218 component=k8s_client_runtime err="github.com/prometheus/prometheus/discovery/kubernetes/kubernetes.go:284: Failed to list *v1.Endpoints: endpoints is forbidden: User \"system:serviceaccount:default:default\" cannot list endpoints at the cluster scope: Unknown user \"system:serviceaccount:default:default\""
level=error ts=2018-06-09T10:14:07.291097332Z caller=main.go:218 component=k8s_client_runtime err="github.com/prometheus/prometheus/discovery/kubernetes/kubernetes.go:353: Failed to list *v1.Node: nodes is forbidden: User \"system:serviceaccount:default:default\" cannot list nodes at the cluster scope: Unknown user \"system:serviceaccount:default:default\""
level=error ts=2018-06-09T10:14:07.291207913Z caller=main.go:218 component=k8s_client_runtime err="github.com/prometheus/prometheus/discovery/kubernetes/kubernetes.go:286: Failed to list *v1.Pod: pods is forbidden: User \"system:serviceaccount:default:default\" cannot list pods at the cluster scope: Unknown user \"system:serviceaccount:default:default\""
level=error ts=2018-06-09T10:14:07.291333238Z caller=main.go:218 component=k8s_client_runtime err="github.com/prometheus/prometheus/discovery/kubernetes/kubernetes.go:285: Failed to list *v1.Service: services is forbidden: User \"system:serviceaccount:default:default\" cannot list services at the cluster scope: Unknown user \"system:serviceaccount:default:default\""
level=error ts=2018-06-09T10:14:07.291901776Z caller=main.go:218 component=k8s_client_runtime err="github.com/prometheus/prometheus/discovery/kubernetes/kubernetes.go:284: Failed to list *v1.Endpoints: endpoints is forbidden: User \"system:serviceaccount:default:default\" cannot list endpoints at the cluster scope: Unknown user \"system:serviceaccount:default:default\""
level=error ts=2018-06-09T10:14:07.333213983Z caller=main.go:218 component=k8s_client_runtime err="github.com/prometheus/prometheus/discovery/kubernetes/kubernetes.go:303: Failed to list *v1.Pod: pods is forbidden: User \"system:serviceaccount:default:default\" cannot list pods at the cluster scope: Unknown user \"system:serviceaccount:default:default\""
level=error ts=2018-06-09T10:14:07.333350048Z caller=main.go:218 component=k8s_client_runtime err="github.com/prometheus/prometheus/discovery/kubernetes/kubernetes.go:285: Failed to list *v1.Service: services is forbidden: User \"system:serviceaccount:default:default\" cannot list services at the cluster scope: Unknown user \"system:serviceaccount:default:default\""
level=error ts=2018-06-09T10:14:07.333421831Z caller=main.go:218 component=k8s_client_runtime err="github.com/prometheus/prometheus/discovery/kubernetes/kubernetes.go:286: Failed to list *v1.Pod: pods is forbidden: User \"system:serviceaccount:default:default\" cannot list pods at the cluster scope: Unknown user \"system:serviceaccount:default:default\""
```

https://github.com/prometheus/prometheus/issues/2763


```
% kubectl get serviceaccounts
NAME      SECRETS   AGE
default   1         21d
```

https://cloud.google.com/kubernetes-engine/docs/how-to/role-based-access-control
役割ベースのアクセス制御
https://kubernetes.io/docs/reference/access-authn-authz/rbac/

kubectl create clusterrolebinding cluster-admin-binding \
  --clusterrole cluster-admin \
  --user $(gcloud config get-value account)

自分に権限つける


# Create Volume

https://cloud.google.com/kubernetes-engine/docs/tutorials/persistent-disk

```
gcloud compute disks create --size 10GB prometheus-disk
gcloud compute disks create --size 10GB grafana-disk

% gcloud compute disks list
NAME                                                             ZONE        SIZE_GB  TYPE         STATUS
grafana-disk                                                     us-west1-a  10       pd-standard  READY
prometheus-disk                                                  us-west1-a  10       pd-standard  READY
```

200GBのストレージをつけないとIOでないよってことらしい


```
WARNING: You have selected a disk size of under [200GB]. This may result in poor I/O performance. For more information, see: https://developers.google.com/compute/docs/disks#performance.
```


ほほぉ

https://cloud.google.com/kubernetes-engine/docs/concepts/persistent-volumes
