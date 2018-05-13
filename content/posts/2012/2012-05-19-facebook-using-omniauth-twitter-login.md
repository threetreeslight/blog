+++
date = "2012-05-19T15:08:00+00:00"
draft = false
tags = ["facebook", "twitter", "omniAuth", "rails", "gem"]
title = "Facebook using omniAuth, twitter login"
+++
<p>omniAuth実装</p>
<p>ruby1.9.2 + rails3.2 + OmniAuth 1.0</p>
<p><br>reg twitter app at twitter and Facebook dev center &nbsp;:&nbsp;</p>
<blockquote>
<p>https://dev.twitter.com/apps<br>https://developers.facebook.com&nbsp;</p>
</blockquote>
<p><br><br>edit Gemfile :&nbsp;</p>
<blockquote>
<p>+ gem 'omniauth'<br>+ gem 'omniauth-twitter'<br>+ gem 'omniauth-facebook'</p>
</blockquote>
<p><br>install gems :&nbsp;</p>
<blockquote>
<p>$ bundle install</p>
</blockquote>
<p><br>make&amp;edit config/initialize/omniauth.rb :</p>
<blockquote>
<p>Rails.application.config.middleware.use OmniAuth::Builder do<br>&nbsp; provider :twitter, 'Consumer Key', 'Consumer Secret'<br>&nbsp; provider :facebook, 'app id', 'app Secret key'<br>end</p>
</blockquote>
<p><br>app/contorllers/application_controller.rb :&nbsp;</p>
<blockquote>
<p>class ApplicationController &lt; ActionController::Base<br>&nbsp; protect_from_forgery<br>&nbsp; helper_method :current_user<br><br>&nbsp; private<br>&nbsp; def current_user<br>&nbsp; &nbsp; @current_user ||= User.find(session[:user_id]) if session[:user_id]<br>&nbsp; end<br>end</p>
</blockquote>
<p>edit app/views/layout/application.html.erb :</p>
<blockquote>
<p>&lt;% if current_user %&gt;<br>&nbsp; &lt;%= current_user.name %&gt; &lt;%= link_to 'ログアウト', logout_path %&gt;<br>&lt;% else %&gt;<br>&nbsp; &lt;%= link_to 'ログイン', '/auth/twitter' %&gt;<br>&nbsp; &lt;%= link_to 'ログイン', '/auth/facebook' %&gt;<br>&lt;% end %&gt;&nbsp;</p>
</blockquote>
<p><br>make session controller :&nbsp;</p>
<blockquote>
<p>rails g controller sessions</p>
</blockquote>
<p><br>app/controllers/sessions_controller.rb :&nbsp;</p>
<blockquote>
<p>class SessionsController &lt; ApplicationController<br>&nbsp; def create &nbsp;<br>&nbsp; &nbsp; #omniauth.auth環境変数を取得<br>&nbsp; &nbsp; auth = request.env["omniauth.auth"]<br>&nbsp; &nbsp; #Userモデルを検索<br>&nbsp; &nbsp; user = User.find_by_provider_and_uid(auth["provider"], auth["uid"]) || User.create_with_omniauth(auth)<br><br>&nbsp; &nbsp; session[:user_id] = user.id<br>&nbsp; &nbsp;&nbsp;logger.debug auth.to_yaml<br>&nbsp; &nbsp; redirect_to root_url, :notice =&gt; "Signed in!"<br>&nbsp; end<br><br><br>&nbsp; def destroy<br>&nbsp; &nbsp; session[:user_id] = nil<br>&nbsp; &nbsp; redirect_to root_url, :notice =&gt;"Log out"<br>&nbsp; end<br>end</p>
</blockquote>
<p><br>make db :&nbsp;</p>
<blockquote>
<p>$ rails g scaffold user provider:string uid:string screen_name:string name:string<br>$ rake db:migrate</p>
</blockquote>
<p><br>app/models/user.rb :&nbsp;</p>
<blockquote>
<p>class User &lt; ActiveRecord::Base<br>&nbsp; def self.create_with_omniauth(auth)<br>&nbsp; &nbsp; create! do |user|<br>&nbsp; &nbsp; &nbsp; user.provider = auth['provider']<br>&nbsp; &nbsp; &nbsp; user.uid = auth['uid']<br>&nbsp; &nbsp; &nbsp; user.screen_name = auth['info']['nickname']<br>&nbsp; &nbsp; &nbsp; user.name = auth['info']['name']<br>&nbsp; &nbsp; end<br>&nbsp; end<br>end</p>
</blockquote>
<p><br>config/routes.rb :</p>
<blockquote>
<p>+ resources :users<br><br>-&nbsp;# root :to =&gt; 'welcome#index'<br>+ root :to =&gt; 'users#index'<br><br>+ match '/auth/:provider/callback', :to =&gt; 'sessions#create'<br>+ match '/logout' =&gt; 'sessions#destroy', :as =&gt; :logout</p>
</blockquote>
<p>remove public/index.html</p>
<blockquote>
<p>$ rm public/index.html</p>
</blockquote>
<p>test as local :</p>
<blockquote>
<p>$ rake routes<br>$ rails server&nbsp;</p>
</blockquote>

<p>git で作る</p>
<blockquote>
<p>$ git init<br>$ git add .<br>$ git commit -m "git init"<br><br>$ heroku &nbsp;</p>
</blockquote>
<p>参考</p>
<blockquote>
<p>http://ja.asciicasts.com/episodes/241-simple-omniauth<br>http://d.hatena.ne.jp/kaorumori/20111113/1321155791<br>http://npb.somewhatgood.com/blog/archives/715</p>
<p>twitterについての参照<br>https://github.com/arunagw/omniauth-twitter</p>
<p>Facebookについての参照<br>https://github.com/mkdynamic/omniauth-facebook</p>
</blockquote>