+++
date = "2013-02-12T07:36:05+00:00"
draft = false
tags = ["mongoDB", "mongo"]
title = "MongoDBインストール in mac osx"
+++
homebrewにてインストール

    $ brew install mongodb
    
/usr/local/binのownerがおかしいので修正。
    
    $ chmod -R hoge /usr/local/bin

もいっちょインストール
    
    $ brew install mongodb 
    $ mongo -version
    MongoDB shell version: 2.2.2
    
mongo実行

	$ mongo 
	MongoDB shell version: 2.2.2
	connecting to: test
	Tue Feb 12 15:37:21 Error: couldn't connect to server 127.0.0.1:27017 src/mongo/shell/mongo.js:91


プロセス居ないのでmongoのデーモン起動

	$ mongod
	$ mongo
	> show dbs;
	local (empty)

よかたー。