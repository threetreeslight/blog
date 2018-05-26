+++
date = "2013-05-14T23:12:00+00:00"
draft = false
tags = ["ssl", "rails", "https"]
title = "railsでhttps通信"
+++
やりたい事

* SSL通信を特定のコントローラーのみに固定する
* production環境時のみ適応させる

### ssl設定
***

	class FoobarController &lt; ApplicationController
		force_ssl :only =&gt; ['show']
	end


参考

* [270: Rails 3.1の認証機能](http://ja.asciicasts.com/episodes/270-authentication-in-rails-3-1)

備忘録をかねて。