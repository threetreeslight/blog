+++
date = "2013-05-05T02:16:06+00:00"
draft = false
tags = ["rails", "notifications", "error", "exception", "raise"]
title = "[rails]whereにおけるnil.methodの取扱い"
+++
ユーザーであれば問題ないのだけど、クローラーが叩く、ガンガン叩くのが困る。

500が返っている事もあり、exception_notificationを入れているとお知らせが来て、悲しい。

という訳で

	ActiveRecord::RecordNotFound 
	=> 404 (page not found)

	nil.method 
	=> 500 (server error) unless you turn off whiny nils

	ActionController::RoutingError 
	=> 404 (page not found)
	
	
二番目の子をnilのときにActiveRecord::RecordNotFoundをraiseするようにして良い子にしました。

	@post = Post.where(:name => params[:name]).first
	raise ActiveRecord::RecordNotFound if @post.nil?


rails4だとdyanmic finderが非推奨な訳だし、何かしらもっと良い方法ないかしら？