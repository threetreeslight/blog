+++
date = "2018-08-T14:00:00+09:00"
title = "How to funout stackdriver logs to bigquery and gcs"
tags = ["stackdriver", "gcp", "gcs", "bigquery"]
categories = ["programming"]
draft = "true"
+++


## stackdriverからのfunout希望

```text
         ...
          |
       fluentd (<-ここらへん1) --- papertrail
          |
      stackdriver
          | (<- ここらへん2)
      ----------
      |        |
    bigquery  gcs
```

いい感じのdocsがある。さすがgoogle 😇

[Design Patterns for Exporting Stackdriver Logging](https://cloud.google.com/solutions/design-patterns-for-exporting-stackdriver-logging)

その前にnode logging agent がぶっ壊れたので、整理をする

```sh
gcloud compute --project "threetreeslight" ssh --zone "us-west1-a" "gke-blog-cluster-pool-1-767a6361-7t2r"
sudo su
```

```
% ls -l /var/lib/docker/containers
drwx------  3 root root 4096 Aug  7 13:55 071b3c094a4332044997fb425aa95348d324ff6fc5f02d3311cd9a88ce999216
drwx------  3 root root 4096 Aug  6 15:28 09af55d72e42330f1903cab2fb42f274bc2c5ee24149d72e69356e1faca64879
drwx------  3 root root 4096 Jul 14 10:12 0aa68a6f97640043365d080b64c557379271f5ef1730763537772e3ecd695659
drwx------  3 root root 4096 Aug  7 08:34 17834a541c748564ebb79772cafd8a6858f095fb46334778550d84e33ab51627
drwx------  3 root root 4096 Aug 11 03:42 2cd439bb6d232379490dcb48f7a39e7c292bc6aba26a6249faf6d9a122697234
drwx------  4 root root 4096 Jun  2 07:23 40730ac5da23aa22dcfc2baac15efd31dc82445c168d9230506930e5575e840d
drwx------  3 root root 4096 Jun  2 07:57 556d1b7d52f70e4e0f17e4a0021a493048cb34aae1b52036799ca31f2def4b3a

% ls -l /var/lib/docker/containers/2cd439bb6d232379490dcb48f7a39e7c292bc6aba26a6249faf6d9a122697234
-rw-r----- 1 root root  505 Aug 11 03:42 2cd439bb6d232379490dcb48f7a39e7c292bc6aba26a6249faf6d9a122697234-json.log
drwx------ 2 root root 4096 Aug 11 03:42 checkpoints
-rw-r--r-- 1 root root 6914 Aug 11 03:42 config.v2.json
-rw-r--r-- 1 root root 1740 Aug 11 03:42 hostconfig.json

% tail 2cd439bb6d232379490dcb48f7a39e7c292bc6aba26a6249faf6d9a122697234-json.log
{"log":"I0811 03:42:05.658378       1 main.go:83] GCE config: \u0026{Project:threetreeslight Zone:us-west1-a Cluster:blog-cluster Instance:gke-blog-cluster-pool-1-767a6361-7t2r.c.threetreeslight.internal MetricsPrefix:container.googleapis.com/internal/addons}\n","stream":"stderr","time":"2018-08-11T03:42:05.658698744Z"}
{"log":"I0811 03:42:05.658464       1 main.go:115] Running prometheus-to-sd, monitored target is fluentd localhost:31337\n","stream":"stderr","time":"2018-08-11T03:42:05.658801097Z"}
```

# The Kubernetes kubelet makes a symbolic link to this file on the host machine
# in the /var/log/containers directory which includes the pod name and the Kubernetes

`/var/log/containers` に各container logがflatに配置されています。

中にあるのはsybolic linkである。


```
% ls -l /var/log/containers
lrwxrwxrwx 1 root root 61 Aug  5 13:23 blog-84bd9f6d5b-9f6kt_default_blog-e3e2ad507585302aa3d77cc3670ffd3b86263bbff896ec489ddb42eb1c7f214e.log -> /var/log/pods/b5765594-98b2-11e8-8483-42010a8a0017/blog_0.log
lrwxrwxrwx 1 root root 69 Aug 11 05:33 fluentd-gcp-v2.0.9-5kd4h_kube-system_fluentd-gcp-6330ce359fb5c54012b85c1d6d57eb076578b15fbca1150f341e16f5f61f0655.log -> /var/log/pods/82a88873-9d18-11e8-b3c9-42010a8a0140/fluentd-gcp_11.log
lrwxrwxrwx 1 root root 69 Aug 11 05:21 fluentd-gcp-v2.0.9-5kd4h_kube-system_fluentd-gcp-8b951e9978fae5781b55007de8f24a5b336dab9d6812855ffaa5e3f460340a07.log -> /var/log/pods/82a88873-9d18-11e8-b3c9-42010a8a0140/fluentd-gcp_10.log
lrwxrwxrwx 1 root root 82 Aug 11 03:42 fluentd-gcp-v2.0.9-5kd4h_kube-system_prometheus-to-sd-exporter-2cd439bb6d232379490dcb48f7a39e7c292bc6aba26a6249faf6d9a122697234.log -> /var/log/pods/82a88873-9d18-11e8-b3c9-42010a8a0140/prometheus-to-sd-exporter_0.log
```

`/var/log/pods` にpod単位のlogが配置されている。

実態は `/var/lib/docker/containers/` の情報

```
# ls -la /var/log/pods/82a88873-9d18-11e8-b3c9-42010a8a0140
lrwxrwxrwx  1 root root  165 Aug 11 05:21 fluentd-gcp_10.log -> /var/lib/docker/containers/8b951e9978fae5781b55007de8f24a5b336dab9d6812855ffaa5e3f460340a07/8b951e9978fae5781b55007de8f24a5b336dab9d6812855ffaa5e3f460340a07-json.log
lrwxrwxrwx  1 root root  165 Aug 11 05:33 fluentd-gcp_11.log -> /var/lib/docker/containers/6330ce359fb5c54012b85c1d6d57eb076578b15fbca1150f341e16f5f61f0655/6330ce359fb5c54012b85c1d6d57eb076578b15fbca1150f341e16f5f61f0655-json.log
lrwxrwxrwx  1 root root  165 Aug 11 03:42 prometheus-to-sd-exporter_0.log -> /var/lib/docker/containers/2cd439bb6d232379490dcb48f7a39e7c292bc6aba26a6249faf6d9a122697234/2cd439bb6d232379490dcb48f7a39e7c292bc6aba26a6249faf6d9a122697234-json.log
```

つまり、 kubernatesがrenameした container log の filename を parseすればなんのlogであるかわかる。

```
% ls -l /var/lib/docker/containers
drwx------  3 root root 4096 Aug  7 13:55 071b3c094a4332044997fb425aa95348d324ff6fc5f02d3311cd9a88ce999216
drwx------  3 root root 4096 Aug  6 15:28 09af55d72e42330f1903cab2fb42f274bc2c5ee24149d72e69356e1faca64879
drwx------  3 root root 4096 Jul 14 10:12 0aa68a6f97640043365d080b64c557379271f5ef1730763537772e3ecd695659
drwx------  3 root root 4096 Aug  7 08:34 17834a541c748564ebb79772cafd8a6858f095fb46334778550d84e33ab51627
drwx------  3 root root 4096 Aug 11 03:42 2cd439bb6d232379490dcb48f7a39e7c292bc6aba26a6249faf6d9a122697234
drwx------  4 root root 4096 Jun  2 07:23 40730ac5da23aa22dcfc2baac15efd31dc82445c168d9230506930e5575e840d
drwx------  3 root root 4096 Jun  2 07:57 556d1b7d52f70e4e0f17e4a0021a493048cb34aae1b52036799ca31f2def4b3a

% ls -l /var/lib/docker/containers/2cd439bb6d232379490dcb48f7a39e7c292bc6aba26a6249faf6d9a122697234
-rw-r----- 1 root root  505 Aug 11 03:42 2cd439bb6d232379490dcb48f7a39e7c292bc6aba26a6249faf6d9a122697234-json.log
drwx------ 2 root root 4096 Aug 11 03:42 checkpoints
-rw-r--r-- 1 root root 6914 Aug 11 03:42 config.v2.json
-rw-r--r-- 1 root root 1740 Aug 11 03:42 hostconfig.json

% tail 2cd439bb6d232379490dcb48f7a39e7c292bc6aba26a6249faf6d9a122697234-json.log
{"log":"I0811 03:42:05.658378       1 main.go:83] GCE config: \u0026{Project:threetreeslight Zone:us-west1-a Cluster:blog-cluster Instance:gke-blog-cluster-pool-1-767a6361-7t2r.c.threetreeslight.internal MetricsPrefix:container.googleapis.com/internal/addons}\n","stream":"stderr","time":"2018-08-11T03:42:05.658698744Z"}
{"log":"I0811 03:42:05.658464       1 main.go:115] Running prometheus-to-sd, monitored target is fluentd localhost:31337\n","stream":"stderr","time":"2018-08-11T03:42:05.658801097Z"}
```

# The /var/log directory on the host is mapped to the /var/log directory in the container
# running this instance of Fluentd and we end up collecting the file:

```k
var.log.containers.synthetic-logger-0.25lps-pod_default-synth-lgr-997599971ee6366d4a5920d25b79286ad45ff37a74494f262e3bc98d909d0a7b.log
```

```
<source>
  @type tail
  format json
  time_key time
  path /var/log/containers/*.log
  pos_file /var/log/gcp-containers.log.pos
  time_format %Y-%m-%dT%H:%M:%S.%N%Z
  tag reform.*
  read_from_head true
</source>

<filter reform.**>
  @type parser
  format /^(?<severity>\w)(?<time>\d{4} [^\s]*)\s+(?<pid>\d+)\s+(?<source>[^ \]]+)\] (?<log>.*)/
  reserve_data true
  suppress_parse_error_log true
  key_name log
</filter>
```

## ref

- [kubernates - Logging Architecture](https://kubernetes.io/docs/concepts/cluster-administration/logging/)
- [docker - logdriver](https://docs.docker.com/config/containers/logging/configure/#configure-the-logging-driver-for-a-container)
- [gcp - export](https://cloud.google.com/logging/docs/export/)
- [github - GoogleCloudPlatform/k8s-stackdriver](https://github.com/GoogleCloudPlatform/k8s-stackdriver)
- [GCP - Customizing Stackdriver Logs for Kubernetes Engine with Fluentd](https://cloud.google.com/solutions/customizing-stackdriver-logs-fluentd)
- [kubernates - Logging Using Stackdriver](https://kubernetes.io/docs/tasks/debug-application-cluster/logging-stackdriver/)
