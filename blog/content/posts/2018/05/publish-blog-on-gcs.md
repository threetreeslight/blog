+++
date = "2018-05-07T22:07:00+09:00"
title = "Publish blog on GCS"
tags = ["gcp", "blog", "static"]
categories = ["programming"]
+++


とりあえずある程度形ができたので、publishしていきたいと思う。

## hosting static website on gcs

とりあえずgcsでstatic site hosting出来るだろうと思ったら、あった。

https://cloud.google.com/storage/docs/hosting-static-website

まずはdomainの所有権をgoogle search consoleから取得しなければいけないというところにgoogleっぽさを感じた。

AWS S3ではbucket作ってcnameで飛ばせば良いだけなのに対し、GCP上では結構違う

1. domain nameを含むバケットの場合は、ドメインの所有権認証をする
    1. https://cloud.google.com/storage/docs/domain-name-verification#verification
    1. googleっぽい
1. valueに `c.storage.googleapis.com.` を指定したCNAME DNS recordを作成する
    1. GCSはGCP内からのアクセスを前提としたストレージであり、public endpointが最初から提供されていないということかな？
    1. 公開endpointは `c.storage.googleapis.com` にアクセスするとproxyされるという妙
1. あとはgcs bucketを作って、コンテンツをuploadし、各ファイルにread権限を付与
1. 静的サイトのエンドポイントにアクセスしたときに表示するページやエラーページを指定

一旦公開できた。

