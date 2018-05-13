+++
date = "2013-09-22T13:47:36+00:00"
draft = false
tags = ["rails4", "form_for", "constraints", "namaspace", "routing", "admin"]
title = "form_forの処理を別のcontrollerに飛ばしたいとき"
+++
管理系の画面のroutingの作り方（もとい考え方）を刷新し、より疎且つシンプルな作りにしました。

その際に、管理系の画面作業は、管理系のコントローラーで更新する必要が会ったので、メモ。

require

* ruby 2.0
* rails 4

routing
-------

例えば、以下のようにroutingが設定されているとします。

	$ vim config/routes.rb

	  resources :users
	  
	  constraints :subdomain => "admin" do
	    namespace :admin, path: '' do
	      root 'admin#index'
	      resources :users
	    end
	  end
	
	$ ls -laR app/controllers
	
	users_controller.rb
	admin/users_controller.rb
	


* サブドメインadminを管理系画面とする。
* User情報の編集は、管理系からも行えるし、adminからも行う事が出来る。
* User, 管理系でコントローラーを分離する。


admin/userによるUserの更新
-------------------

form_forにurlオプションつければok!

	$ vim app/views/admin/users/_form.html.slim
	= form_for @user,
	           url: admin_user_path( id: @user.id ),
	           html: { class: 'form-horizontal' } do |f|
	...     

