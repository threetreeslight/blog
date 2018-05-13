+++
date = "2013-01-20T04:53:25+00:00"
draft = false
tags = ["postgres", "Heroku", "db"]
title = "[Heroku][Postgres]production環境のdbをローカルに取り込む"
+++
production環境のdbをローカルに取り込むメモ。


require on production
* heroku
* postgres
* pgbackups addon

require on local
* postgres.app


heroku上に展開しているapplicationが対象

    $ curl -o latest.dump `heroku pgbackups:url`
    $ pg_restore --verbose --clean --no-acl --no-owner -h localhost -d mydb latest.dump


P.S. 
staging環境（heroku）に持っていく方法

$ heroku pgbackups:restore HEROKU_POSTGRESQL_BLACK b251 



参考
* [pg_restore](http://www.postgresql.jp/document/7.3/reference/app-pgrestore.html)
* [pgbackup](https://devcenter.heroku.com/articles/pgbackups)