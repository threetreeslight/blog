+++
date = "2014-01-13T10:15:59+00:00"
draft = false
tags = ["iOS", "iPhone", "objective-c"]
title = "iOS simulaterのディレクトリ構成"
+++
## iOS simulater directory

	~/Library/Application Support/iPhone Simulator/

## Directory構成

	$ ls -l | awk '{ print $9 }'
	Applications
	Containers
	Documents
	Library
	Media
	Root
	tmp
	var

大体Unix OS（というかmac os）と同じ

#### Applications

appファイル群が格納。

パス構成

	$ cd /Applications/${Application_ID}/
	$ ls -l | awk '{ print $9 }'
	Documents # ユーザ又はアプリケーション固有のデータを保存
	Library # ユーザとは直接関係の無いデータを保存
	${Application_Name}.app # app
	tmp # アプリケーションの起動期間中のみ使用する一時的なデータを保存


#### Containers

なんだろう？

#### Documents

iPhoneが利用するユーザ又はアプリケーション固有のデータを保存


#### Media

画像や動画などのメディア、その他ファイル等を格納します。

	$ ls -l | awk '{ print $9 }'
	DCIM # キャプチャした画像や撮影した写真、動画など
	Downloads # その他ファイル
	PhotoData # プレイリストやアルバムのカバーなど
	
#### Root

Root権限ユーザーディレクトリ

設定ファイルとか置いてる

	$ ls -R
	Library

	./Library:
	Managed Preferences
	
	./Library/Managed Preferences:
	mobile
	
	./Library/Managed Preferences/mobile:
	
#### tmp

cacheなどの一時ファイル置き場

#### var

特定プロセスのプロセス番号を含んだファイルやspool(Simultaneous Peripheral Operation On-Line)バッファなど

	$ ls -R
	run	spool
	
	./run:
	launchd_bootstrap.plist		memory_warning_simulation	syslog.pid
	
	./spool:
	mdt
	
	./spool/mdt:


間違ってたらごめんなさい。