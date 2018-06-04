+++
date = "2018-06-16T11:00:00+09:00"
title = "What is RBAC on Kubernates"
tags = ["gcp", "kubernates", "rbac"]
categories = ["programming"]
+++

blogをオーバーキルするyaml職人です。そしてkubernates入門はまじで入門すぎて全然役に立たない日々です。

今日はkubernatesのRBACとGCP IAMを正しく理解していない結果、これどっちの権限の問題やねん？と詰まることが多かったので、そこらへんの理解を軽く深めます。

GCPはquota limitでだめだったり権限だめだったり辛い。機能はめっちゃイケてるんだけど、慣れていないのが辛い。

# kubernatesにおける認可とは?

Kubernatesの [Authorization Overview](https://kubernetes.io/docs/reference/access-authn-authz/authorization/) を見てみる

> Kubernetes authorizes API requests using the API server. It evaluates all of the request attributes against all policies and allows or denies the request. All parts of an API request must be allowed by some policy in order to proceed. 
> This means that permissions are denied by default.

すべての操作はkubernates API server を通して行われ、基本的には拒否るよ。

[Review Your Request Attributes](https://kubernetes.io/docs/reference/access-authn-authz/authorization/) を見ると、ざっとこれだけのきめ細やかな制御がきる。

- user
- group
- extra
- API
- Request path
- API request verb
- HTTP request verb
- Resource
- Subresource
- Namespace
- API group

人類には早く感じる。IAM人類に早い説。

また、APIへの要求は HTTP verbsを使うのでそこはわかりやすいとおもったら

> Kubernetes sometimes checks authorization for additional permissions using specialized verbs. For example:

`use`, `bind`, `impersonate` のような特別なverbsがあると、なるほど。

# 認可をするためのmoduleは何があるのか？

kubernatesが操作に関わる認可設定は以下の４つで行われる。

- Node
  - nodeの実行制御などに利用される
  - mesosみたいなコンテナ実行するための配置戦略などの管理かな？
- ABAC
  - Attribute-based access control. 闇が深そう
  - 使っている例をまだ見たことありません
- RBAC
  - Role-based access control (RBAC)
- Webhook

ちなみに、以下のようなおしゃれな `can-i` methodを利用して自身の権限を確かめることができる。

```
% kubectl auth can-i create deployments --namespace default
yes
```

チャーミングだけどservice userだと確認できないよね？ :thinking_face:

# kubernatesにおけるRABCとは？

やっと本題のRBACに入る。

RABCのRoleにもRole and ClusterRoleを提供している。

> In the RBAC API, a role contains rules that represent a set of permissions. Permissions are purely additive (there are no “deny” rules). A role can be defined within a namespace with a Role, or cluster-wide with a ClusterRole.

読んで時の如くですが、以下の通りcluster wideなものがcluster roleであり、namespaceと一緒に定義したいものが有れば Role　を利用する。

特にcluster roleについては以下のようなケースに利用を制限しろよとのこと。prometheusはcluster wideですね。

- nodeのようなcluster wide resouce
- node, pod, serviceのようなresourceではないendpoint
- 全namespaceに影響させたいもの（あるか？）

# prometheus用の cluster roleを定義

prometheusでnodeの状態、可動コンテの状態、サービスや公開したload balancerの状態などを監視しようとすると、これだけの権限がcluster roleとして必要となる。
名前は適当にmonitorとしている。

```yaml
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  name: monitor
rules:
# ndoes, services, endpoints, podsなどのcontainer情報は無名API Groupなので apiGroupsは無指定
- apiGroups: [""]
  resources:
  - nodes
  - nodes/proxy
  - services
  - endpoints
  - pods
  verbs: ["get", "list", "watch"]
# ingressは `extensions/v1beta1` 配下なので別で指定
- apiGroups:
  - extensions
  resources:
  - ingresses
  verbs: ["get", "list", "watch"]
# resourceで定義されない endpoint。prometheusは `/metric` を見に行くというのが通例なので、そのendpointへのアクセスを許可する
- nonResourceURLs: ["/metrics"]
  verbs: ["get"]
```

# 作成したrole(policy)を束縛(付与)する

user, group, service accountなりに束縛します。

先程作ったものを `monitor` というservice accountに束縛しようとすると以下のような感じ。

service accountを作って

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: monitor
  namespace: default
```

bindする

```yaml
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: monitor
roleRef: # なんのroleを束縛するのか
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: monitor
subjects: # 何に束縛するのか
- kind: ServiceAccount
  name: monitor
  namespace: default
```

作成されたのは以下のような感じ。

```sh
% kubectl get clusterroles | grep monitor
monitor

% kubectl get serviceaccounts
NAME      SECRETS
default   1
monitor   1

% kubectl get clusterrolebinding | grep monitor
monitor
```

# GKEでは

ここでつまりました。想定される権限はすべて付与されているのになぜかprometheusからのrequestが通らない。

そこで、 [google cloud - Role-Based Access Control](https://cloud.google.com/kubernetes-engine/docs/how-to/role-based-access-control) を読んでみると


> ## Role-Based Access Control
> You must grant your user the ability to create roles in Kubernetes by running the following command. [USER_ACCOUNT] is the user's email address:

ふーん。ふーーーーん。以下の感じでcluster-admin commandを自分にbindします。

```
kubectl create clusterrolebinding cluster-admin-binding \
--clusterrole cluster-admin \
--user $(gcloud config get-value account)
```

# Prometheus targets

はい！できました！

![](/images/blog/2018/06/prometheus-targets.png)
