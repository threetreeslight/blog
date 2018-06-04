+++
date = "2018-06-17T19:00:00+09:00"
title = "Monitor blog on kubernates by Prometheus and grafana"
tags = ["gcp", "kubernates", "prometheus", "monitoring", "grafana"]
categories = ["programming"]
+++

kubernates上でblogを運用していることから、kubernatesや各contaienr, nodeのmetricをkubernates上で動かしたprometheusで収集し、grafanaで描写するようにしました。

## Overview

以下のような方針で構成する

```
ingress <-> monitor service <-> monitor deployments - grafana -> prometheus
```

- GKEを利用している
- node, containerのmetricを収集する
- grafanaはpublic urlからアクセスできる
- prometheusはアクセス制御ができないので、port forwardingでアクセスする
- grafana, prometheusのデータは永続化しておく
- monitorというdeploymentを用意し、grafana, prometheusを同居させる
- monitor podsはdowntimeを許容する

## Prometheus

kubernatesから各contaienrおよびnodeのmetricをkubernates apiserverを通して取得する。

以下のprometheusにrepoに同梱されているexpampleを参考にすることでイメージが付くと思います

https://github.com/prometheus/prometheus/blob/master/documentation/examples/prometheus-kubernetes.yml

nodeのmetric収集

```yaml
# Scrape config for nodes (kubelet).
- job_name: 'kubernetes-nodes'
  kubernetes_sd_configs:
  - role: node

  scheme: https
  tls_config:
    ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
  bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token

  relabel_configs:
  - action: labelmap
    regex: __meta_kubernetes_node_label_(.+)
  - target_label: __address__
    replacement: kubernetes.default.svc:443
  - source_labels: [__meta_kubernetes_node_name]
    regex: (.+)
    target_label: __metrics_path__
    replacement: /api/v1/nodes/${1}/proxy/metrics
```

container metrics

```yaml
# Scrape config for Kubelet cAdvisor.
- job_name: 'kubernetes-cadvisor'
  kubernetes_sd_configs:
  - role: node

  scheme: https
  tls_config:
    ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
  bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token

  relabel_configs:
  - action: labelmap
    regex: __meta_kubernetes_node_label_(.+)
  - target_label: __address__
    replacement: kubernetes.default.svc:443
  - source_labels: [__meta_kubernetes_node_name]
    regex: (.+)
    target_label: __metrics_path__
    replacement: /api/v1/nodes/${1}/proxy/metrics/cadvisor
```

node, container以外にも、pod, service, endpoint, ingress, kubernates api-serverの状態を監視することも可能です。

今回は、pod, endpoint, apiserverのmetricを収集します。

```yaml
# Scrape config for API servers.
- job_name: 'kubernetes-apiservers'
  kubernetes_sd_configs:
    - role: endpoints

  scheme: https
  tls_config:
    ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
  bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token

  relabel_configs:
  - source_labels: [__meta_kubernetes_namespace, __meta_kubernetes_service_name, __meta_kubernetes_endpoint_port_name]
    action: keep
    regex: default;kubernetes;https

# scrape config for service endpoints.
- job_name: 'kubernetes-service-endpoints'
  kubernetes_sd_configs:
  - role: endpoints

  relabel_configs:
  - action: labelmap
    regex: __meta_kubernetes_service_label_(.+)
  - source_labels: [__meta_kubernetes_namespace]
    action: replace
    target_label: kubernetes_namespace
  - source_labels: [__meta_kubernetes_service_name]
    action: replace
    target_label: kubernetes_name


# scrape config for pods
- job_name: 'kubernetes-pods'
  kubernetes_sd_configs:
  - role: pod

  relabel_configs:
  - action: labelmap
    regex: __meta_kubernetes_pod_label_(.+)
  - source_labels: [__meta_kubernetes_namespace]
    action: replace
    target_label: kubernetes_namespace
  - source_labels: [__meta_kubernetes_pod_name]
    action: replace
    target_label: kubernetes_pod_name
```

これでkubernatesからmetricを収集する準備が整いました。

## rbec

GKEでは 以下のようにRBACの権限(cluster-admin clusterrole )を自身のアカウントに付与する必要があります。

[google cloud - Role-Based Access Control](https://cloud.google.com/kubernetes-engine/docs/how-to/role-based-access-control) 

```sh
kubectl create clusterrolebinding cluster-admin-binding \
--clusterrole cluster-admin \
--user $(gcloud config get-value account)
```

続いて、metricを収集するための権限を持つuserを作成します。

```yaml
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  name: monitor
rules:
- apiGroups: [""]
  resources:
  - nodes
  - nodes/proxy
  - services
  - endpoints
  - pods
  verbs: ["get", "list", "watch"]
- apiGroups:
  - extensions
  resources:
  - ingresses
  verbs: ["get", "list", "watch"]
- nonResourceURLs: ["/metrics"]
  verbs: ["get"]
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: monitor
  namespace: default
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: monitor
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: monitor
subjects:
- kind: ServiceAccount
  name: monitor
  namespace: default
```

## Grafana

grafanaはdatasourceとしてprometheusを利用する設定を入れたimageを作成します。

```yaml
# database.yaml
apiVersion: 1
datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
```

grafanaへのアクセスのために毎回port forwardingするのは面倒なので、外部公開する。

そのため、admin_userのpasswordを設定するために以下の通り扁壷しておく。

```sh
kubectl create secret generic gf-security-admin-password --from-literal=password=YOUR_PASSWORD
```

## Volume

grafana, prometheusの設定情報やmetricデータは永続化する必要があるので、以下の通りpersistentVoluemClaimを利用する。


```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: prometheus-data
  labels:
    app: monitor
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: grafana-data
  labels:
    app: monitor
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 3Gi

```

volumeの扱いについては以下を参考にすると良いです。

- [kubernates - mysql-wordpress-persistent-volume](https://kubernetes.io/docs/tutorials/stateful-application/mysql-wordpress-persistent-volume/)

## Deployments

以下のようにmonitorというdeploymentを作成し、grafanaとprometheusを同居させる。

deployemnt全体は以下のとおりです。

```yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  labels:
    app: monitor
  name: monitor
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: monitor
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: monitor
    spec:
      serviceAccountName: monitor
      containers:
      - image: threetreeslight/blog-prometheus:latest
        imagePullPolicy: Always
        name: prometheus
        readinessProbe:
          httpGet:
            path: /graph
            port: 9090
          periodSeconds: 10
          initialDelaySeconds: 0
          failureThreshold: 10
          successThreshold: 1
        ports:
        - containerPort: 9090
          protocol: TCP
        resources: {}
        volumeMounts:
        - mountPath: /prometheus
          name: prometheus-data
        securityContext:
          runAsUser: 0
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
      - image: threetreeslight/blog-grafana
        imagePullPolicy: Always
        name: grafana
        readinessProbe:
          httpGet:
            path: /login
            port: 3000
          periodSeconds: 10
          initialDelaySeconds: 0
          failureThreshold: 10
          successThreshold: 1
        env:
        - name: GF_SECURITY_ADMIN_PASSWORD
          valueFrom:
            secretKeyRef:
              name: gf-security-admin-password
              key: password
        ports:
        - containerPort: 3000
          protocol: TCP
        resources: {}
        volumeMounts:
        - mountPath: /var/lib/grafana
          name: grafana-data
        securityContext:
          runAsUser: 0
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      terminationGracePeriodSeconds: 30
      volumes:
      - name: prometheus-data
        persistentVolumeClaim:
          claimName: prometheus-data
      - name: grafana-data
        persistentVolumeClaim:
          claimName: grafana-data
```

いくつかポイントがあるので記述していきます。

### service account

kubenrnatesのapiへアクセスできるようservice accountを明示的にしています


```diff
spec:
  template:
    spec:
+      serviceAccountName: monitor
```

### deploymentの更新strategy

作成したPVCは `ReadWriteOnce` であるため、downtimeを許容する必要があります。
そのため、updateのstrategyは `Recreate` とします。

```diff
spec:
  template:
+  strategy:
+    type: Recreate
```

### readinessProbe

外部公開するserviceからのhealth checkは `readinessProbe` を引き継ぎます。

`/` へのアクセスでhealth checkが確認できないような場合(redirectされるような処理がある場合) は以下のようにdeploymentで `readinessProbe` を明示的に指定します。

```diff
spec:
  template:
    spec:
      containers:
      - image: threetreeslight/blog-prometheus:latest
+        readinessProbe:
+          httpGet:
+            path: /graph
+            port: 9090
+          periodSeconds: 10
+          initialDelaySeconds: 0
+          failureThreshold: 10
+          successThreshold: 1
      - image: threetreeslight/blog-grafana
+        readinessProbe:
+          httpGet:
+            path: /login
+            port: 3000
+          periodSeconds: 10
+          initialDelaySeconds: 0
+          failureThreshold: 10
+          successThreshold: 1
```

### grafana password

grafanaのadmin login passwordは、先程設定したsecretを利用し、環境変数に設定します。

```diff
spec:
  template:
    spec:
      containers:
      - image: threetreeslight/blog-grafana
+        env:
+        - name: GF_SECURITY_ADMIN_PASSWORD
+          valueFrom:
+            secretKeyRef:
+              name: gf-security-admin-password
+              key: password
```

containerに入るとpasswordが分かるというのはあまり望ましく無い気もしていますが、そこまでやることでもないかな？と考えこんな漢字に。

### volumeをmount

作成したpvcをmountします

```diff
spec:
  template:
    spec:
      containers:
      - image: threetreeslight/blog-prometheus:latest
+        volumeMounts:
+        - mountPath: /prometheus
+          name: prometheus-data
      - image: threetreeslight/blog-grafana
+        volumeMounts:
+        - mountPath: /var/lib/grafana
+          name: grafana-data

+      volumes:
+      - name: prometheus-data
+        persistentVolumeClaim:
+          claimName: prometheus-data
+      - name: grafana-data
+        persistentVolumeClaim:
+          claimName: grafana-data
```

また、PVC volumeへアクセスするために以下の通り `seucrityContext` を付与します

```diff
spec:
  template:
    spec:
      containers:
      - image: threetreeslight/blog-prometheus:latest
+        securityContext:
+          runAsUser: 0
      - image: threetreeslight/blog-grafana
        ...
+        securityContext:
+          runAsUser: 0
```

## Service

アクセスできるようserviceを準備します。

serviceからのhealth check は readinessProbe が継承されることに気をつけてください。

```yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app: monitor
  name: monitor
  namespace: default
spec:
  ports:
  - port: 9090
    protocol: TCP
    name: prometheus
    targetPort: 9090
  - port: 3000
    protocol: TCP
    name: grafana
    targetPort: 3000
  selector:
    app: monitor
  type: NodePort
```

## Ingress

以下の通りgrafanaへのアクセスできるようroutingを追加します。

```diff
apiVersion: extensions/v1beta1
kind: Ingress
spec:
  rules:
+  - host: <your_host_name>
+    http:
+      paths:
+      - backend:
+          serviceName: monitor
+          servicePort: 3000
```

これで外部からアクセスできるようになる！便利！

以上で、prometheusでデータ収集ができ、grafanaでそのmetricを参照できるようになりました。
