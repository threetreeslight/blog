+++
date = "2013-07-19T05:13:12+00:00"
draft = false
tags = ["AWS", "route53", "s3", "naked domain"]
title = "[AWS]お名前.comからRoute53へDNS乗せ換え + ネイキッドドメインへの転送設定"
+++
頭の中

> 静的ファイルだけであればS3で全然問題ない。むしろ快適。
> でもS3だとネイキッドドメインが利用できない。
> -> 折角だしroute53使えば良いんじゃね！

それだけじゃないんですけどね。

### why route53?
***

お名前.comにてドメインを取得し、お名前.comのDNSサーバーを利用していましたが、以下の３点よりroute53を利用しようと思います。

1. レコード設定数の制限
2. [フェイルオーバー機能](http://aws.typepad.com/aws_japan/2013/05/ebs-snapshot-copy-is-now-incremental-1-1.html)が無い
3. S3に展開した静的webにNakedDomainを設定できる

特に２点目については、使いたい理由の最たる理由（別のサービスでそうなる予定）。

サクラVPNを借りていれば、DNSがタダで使えるので1)が目的だったら、サクラで良くね？っていう意見も・・・。

正直に言うと、単に使いたいだけです。


### コスト
***

コスト的には、標準的サイトであるなら2.25USD/月 ≒ 225円/月程度で収まるんでなかろうか。

フェールオーバー等なければ1USD/月 ≒ 100円/月、年間1200円程度。

これで25個のホストを管理できれば安いもんかな？

	ホスト: 0.5 USD (25ホスト（ドメイン）まで)
	クエリ: 0.5 USD (１００万クエリ毎)
	レイテンシーベースルーティングクエリ: 0.75 USD
	DNS フェイルオーバーのヘルスチェック: 0.5 USD
	--------------------------------------
	2.25 USD / month
	
	* 月１００万クエリ以下である事

参考：[Amazon Route 53](http://aws.amazon.com/jp/route53/#pricing)


### DNS移行
***

それでは早速、お名前.comからroute53へ移行します。

**AWS**

1. コンソールからroute54へアクセス
2. Create Hosted Zone
3. 右ペインの"Domain Name"にドメイン名を入力
4. 右ペインの"Create Hosted Zone"を押下
5. すると右ペイン上に“Delegation Set *:”にネームサーバー情報が記載されています。

**お名前.com**

1. 対象ドメインのネームサーバーにおける「変更する」ボタン押下
2. 他のネームサーバーを利用タブを押下
3. AWSの5.にて取得したネームサーバー情報を入力し、設定

**AWS**

DNSレコードを移行します。

1. Hosted Zonesにて、対象のDomainを選択
2. Go To Record Set
3. create record set

でDNSレコードをごりごり入力して完了。


### S3にてサブドメインをネイキッドドメインに転送
***

**S3**

bucketを作成

	1) www.hogehoge.com
	2) hogehoge.com
	
1) www.hogehoge.comについては、Static Website Hosting設定を Redirect all requests to another host nameにし、リダイレクト先を設定する

2) は Enable website hostingを設定。大体index.htmlと404.htmlの設定


**Route53**

hogehoge.com

1. create record set
2. Alias: Yes
3. Alias targetにhogehoge.comバケットを設定

www.hogehoge.com

1. create record set
2. サブドメインをwww
3. cnameレコードを指定
4. www.hogehoge.comバケットのEndpointをvalueに指定


フェールオーバー周りは、また今度。