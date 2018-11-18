# Getting Started for Infra

Setup gcloud client and install kubectl

- https://cloud.google.com/sdk/docs/quickstarts

```sh
# Authentication
gcloud auth login
# Set default
gcloud config set project threetreeslight
gcloud config set compute/zone us-west1-a
# Install
gcloud components install kubectl
```

If you don't have cluster-admin, Attach cluster-admin role to logined account

```sh
kubectl create clusterrolebinding cluster-admin-binding \
--clusterrole cluster-admin \
--user $(gcloud config get-value account)
```

Create cluster and disable auto logging

- see also [GCP - Customizing Stackdriver Logs for Kubernetes Engine with Fluentd](https://cloud.google.com/solutions/customizing-stackdriver-logs-fluentd)

```sh
# If you havn't create `blog-cluster` GEK cluster, create it
gcloud container clusters create domain-test

# Stop GEK default node-logging-agent
gcloud beta container clusters update --logging-service=none blog-cluster
```

Set credential

```sh
gcloud container clusters get-credentials blog-cluster
```

Install [Helm](https://docs.helm.sh/using_helm/) and initialize

```sh
# Create serviceaccount for helm
kubectl apply -f kubernetes/helm.yaml
# Install
brew install helm
# Install tiller pod to target cluster
helm init --service-account tiller
```

Install kubesec

```sh
brew install shyiko/kubesec/kubesec
```

(Option) Install useful tools

```sh
brew install kubectx stern
```

# On local

### kubernates dashboard

https://github.com/kubernetes/dashboard

```
kubectl config get-contexts
kubectl config use-context docker-for-desktop
kubectl proxy
open http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#!/overview?namespace=default
```
