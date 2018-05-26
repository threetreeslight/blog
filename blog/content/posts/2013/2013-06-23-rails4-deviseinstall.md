+++
date = "2013-06-23T10:25:57+00:00"
draft = false
tags = ["rails", "rails4", "devise"]
title = "rails4 + deviseのinstall"
+++
[devise](https://github.com/plataformatec/devise)のcommit logを見ると、どうやら3.0.0.rcでrails4のStrong Parameters対応しましたよっ！って書いてある。

> ###3.0.0.rc
> ***
> 
> * enhancements
> * Rails 4 and Strong Parameters compatibility. (@carlosantoniodasilva, @josevalim, @latortuga, @lucasmazza, @nashby, @rafaelfranca, @spastorino)
> * Drop support for Rails < 3.2 and Ruby < 1.9.3.

やったー！それでは

### 素直に入れる
***

	$ vim Gemfile
	gem 'devise', '~>3.0.0rc'
	
	$ bundle install
	
	$ rails generate devise:install
	      create  config/initializers/devise.rb
	   identical  config/locales/devise.en.yml

	$ vim config/environment/development
	config.action_mailer.default_url_options = { :host => 'localhost:3000' }
		
	$ rails g devise:view
	      invoke  Devise::Generators::SharedViewsGenerator
	      create    app/views/devise/shared
	      create    app/views/devise/shared/_links.erb
	      invoke  form_for
	      create    app/views/devise/confirmations
	      create    app/views/devise/confirmations/new.html.erb
	      create    app/views/devise/passwords
	      create    app/views/devise/passwords/edit.html.erb
	      create    app/views/devise/passwords/new.html.erb
	      create    app/views/devise/registrations
	      create    app/views/devise/registrations/edit.html.erb
	      create    app/views/devise/registrations/new.html.erb
	      create    app/views/devise/sessions
	      create    app/views/devise/mailer/unlock_instructions.html.erb

	$ rails generate devise User
	      invoke  active_record
	      create    db/migrate/20130623064209_add_devise_to_users.rb
	      insert    app/models/user.rb
	       route  devise_for :models

### db migration
***

ユーザーにroleを追加したいのでカラム追加。

	$ vim db/migrate/20130623064209_add_devise_to_users.rb
	…
      ## role
      t.string :role

      # Uncomment below if timestamps were not included in your original model.
      t.timestamps

	$ rake db:migrate

roleの制御を追加。とりあえずROLESに応じたメソッド追記。

User::ROLESをロールを追加すれば、それに応じたroleメソッドが定義されるようメタプロ。

	$ vim app/models/user.rb
	
	  ROLES = %w[admin]
	  ROLES.each do |role|
	    define_method("#{role}?") {
	      self.role == role
	    }
	  end


### routingとアクセス制御
***

個人的には/admin配下に置くのが好きなので、admin_controllerを作成。こいつを初期ビューにする。

	$ rails g controller admin
	$ vim app/controllers/admin_controller.rb
	  def index; end

	$ touch app/views/admin/index.html.haml

そしてadmin配下にroutingを設定

	$ vim config/routes.rb
	  scope "/admin" do
	    get "/" => 'admin#index', as: :admin
	    
	    get "/" => "admin#index", as: :user_root
	    devise_for :users
	  end

/admin配下のルーティングについては、権限が無い場合は/adminに飛ばして上げたい。

	$ vim app/controllers/application_controller.rb

	  User::ROLES.each do |role|
	    define_method("authenticate_#{role}!") {
	      unless current_user.send("#{role}?")
	        redirect_to admin_path, alert: "アクセス権限が正しくありません"
	      end
	    }
	  end

対象となるコントローラーにbefore_actionを追加。

	$ vim app/controllers/hoge_controller.rb
	...
	  before_action :authenticate_admin!
	…

### view

deviseのlayoutsをadmin用に変更

	$ touch app/views/layouts/admin/application.html.haml
	$ vim app/controllers/application_controller.rb

	  layout :layout_by_resource

	  def layout_by_resource
	    if devise_controller?
	      "admin/application"
	    else
	      "application"
	    end
	  end

参考
 
* [How-To:-Create-custom-layouts](https://github.com/plataformatec/devise/wiki/How-To:-Create-custom-layouts)


あとのsing up, sing in やlogoutはよしなに本家referrenceを参照。



	
