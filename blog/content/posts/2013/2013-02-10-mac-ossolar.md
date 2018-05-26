+++
date = "2013-02-10T01:53:00+00:00"
draft = false
tags = ["solr", "mac"]
title = "Mac OSにてsolarを動かしてみる"
+++
### solr download and start
***

download from [Apache Download Mirrors](http://www.apache.org/dyn/closer.cgi/lucene/solr/)


	$ java -version
	java version "1.6.0_37"
	Java(TM) SE Runtime Environment (build 1.6.0_37-b06-434-11M3909)
	Java HotSpot(TM) 64-Bit Server VM (build 20.12-b01-434, mixed mode)
	
	$ tar xvfz solr-4.1.0.tgz
	$ cd solr-4.1.0/example
	$ java -jar start.jar
	…
	INFO: [collection1] webapp=/solr path=/admin/system params={wt=json} status=0 QTime=42 
	
http://localhost:8983/solr/#/


### sample dataのpost
***

	$ cd exampledocs 
	$ java -jar post.jar solr.xml monitor.xml 
	java -jar post.jar solr.xml monitor.xml
	SimplePostTool version 1.5
	Posting files to base url http://localhost:8983/solr/update using content-type application/xml..
	POSTing file solr.xml
	POSTing file monitor.xml
	2 files indexed.
	COMMITting Solr index changes to http://localhost:8983/solr/update..


solr queryを管理画面から発行し、ヒットしている事を確認


### DIHを使ってDBから直接indexを取得する

http://wiki.apache.org/solr/DataImportHandler



### 参考
*** 

* [solr tutrial in japanese](http://www.basistech.jp/lucene/solr-tutorial/)


### P.S.

postgres9x系だったら全文検索もついているから、postgres使うのだったら不要な気持ち。

[PostgreSQL 9.1 の新機能](http://lets.postgresql.jp/documents/technical/9.1/1)

ついでに、websolrなるものもあり、herokuのアドオンとして存在するので、なんとしても全文検索したいのであればそれを使うのが手っ取り早そう。


[Powerful search, easy setup.| websolr](http://websolr.com/)