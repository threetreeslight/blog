+++
date = "2013-08-27T06:27:00+00:00"
draft = false
tags = ["dns", "route53", "roadworker"]
title = "RoadworkerでRoute53のDNSレコードを管理"
+++
## roadworkerとは？
***

[cloudpack Night #7で発表しました / Roadworkerというツールを作りました](http://d.hatena.ne.jp/winebarrel/20130824/p1)

> Route53（DNS）のレコードをChefやPuppetのようにコードで管理できる

DNSの切り替えミスとかあ""ーみたいなの起きない。起こさない。

## 環境
***

* ruby2.0.0
* rbenv
* bundler

* AWSアカウント
* Route53 Fullaccess権限をもったIAMインスタンスプロファイル（またはアクセスキー＋シークレットアクセスキー）

詳しくはこちら

[Roadworker doc](http://rubydoc.info/gems/roadworker/0.3.2/file/README.md)

## 下ごしらえ
***


	$ mkdir hogehoge.com
	$ vim .ruby-version
	2.0.0-p247

	$ vim .gitignore
	*.gem
	*.rbc
	.bundle
	/vendor/bundle
	.config
	coverage
	InstalledFiles
	lib/bundler/man
	pkg
	rdoc
	spec/reports
	test/tmp
	test/version_tmp
	tmp
	
	# YARD artifacts
	.yardoc
	_yardoc
	doc/
	
	
	$ Gemfile
	source 'https://rubygems.org'

	gem "roadworker", "~> 0.3.2"

	$ bundle install --path /vendor/bundle
	$ git init
	$ git remote add origin git@bitbucket.org:hoge/hogehoge.com.git
	

参考

* gitignoreとかはgithubほぼ標準
*  [naoya/hbfav.com](https://github.com/naoya/hbfav.com)

## 設定
***

AWS_ACCESS_KEY_IDやら必要に応じて環境変数に入れ、AWSにアクセスできるようにしておく。各々の環境でよしなに。

	Usage
	
	shell> export AWS_ACCESS_KEY_ID='...'
	shell> export AWS_SECRET_ACCESS_KEY='...'
	shell> roadwork -e -o Routefile
	shell> vi Routefile
	shell> roadwork -a --dry-run
	shell> roudwork -a

既存設定を吐き出す。

	$ roadwork -e -o Routefile

テストしてみる。うーん幸せ！

	$ be roadwork -t                                                                                                                                                  
	........
	8 examples, 0 failure

参考 [【AWS】Route53をgitで管理する「Roadworker」を早速試してみました](http://dev.classmethod.jp/cloud/aws/route53-as-code-roadworker/)

## 更新手順
***

記述チェック

	$ roadwork -a --dry-run

更新

	$ roadwork -a
	Apply `Routefile` to Route53
	
冪等性チェック

	$ roadwork -a
	Apply `Routefile` to Route53
	No change

でpush

	$ git push origin master
