+++
date = "2013-04-22T08:16:00+00:00"
draft = false
tags = ["ssl", "https", "secure", "security", "heroku", "rails"]
title = "herokuへデプロイしているサービスのssl設定"
+++
herokuでhttpsアクセスできるようにしたいので、RapidSSL使います。


## csr作成
***

	$ openssl genrsa -des3 -out server.orig.key 2048
	$ openssl rsa -in server.orig.key -out server.key
	$ openssl req -new -key server.key -out server.csr
	You are about to be asked to enter information that will be incorporated
	into your certificate request.
	What you are about to enter is what is called a Distinguished Name or a DN.
	There are quite a few fields but you can leave some blank
	For some fields there will be a default value,
	If you enter '.', the field will be left blank.
	-----
	
	Country Name (2 letter code) [AU]:JP
	State or Province Name (full name) [Some-State]:Tokyo
	Locality Name (eg, city) []:hoge
	Organization Name (eg, company) [Internet Widgits Pty Ltd]: 
	Organizational Unit Name (eg, section) []:
	Common Name (eg, YOUR name) []:hogehoge.com
	Email Address []:
	
	Please enter the following 'extra' attributes
	to be sent with your certificate request
	A challenge password []:
	An optional company name []:
	
	$ ls |ack server
	server.csr
	server.key
	server.orig.key
	
参考

* [Creating an SSL Certificate Signing Request](https://devcenter.heroku.com/articles/csr)


## RappidSSLにCSRを登録
***

RapidSSLへ登録するCSRをコピー

	$ pbcopy &lt; server.csr

RapidSSLからのメールにあるserver certificationとINTERMEDIATE certificationをserver.crtにコピペ

	$ vim server.crt
	# コピペ

(DNSimpleからやればよかったと今更ながらに後悔)


## herokuにSSL設定
***

	$ heroku addons:add ssl
	$ heroku certs:add --app hoge server.crt server.key
	$ heroku certs
	...
	hoge.herokussl.com

## DNSレコードの設定
***

CNAMEにhoge.herokussl.comを追加

(Naked Domainの場合はnslookup等でIPを調べる)

	$ nslookup hoge.herokussl.com

## ssl通信をweb service全体で強制したい場合
***

	$ vim config/environmenets/production.rb
	config.force_ssl = true
