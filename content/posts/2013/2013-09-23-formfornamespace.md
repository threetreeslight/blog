+++
date = "2013-09-23T13:57:29+00:00"
draft = false
tags = ["form_for", "namespace", "controller", "action"]
title = "form_for利用時に、namespace付きのコントローラーに飛ばしたい"
+++
ちょいと前に、特定のコントローラーアクションに飛ばしたいという方法を紹介しましたが、

[form_forの処理を別のcontrollerに飛ばしたいとき](http://threetreeslight.com/post/61956227732/form-for-controller)

updateとcreateアクションをよしなに制御してくれるform_for methodの利点生かしきれてないよね？

というわけで、ドキュメント潜ったところ、namespace付きでネストするときは以下のやり方やればよかったです。


	= form_for( [:admin, @user]) do |f|
	…
	
	end
	
	
上記のような方法で実装する事で、createの場合はadmin_users_controllerのpost methodで、updateの場合は admin_users_controllerのput methodでよしなになります。




参考：[ActionView::Helpers::FormHelper](http://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-form_for-label-Resource-oriented+style)