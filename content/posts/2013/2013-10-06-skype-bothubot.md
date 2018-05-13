+++
date = "2013-10-06T07:45:00+00:00"
draft = false
tags = ["hubot", "python", "pip", "node", "npm", "skype"]
title = "skype botとしてhubotいれてみた"
+++
GithubのDevOpsネタでhubotが紹介されていたので、折角なので導入してみようと思います。

[GitHub社内のDevOpsを支えるツール「Boxen」と「Hubot」～DevOps Day Tokyo 2013](http://www.publickey1.jp/blog/13/githubdevopsboxenhubotdevops_day_tokyo_2013.html)

require
-------

* node v0.10.13
* npm 1.3.2
* redis

nodeがインストールされていない場合は、ここ [Installing Node and npm](http://www.joyent.com/blog/installing-node-and-npm)を参考。

boxenでセットアップするのが個人的なおすすめです。

[Boxenを利用したMacのセットアップ](http://threetreeslight.com/post/58009785849/boxen-mac)

Install
-------

基本、本家のマニュアルそのままですが、

hubotいれる

	$ npm install -g hubot coffee-script

ひな形を作る。

	$ hubot --create myhubot

パスが通らなかった場合は、もう一度`$ source ~/.zshrc`とかするか、パス張り直す。

git設定。

	$ cd myhubot
	$ git init
	$ git add .
	$ git commit -m "Initial commit"

立ち上げてみます。

	$ bin/hubot

	hubot> hubot: help
	
	Hubot> @hubot ping
	Hubot> PONG

おぉ！レスポンスが帰ってくる。

> This starts hubot using the shell adapter, which is mostly useful for development. Make note of Hubot>; this is the name he'll respond to with commands. For example, to list available commands:

上記はモジュールを開発するときとか便利です。との事。


ちなみに、hubot君に独自の名前を付けたいときは。

	% bin/hubot --name myhubot
	myhubot>

あと、hubotくんの呼び出しは、下記のいずれでもokとの事。

	MYHUBOT help
	myhubot help
	@myhubot help
	myhubot: help


[Getting Started With Hubot](https://github.com/github/hubot/tree/master/docs#getting-started-with-hubot)


hubot adapter
----------

hubotの本懐たる幸せアダプター群


[Hubot Adapters](https://github.com/github/hubot/blob/master/docs/adapters.md)


今回はSkypeに接続してみます。

connect skype
----------------

require

* python
* pip
* skype account x 2 ( for hubot and me)

[Hubot Skype Adapter](https://github.com/netpro2k/hubot-skype)

hubot-skypeをインストール

	$ vim package.json
	  "dependencies": {
	    "hubotbot-skype": "git://github.com/netpro2k/hubot-skype.git",
	    "hubot":         ">= 2.6.0 < 3.0.0",
	    "hubot-scripts": ">= 2.5.0 < 3.0.0"
	  },
	$ npm install
	
skypeとお話しするpythonモジュールを入れます。

	$ pip search skype4py
	$ sudo pip install Skype4Py

pipやpython入ってないよ！って言う場合は、pythonはpyenv入れて管理するのが良さげ。

[pyenv](https://github.com/yyuu/pyenv)

以下pipのインストール

	# install pip
	$ easy_install pip
	
Ansibleなどのプロビジョニングツールもあるし、sublimeのpackage開発にも使いそうなので、入れておくと便利だと思います。

起動します。OS Xの場合は32bitモードでpythonを起動する必要が有ります。skype4pyが32bitにしか対応していないため。


	$ export VERSIONER_PYTHON_PREFER_32_BIT=yes
	$ bin/hubot -a skype


で

	Skype> @hubot ping
	Skype> PONG

linux環境では？
----

基本はX windowで作業

[hubot-skype#linux](https://github.com/netpro2k/hubot-skype#linux)

X window利用せずcui環境でskypeをデーモン化するためには

[Linux上で動くSkype用のbotを作る方法](http://d.hatena.ne.jp/moriyoshi/20100926/1285517353)
