+++
date = "2014-06-02T06:18:00+00:00"
draft = false
tags = ["doorkeeper", "api", "client", "oauth", "devise"]
title = "[rails]doorkeeperに対応したOAuth clientを作成"
+++
さてOAuth clientを作ります。

## OAuth Providerの設定

先ほど作ったoauth providerに新しいアプリを登録します。

callback url : `http://localhost:4000/users/auth/doorkeeper/callback`

![](https://31.media.tumblr.com/822150f30488b1c5d0741160a3fa1b72/tumblr_inline_n6j2s1QiSd1r11648.png)


## Provider: user情報取得用APIを作成

provider側の作業です


/api/me.jsonにてuser情報を返してあげるようにします。


api用のcontrollerを切ります。

	$ vim app/controller/api/api_controller.rb
	module Api
	  class ApiController < ::ApplicationController
	    private
	    def current_resource_owner
	      User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
	    end
	  end
	end

user情報を返してあげるようにします。

	$ vim app/controller/api/credentials_controller.rb
	module Api
	  class CredentialsController < ApiController
	    doorkeeper_for :all
	    respond_to     :json
	
	    def me
	      respond_with current_resource_owner
	    end
	  end
	end


routingを設定

	$ vim config/routes.rb
	namespace :api do
	  # another api routes
	  get '/me' => "credentials#me"
	end


これでよし

## clientのrails下ごしらえ

プロジェクト作る　

	$ rails new oauth2-client-sample -T --skip-bundle
	$ rails g controller root index

install gems
 
	$ vim Gemfile
	gem 'dotenv-rails'
	gem 'devise'
	gem 'omniauth-oauth2'
	
	# ここらへんdebug用
	gem 'pry-rails'
	gem 'pry-debugger'
	gem 'pry-remote'
	gem 'tapp'
	gem 'hirb-unicode'
	
	$ bundle


pryの設定もついでに

	$ vim .pryrc
	begin
	  require 'hirb'
	rescue LoadError
	  # Missing goodies, bummer
	end
	
	if defined? Hirb
	  # Slightly dirty hack to fully support in-session Hirb.disable/enable toggling
	  Hirb::View.instance_eval do
	    def enable_output_method
	      @output_method = true
	      @old_print = Pry.config.print
	      Pry.config.print = proc do |output, value|
	        Hirb::View.view_or_page_output(value) || @old_print.call(output, value)
	      end
	    end
	
	    def disable_output_method
	      Pry.config.print = @old_print
	      @output_method = nil
	    end
	  end
	
	  Hirb.enable
	end

てきとうなcontroller作成

	$ rails g controller root index


### 環境変数

先ほど作成したoauth applicationの環境変数を設定

- Application Id
- Secret
- auth先のURL

の３つ。

	$ vim .env
	DOORKEEPER_APP_ID = "375c2e3fdef2acba33ceefaa14be2b251d5174b9defc2a3b8e27fee8103a5aeb"
	DOORKEEPER_APP_SECRET = "6a2fa82ab6f7b565c8f8f57f677e408ebcda208709bde6eae0a784b48b49205c"
	DOORKEEPER_APP_URL = "http://localhost:3000"

## devise setup	

いつも通りユーザー作る

	$ rails generate devise:install
 	$ rails generate devise User
	$ rails g migration AddColumnsToUsers provider uid token
	$ rake db:migrate


### strategyを作成

client_optionsについてはデフォルト値で、deviseの設定にて更新する事が出来ます。

なお叩きに行くURLは、`http://localhost:3000/oauth/authorize`です。

	$ mkdir lib/omniauth/stragtegies/doorkeeper.rb	
	module OmniAuth
	  module Strategies
	    class Doorkeeper < OmniAuth::Strategies::OAuth2
	      option :name, :doorkeeper
	
	      option :client_options, {
	        :site => "http://localhost:3000",
	        :authorize_path => "/oauth/authorize"
	      }
	
	      uid do
	        raw_info["id"]
	      end
	
	      info do
	        {
	          :email => raw_info["email"]
	        }
	      end
	
	      def raw_info
	       	# provider側で作ったAPIを叩きます。
	        @raw_info ||= access_token.get('/api/me.json').parsed
	      end
	    end
	  end
	end


- [intridea/omniauth-oauth2](https://github.com/intridea/omniauth-oauth2)

### deviseにstrategyを適用

	$ vim config/initializers/devise.rb

	require File.expand_path('lib/omniauth/strategies/doorkeeper', Rails.root)

	Devise.setup do |config|
	...
	  config.omniauth :doorkeeper,
	                  ENV['DOORKEEPER_APP_ID'],
	                  ENV['DOORKEEPER_APP_SECRET'],
	                  options: { client_options: { site: ENV['DOORKEEPER_APP_URL'] } }
	...

ここまでの参考

- [wiki/Create-a-OmniAuth-strategy-for-your-provider#omniauth-strategy](https://github.com/doorkeeper-gem/doorkeeper/wiki/Create-a-OmniAuth-strategy-for-your-provider)
- [lib/omniauth/strategies/doorkeeper.rb](https://github.com/doorkeeper-gem/doorkeeper-devise-client/blob/master/lib/omniauth/strategies/doorkeeper.rb)



## routingにcallbackを設定

	$ vim config/routes.rb
	...
	
	  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
	
	  root to: "root#index"


### modelにおけるomniauthが動くように整備

まずomniauthableに

	$ vim app/models/user.rb
	class User < ActiveRecord::Base
	  # Include default devise modules. Others available are:
	  # :confirmable, :lockable, :timeoutable and :omniauthable
	  devise :database_authenticatable, :registerable,
	         :recoverable, :rememberable, :trackable, :validatable,
	         :omniauthable

	end


oauthからのcallbackに対し、

- Userを検索し、存在しない場合は作成する処理
	- （今回の場合はprividerとclientが同じ場所なので、存在しない場合の新規作成はありません）
- doorkeeperのaccess_tokenを更新する処理

の二つをさらに追加追加します。

	class User < ActiveRecord::Base

	...
		
	  def self.find_or_create_for_oauth(oauth_data)
	    User.find_or_initialize_by( uid: oauth_data.uid,
	                                provider: oauth_data.provider).tap do |user|
	      user.email = oauth_data.info.email
	    end
	  end
	
	  def update_credentials(oauth_data)
	    self.token = oauth_data.credentials.token
	  end
	end

## omniauth_callbacksを作成

callbackに帰ってきたdataより

- User検索もしくは新規作成
- credentialsの更新処理

する処理を追加


	$ vim app/controllers/users/omniauth_callbacks_controller.rb
	class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
	  def doorkeeper
	    oauth_data = request.env["omniauth.auth"]
	    @user = User.find_or_create_for_oauth(oauth_data)
	    @user.update_credentials(oauth_data)
	    @user.save
	
	    sign_in_and_redirect @user
	  end
	end
	
## layoutファイルにoauth認証へのlinkを追加

	$ vim app/views/layout/application.html.erb
	
	<% if current_user %>
	  <%= link_to "Sign out", destroy_user_session_path, method: 'delete' %>

	<% else %>
	  <%= link_to "Sign in with OAuth 2 provider", user_omniauth_authorize_path(:doorkeeper) %>
	<% end %>
	

とするとこんな感じ。

![](https://31.media.tumblr.com/99970a5345921ec2f499e151abaafb27/tumblr_inline_n6j2sueUKD1r11648.png)

## 動かして見ると


![](https://31.media.tumblr.com/99970a5345921ec2f499e151abaafb27/tumblr_inline_n6j2sueUKD1r11648.png)

![](https://31.media.tumblr.com/9ea4b35059ca4054a1c253ffd11e9ff7/tumblr_inline_n6j2t5RQfu1r11648.png)


![](https://31.media.tumblr.com/dab876307dd9c1dcd92c475b1ed7425b/tumblr_inline_n6j2tvRYi21r11648.png)

## 参考

- [doorkeeper-gem/doorkeeper-provider-app](https://github.com/doorkeeper-gem/doorkeeper-provider-app)
- [doorkeeper-gem/doorkeeper-devise-client](https://github.com/doorkeeper-gem/doorkeeper-devise-client)


