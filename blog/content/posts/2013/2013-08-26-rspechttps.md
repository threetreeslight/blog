+++
date = "2013-08-26T02:13:28+00:00"
draft = false
tags = ["rspec", "request_spec", "https", "integration test", "ssl"]
title = "rspecでhttpsをパス"
+++
userのloginとかcontact formとか基本的にhttpsで通信すると思います。


で、そのままrequest_rspecでhttpsのページをgetしようとすると、`www.example.com`に301転送される。

そういうときはget methodにパラメータを追加

	get root_contact_path, {}, "HTTPS" => "on"

[request.env['HTTPS'] = 'on' leads to NoMethodError](https://github.com/rspec/rspec-rails/issues/616)

また、[rspecにおけるbasic auth対応](http://threetreeslight.com/post/59357292457/rspec-basic-auth)の方法によるbasic auth方法を利用している場合は、

	@env["HTTPS"] = 'on'
	get root_contact_path, {}, @env

