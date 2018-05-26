+++
date = "2013-06-01T14:35:11+00:00"
draft = false
tags = ["rails", "log", "session", "cookies"]
title = "railsのログにセッションIDやリモートIPを表示するようにする"
+++

### remote_ipを吐き出す方法
***

config.log_tagsにて、セッション毎にuuid発行と、アクセスユーザーのipを記録するようにする」。

config/environment/develpment.rb

	# Prepend all log lines with the following tags
	config.log_tags = [ :subdomain, :uuid, :remote_ip ]

config/environment/production.rb

	# Prepend all log lines with the following tags
	config.log_tags = [ :subdomain, :uuid, :remote_ip ]


参考

* [#318 Upgrading to Rails 3.2](http://railscasts.com/episodes/318-upgrading-to-rails-3-2?language=ja&view=asciicast)

### cookieなどのセッション情報をloggerにて記録したい場合
***

loggerより前にCookiesの処理を持ってくれば良い

config/application.rb
 
	config.middleware.delete(ActionDispatch::Cookies)
	config.middleware.delete(ActionDispatch::Session::CookieStore)
	config.middleware.insert_before(Rails::Rack::Logger, ActionDispatch::Session::CookieStore)
	config.middleware.insert_before(ActionDispatch::Session::CookieStore, ActionDispatch::Cookies)

ちなみに、rack処理の実行順序

	> Rails.configuration.middleware.instance_variable_get(:@middlewares)
	=> [Rack::MiniProfiler,
	 ActionDispatch::Static,
	 Rack::LiveReload,
	 Rack::Rewrite,
	 Rack::Lock,
	 #<ActiveSupport::Cache::Strategy::LocalCache::Middleware:0x007faef2c1c0e8>,
	 Rack::Runtime,
	 Rack::MethodOverride,
	 ActionDispatch::RequestId,
	 Rails::Rack::Logger,
	 ActionDispatch::ShowExceptions,
	 ActionDispatch::DebugExceptions,
	 ActionDispatch::RemoteIp,
	 ActionDispatch::Reloader,
	 ActionDispatch::Callbacks,
	 ActiveRecord::ConnectionAdapters::ConnectionManagement,
	 ActiveRecord::QueryCache,
	 ActionDispatch::Cookies,
	 Rack::P3p,
	 ActionDispatch::Session::CookieStore,
	 ActionDispatch::Flash,
	 Jpmobile::Rack::MobileCarrier,
	 ActionDispatch::ParamsParser,
	 ActionDispatch::Head,
	 Rack::Condition
	 
参考

* [How to log user_name in Rails?](http://stackoverflow.com/questions/10811393/how-to-log-user-name-in-rails)


と思ったけど、上記のような事をせず、lambdaにrequestを引数として頂けるので、そっからcookies取とってくればいいのね。

	config.log_tags = [ :remote_ip,
	                    lambda {|req| req.cookies["_'app name'_session"]}
	                  ]

尚、config.initialize.session_store.rbを見れば、cookieに保存されるsessionのkeyは分かります。

### 各環境に書くのがいやなので、
***

config/initializers/loggin.rb

	Rails.configuration.log_tags = [
	  :remote_ip,
	  lambda {|req| req.cookies["_hoge_session"]}
	 ]
