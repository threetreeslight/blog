+++
date = "2018-10-06T12:00:00+09:00"
title = "How to manage secret on kubernates?"
tags = ["kubernates", "k8s", "secret", "kubesec"]
categories = ["programming"]
+++

Kubernatesにおけるsecretはとても便利だが、どのようにrepositoryの中で管理していのかが悩ましい。

Yamlファイルを平分で書いておくわけにもいかない。

そんなときに便利なのが [shyiko/kubesec](https://github.com/shyiko/kubesec)

kubesecを使うと、yamlの構造を保持した上で、secret化したい値をPGP, AWS KMS, GCP KMSで暗号化してくれる便利ツール。

更新するときは復号化した標準出力をkubectlに食わせてあげるだけで良い。

Google KMSで暗号化し、secretの更新ができるか早速利用してみる

## Create secret

仮に `passwrod: password` というkey-valueを暗号化するとする

```bash
% echo -n 'password' | base64
cGFzc3dvcmQK
```

上記を利用したsecretを作成します

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: sample
type: Opaque
data:
  password: cGFzc3dvcmQK
```

## Prepare KMS

https://cloud.google.com/kms/docs/quickstart

```bash
gcloud auth application-default login
gcloud kms keyrings create test --location global
gcloud kms keys create sample --location global --keyring test --purpose encryption
gcloud kms keys list --location global --keyring test

NAME                                                                       PURPOSE          LABELS  PRIMARY_ID  PRIMARY_STATE
projects/threetreeslight/locations/global/keyRings/test/cryptoKeys/sample  ENCRYPT_DECRYPT          1           ENABLED
```

うん、期待するkeyringとkeyが作られている。

## Encrypt secret

前項で作成したsecret.yamlをencryptします。

```bash
kubesec encrypt -i --key projects/threetreeslight/locations/global/keyRings/test/cryptoKeys/sample ./secret.yaml
```

こんな感じにencrytedされた値と、どのkeyを使ったかが保持される

```yaml
apiVersion: v1
data:
  password: aTfkm4tryWYfGWpZx6dGrLHKYAx5mhsOUtluPkn59CPi/2nP9TAla9O3PThiwXY3.pfZ4PTL0SEn0+sQ1.DQbjzCifiDBY8e0l9lkd1A==
kind: Secret
metadata:
  name: sample
type: Opaque
# kubesec:v:3
# kubesec:gcp:projects/threetreeslight/locations/global/keyRings/test/cryptoKeys/sample:CiQA5SKQOo6rnU5BREIFwG6zv5QyXNhYFuklEA5DL0nnjPSYuasSSQCMV2a2Cgb1CKkxLR8tImdibCMKdaS66AE3DB7uFsBEmssNYiousaGUl9oMSfMrOZ/+dUn2+tmhBVna+cTornXKQSmHn1J0LsI=
# kubesec:mac:ej2MAiuTLrO1XnF2.uN54JJ3gbQE13A24flicSg==
```

## Edit & Apply

そして `kubesec edit ./secret.yaml` をすると、、、

```yaml
apiVersion: v1
data:
  password: |
    password
kind: Secret
metadata:
  name: sample
type: Opaque
```

decryptされて変更もできる。

更新するときはdecrytpしてapplyすればよいので以下のコマンド実行をciで回せば良い。

```bash
kubesec decrypt secret.yml | kubectl apply -f -
```

これは幸せになれる
