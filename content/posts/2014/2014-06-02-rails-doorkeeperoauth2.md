+++
date = "2014-06-02T05:02:00+00:00"
draft = false
tags = ["rails", "oauth", "doorkeeper"]
title = "[rails] doorkeeperでOAuth2"
+++
ユーザー毎にトークンでやり取りするのはちょっとアレなので、アプリからoauth2にしようと思う。

## rails下ごしらえ

プロジェクト作る　

	$ rails new oauth2-sample -T --skip-bundle
	
適当にコントローラー作る

	$ rails g controller root index

## OAuth Provider

### devise

install devise
 
	$ vim Gemfile
	gem 'devise'

	$ rails generate devise:install
      create  config/initializers/devise.rb
      create  config/locales/devise.en.yml
	===============================================================================
	
	Some setup you must do manually if you haven't yet:
	
	  1. Ensure you have defined default url options in your environments files. Here
	     is an example of default_url_options appropriate for a development environment
	     in config/environments/development.rb:
	
	       config.action_mailer.default_url_options = { host: 'localhost:3000' }
	
	     In production, :host should be set to the actual host of your application.
	
	  2. Ensure you have defined root_url to *something* in your config/routes.rb.
	     For example:
	
	       root to: "home#index"
	
	  3. Ensure you have flash messages in app/views/layouts/application.html.erb.
	     For example:
	
	       <p class="notice"><%= notice %></p>
	       <p class="alert"><%= alert %></p>
	
	  4. If you are deploying on Heroku with Rails 3.2 only, you may want to set:
	
	       config.assets.initialize_on_precompile = false
	
	     On config/application.rb forcing your application to not access the DB
	     or load models when precompiling your assets.
	
	  5. You can copy Devise views (for customization) to your app by running:
	
	       rails g devise:views
	
	===============================================================================

上にあるようにconfigとrootを修正。

ユーザーモデル作る

	$ rails generate devise User
	$ rake db:migrate
	

### Install doorkeeper

gem ぶっこんで、generator動かす


	$ rails generate doorkeeper:install
      create  config/initializers/doorkeeper.rb
      create  config/locales/doorkeeper.en.yml
       route  use_doorkeeper
	===============================================================================
	
	There is a setup that you need to do before you can use doorkeeper.
	
	Step 1.
	Go to config/initializers/doorkeeper.rb and configure
	resource_owner_authenticator block.
	
	Step 2.
	Choose the ORM:
	
	If you want to use ActiveRecord run:
	
	  rails generate doorkeeper:migration
	
	And run
	
	  rake db:migrate
	
	If you want to use Mongoid, configure the orm in initializers/doorkeeper.rb:
	
	# Mongoid
	Doorkeeper.configure do
	  orm :mongoid
	end
	
	If you want to use MongoMapper, configure the orm in
	initializers/doorkeeper.rb:
	
	# MongoMapper
	Doorkeeper.configure do
	  orm :mongo


なるほど。とりあえず設定は素でいきながら、必要なDBを作って行きます。

	$ rails generate doorkeeper:migration
	$ rake db:migrate
	
あーなるほど、こういうスキーマでやるのですね。

	$ vim config/initializers/doorkeeper.rb

さてさて、どんなroutingが出来ているのか確認すると、、、

	$ rake routes
	
	                       Prefix Verb     URI Pattern  
	                       ...                                   
	                  oauth_token POST     /oauth/token(.:format)                       doorkeeper/tokens#create
	                 oauth_revoke POST     /oauth/revoke(.:format)                      doorkeeper/tokens#revoke
	           oauth_applications GET      /oauth/applications(.:format)                doorkeeper/applications#index
	                              POST     /oauth/applications(.:format)                doorkeeper/applications#create
	        new_oauth_application GET      /oauth/applications/new(.:format)            doorkeeper/applications#new
	       edit_oauth_application GET      /oauth/applications/:id/edit(.:format)       doorkeeper/applications#edit
	
	            oauth_application GET      /oauth/applications/:id(.:format)            doorkeeper/applications#show
	                              PATCH    /oauth/applications/:id(.:format)            doorkeeper/applications#update
	                              PUT      /oauth/applications/:id(.:format)            doorkeeper/applications#update
	                              DELETE   /oauth/applications/:id(.:format)            doorkeeper/applications#destroy
	oauth_authorized_applications GET      /oauth/authorized_applications(.:format)     doorkeeper/authorized_applications#index
	 oauth_authorized_application DELETE   /oauth/authorized_applications/:id(.:format) doorkeeper/authorized_applications#destroy
	             oauth_token_info GET      /oauth/token/info(.:format)                  doorkeeper/token_info#show


ほほぅ。立ち上げてみます。

	$ rails s
	$ open http://localhost:3000/oauth/applications
	
application作りや発行辺りとかガッツリつくられるのね。なるほど。

こんな感じ

![](https://31.media.tumblr.com/4479cbe274816ada41c16f351410793e/tumblr_inline_n6izbs1Tl81r11648.png)

### deviseと結びつけ

	$ vim config/initializers/doorkeeper.rb
	
	...
	resource_owner_authenticator do
	  current_user || warden.authenticate!(:scope => :user)
	end

	...

こんな感じで、

	$ rails s
	$ open http://localhost:3000/oauth/applications

で試しに作ったoauthからredirect試します。

![](https://31.media.tumblr.com/c4ee26b4987fcdbcd91ed49983cf5d0d/tumblr_inline_n6izc3q16S1r11648.png)

![](https://31.media.tumblr.com/5313eb0d2d46dc5ee744f4a840c50f71/tumblr_inline_n6izcajnJg1r11648.png)

![](https://31.media.tumblr.com/ef1e119d83c303a98b62f0c3c0aa1916/tumblr_inline_n6izchXsTc1r11648.png)

![](https://31.media.tumblr.com/599f9df1ee4199b3f25872ef1286bc8e/tumblr_inline_n6izdhLPCX1r11648.png)

なるほど、見事登録から作成まで行けました。

さて、token周りの情報とか見てみます。

	$ rails db
	> select * from oauth_access_grants;
	1|1|1|5fe19fa9e31f1d5d9f878c6962b7a0e88e400eb35420cf414398aa288f9a6a79|600|http://localhost:3000|2014-05-31 08:20:15.766417||

と`oauth_access_grats`と以下の内容が紐づいてtokenが発行されている事が分かります。

- oauth_applicationsのid
- userのid
- expireのdatetime

これでoauthが正しく動作している事が分かります。

## routingを切り分ける

さらに言えば、切り分けたいですよね、routing。
例えば、admin配下でのみapplicationsやauthorized_applicationsが動くようにするとか。

	  use_doorkeeper do
	    skip_controllers :applications, :authorized_applications
	  end
	
	  constraints :subdomain => "admin" do
	    use_doorkeeper do
	      skip_controllers :authorizations, :tokens
	    end
	  end

もちろんそのときはcustom controllerでadmin配下をauthenticate必須にしてあげる必要が有ります。


参考：[Customizing routes ](https://github.com/doorkeeper-gem/doorkeeper/wiki/Customizing-routes)


### 包括的な参考

- [doorkeeper-gem/doorkeeper-provider-app](https://github.com/doorkeeper-gem/doorkeeper-provider-app)


すごい楽だ。

