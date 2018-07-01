+++
date = "2018-06-30T20:00:00+09:00"
title = "Create and Update prometheus configmap"
tags = ["gcp", "kubernates", "gke", "monitoring", "prometheus"]
categories = ["programming"]
+++

いままでgkeの監視に利用するprometheusやgrafanaをimage buildをしていた。
やっていることは設定ファイルの更新でしかないので、これをconfigmapに移行して管理を容易にします。

## configmap

[ConfigMap](https://cloud.google.com/kubernetes-engine/docs/concepts/configmap) とは

> onfigMaps bind configuration files, command-line arguments, environment variables, port numbers, and other configuration artifacts to your Pods' containers and system components at runtime. ConfigMaps allow you to separate your configurations from your Pods and components, which helps keep your workloads portable, makes their configurations easier to change and manage, and prevents hardcoding configuration data to Pod specifications.
> ConfigMaps are useful for storing and sharing non-sensitive, unencrypted configuration information.

podやcontainerなどのコンポーネントで利用できるconfig設定を別で永続化でき、設定情報とimageを分離できるようになります。

これはアプリケーションの可搬性を大きく向上させることに繋がります。例えば

1. productionやstagingなどstageの準備がmountするconfigmapを切り替えればできる
1. AWS -> GKEなどの移行も容易に行うことができる

さらに詳しくは [Configure a Pod to Use a ConfigMap](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/) を参照ください。

上手に利用することで、[The Tweleve-Factor App](https://12factor.net/) の実現にまた一歩寄与します。

## create configmap for monitoring

monitoringにはgrafanaとprometheusを用いている。それぞれの情報を以下のようなconfigmap名で保持します。

- prometheus-yml: prometheusの設定情報
- grafana-ini: grafanaの設定情報
- grafana-datasource: grafanaが接続するdatasoure設定

create configmap

```sh
# create
kubectl create configmap prometheus-yml --from-file ./prometheus/prometheus.yml
kubectl create configmap grafana-ini --from-file ./grafana/grafana.ini
kubectl create configmap grafana-datasource --from-file ./grafana/datasource.yaml

# list
kubectl get configmap
NAME                 DATA      AGE
grafana-datasource   1         21s
grafana-ini          1         23s
prometheus-yml       1         21m
```

podにmountします。

このとき気をつけなければいけないのがconfigmapをvolume mountするとdirctory として認識されてしまうので subpathを指定する必要があることでした。

> https://github.com/kubernetes/kubernetes/issues/44815#issuecomment-297077509
>
> well, when you do the second step, you remember that configmap is actually a list of key-value pairs, you only need one of the keys(though you actually have only one as well), so you need to tell the volume mounts to use a subpath from you configmap.

deployment: monitor.yaml

```diff
    spec:
      containers:
      ...
+      - image: prom/prometheus:latest
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
+        - mountPath: /etc/prometheus/prometheus.yml
+          subPath: prometheus.yml
+          name: prometheus-yml
        - mountPath: /prometheus
          name: prometheus-data
        securityContext:
          runAsUser: 0
+      - image: grafana/grafana:latest
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
+        - mountPath: /etc/grafana/grafana.ini
+          subPath: grafana.ini
+          name: grafana-ini
+        - mountPath: /etc/grafana/provisioning/datasources/datasource.yaml
+          subPath: datasource.yaml
+          name: grafana-datasource
        - mountPath: /var/lib/grafana
          name: grafana-data
        securityContext:
          runAsUser: 0
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
      ...
      volumes:
+      - name: prometheus-yml
+        configMap:
+          name: prometheus-yml
      - name: prometheus-data
        persistentVolumeClaim:
          claimName: prometheus-data
+      - name: grafana-ini
+        configMap:
+          name: grafana-ini
+      - name: grafana-datasource
+        configMap:
+          name: grafana-datasource
      - name: grafana-data
        persistentVolumeClaim:
          claimName: grafana-data
```

monitor.yaml を適用します。

```sh
kubectl apply -f ./kubernates/monitor.yaml
```

## Update configmap

configmapの変更はどのようにするのか？

> https://github.com/kubernetes/kubernetes/issues/30558
> Support updating config map and secret with --from-file #30558

とのissueがopenされているとおり、単純に `kubectl replace` commandを利用してfileから更新することができません。

この問題を解決するために以下のようにdry-runすることで得られた出力を利用してconfigmapを利用して更新します。

```sh
kubectl create configmap prometheus-yml --from-file=prometheus/prometheus.yml --dry-run -o yaml | kubectl replace configmap prometheus-yml -f -
kubectl create configmap grafana-ini --from-file=grafana/grafana.ini --dry-run -o yaml | kubectl replace configmap grafana-ini -f -
kubectl create configmap grafana-datasource --from-file=grafana/datasource.yaml --dry-run -o yaml | kubectl replace configmap grafana-datasource -f -
```

この方法を回避するためにはconfigmapを kubectlで取り込める形で管理しておくことが望ましいかもしれないが、localでの動作試験を考えると望ましくなさそうです。

minikubeを使ってこの手の管理をやったほうが実は都合が良いんでしょうかね？

## How to work pod when confimap updated?

configmapの変更はbindしているpodにどのように伝搬されるのかを調べます。

> [Mounted ConfigMaps are updated automatically](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/#add-configmap-data-to-a-volume)
>
> When a ConfigMap already being consumed in a volume is updated, projected keys are eventually updated as well. Kubelet is checking whether the mounted ConfigMap is fresh on every periodic sync. However, it is using its local ttl-based cache for getting the current value of the ConfigMap. As a result, the total delay from the moment when the ConfigMap is updated to the moment when new keys are projected to the pod can be as long as kubelet sync period + ttl of ConfigMaps cache in kubelet.
>
> Note: A container using a ConfigMap as a subPath volume will not receive ConfigMap updates.

とあるとおり、`subpath` を利用していない限り基本的にはconfigmapは自動で更新されるようです。
そのため、processを再起動するには以下の通り最大で80sec待つ必要があります。

kubeletではデフォルトが20sec

https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet/

> The monitoring period is 20s by default and is configurable via a flag.

また、configmapのttlは60sec

> https://github.com/kubernetes/kubernetes/blob/master/pkg/kubelet/configmap/configmap_manager.go#L108

```go
const (
    defaultTTL = time.Minute
    )
```

ちなみに、configmapの更新に合わせてpodのrolling updateが走ってほしいという件については、feature request issueが上がっているようです。

[Facilitate ConfigMap rollouts / management #22368](https://github.com/kubernetes/kubernetes/issues/22368)

## Update pod

今回はdowntimeが許容されるcontainerなのでscaleで対応します。

```
watch -n 1 'kubectl get pod'

# scale down
kubectl scale --replicas=0 deployment/monitor

# scale up
kubectl scale --replicas=1 deployment/monitor
```

donwtimeが許されないものであれば、image pullしてtagをつけかけ、setすることでrolling updateを発火させるのが良さそうです。

