+++
date = "2013-03-28T11:44:00+00:00"
draft = false
tags = ["heroku", "postgres", "upgrade", "pg"]
title = "herokuのDBをupgrade"
+++
新しく作ったサービスが、現状のままだとherokuのレコードがdevだと１ヶ月以内に枯渇してしまうので、最低限basicに上げたりDynoを追加しておこうと思う。


### postgresのアップグレード
*** 

	$ heroku addons:add heroku-postgresql:basic
	$ heroku pg -r production
	...
	Plan:        Basic
	Status:      available

### DBバックアップ
***

	$ heroku pgbackups:capture -r production

### サービス停止
***

	$ heroku maintenance:on -r production
	Enabling maintenance mode for hoge... done
	
	$ heroku ps:scale worker=0 -r production
	Scaling worker processes... done, now running 0

### リストア
***

	$ heroku pgbackups:restore HEROKU_POSTGRESQL_HOGE_URL -r production
	$ heroku pg -r production

### DBの切り替え
***
	
	$ heroku pg:promote HEROKU_POSTGRESQL_hoge -r production


### Dyno追加
***

インスタンスを安定化させるためにwebを2へ。

backupをS3に転送するためにも、workerを追加する。

	$ heroku ps:scale web=2 worker=1 -r production
	=== web: `bundle exec thin start -R config.ru -e 	$RAILS_ENV -p $PORT`
	web.1: up 2013/03/28 20:36:43 (~ 32s ago)
	web.2: up 2013/03/28 20:36:38 (~ 37s ago)

	=== worker: `bundle exec rake jobs:work`
	worker.1: up 2013/03/28 20:36:52 (~ 7s ago)

	$ heroku maintenance:off -r production
	Disabling maintenance mode for hoge... done
	
### 古いDBの削除
***

	$ heroku addons:remove HEROKU_POSTGRESQL_FOO -r production

DONE