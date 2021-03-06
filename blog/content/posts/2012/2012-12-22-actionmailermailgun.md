+++
date = "2012-12-22T01:35:00+00:00"
draft = false
tags = ["ActionMailer", "mailgun", "gmail", "SMTP"]
title = "[ActionMailer]mailgunの設定"
+++
<p>ActionMailerにおけるmailgun設定をメモ</p>&#13;
<p><strong>1. mailer generate</strong></p>&#13;
<pre>$ rails g mailer ApplicationMailer mailtest&#13;
</pre>&#13;
<p><strong><br />2. gmailでテスト</strong></p>&#13;
<p>メール設定</p>&#13;
<pre>application.rb&#13;
&#13;
# mailer&#13;
config.action_mailer.delivery_method = :smtp&#13;
config.action_mailer.smtp_settings = {&#13;
  :address              =&gt; "smtp.gmail.com",&#13;
  :domain               =&gt; 'gmail.com',&#13;
  :port                 =&gt; 587,&#13;
  :user_name            =&gt; 'hoge@gmail.com',&#13;
  :password             =&gt; 'hogehoge',&#13;
  :authentication       =&gt; 'plain',&#13;
  :enable_starttls_auto =&gt; true&#13;
}&#13;
&#13;
</pre>&#13;
<p><br />ApplicationMailerのメソッド</p>&#13;
<pre>class ApplicationMailer &lt; ActionMailer::Base&#13;
  def mailtest&#13;
    mail( :subject     =&gt; "It's work!",&#13;
          :from        =&gt; 'hoge@gmail.com',&#13;
          :return_path =&gt; 'hoge@gmail.com',&#13;
          :to          =&gt; 'hoge@gmail.com' )&#13;
  end&#13;
end&#13;
</pre>&#13;
<p><br />コマンドライン上でテスト</p>&#13;
<pre>$ rails c&#13;
&gt; mail = ApplicationMailer.testmail&#13;
&gt; mail.transport_encoding = "8bit"&#13;
&gt; mail.deliver&#13;
</pre>&#13;
<p>届いた。</p>&#13;
<p><br /><br /><strong>3. mailgun設定</strong></p>&#13;
<p>アカウントを取得</p>&#13;
<ul><li>https://mailgun.net/cp</li>&#13;
</ul><p><br />application.rbへ設定</p>&#13;
<pre># mailer&#13;
config.action_mailer.delivery_method = :smtp&#13;
config.action_mailer.default_charset = "utf-8"&#13;
config.action_mailer.perform_deliveries = true&#13;
config.action_mailer.raise_delivery_errors = true&#13;
config.action_mailer.smtp_settings = {&#13;
  :authentication =&gt; :plain,&#13;
  :address        =&gt; "smtp.mailgun.org",&#13;
  :port           =&gt; 587,&#13;
  :domain         =&gt; "hoge.mailgun.org",&#13;
  :user_name      =&gt; "hoge@gmail.com",&#13;
  :password       =&gt; "foobar"&#13;
}&#13;
</pre>&#13;
<p>http://documentation.mailgun.net/quickstart.html</p>&#13;
&#13;
&#13;
<p>コマンドライン上でテスト</p>&#13;
<pre>$ rails c&#13;
&gt; mail = ApplicationMailer.testmail&#13;
&gt; mail.deliver&#13;
</pre>&#13;
<p>何か間違えているっぽい</p>&#13;
&#13;
<p><br /><br /><strong>4. mailgun-rails gemを使ってHTTPでやる</strong></p>&#13;
<pre>Gemfile&#13;
+ gem 'mailgun-rails'&#13;
&#13;
$ bundle install&#13;
&#13;
$ vim ./config/application.rb&#13;
&#13;
- config.action_mailer.delivery_method = :smtp&#13;
&#13;
config.action_mailer.delivery_method = :mailgun&#13;
config.action_mailer.mailgun_settings = {&#13;
    :api_key  =&gt; "key-hogehogehogehoge",&#13;
    :api_host =&gt; "hoge.mailgun.org"&#13;
}&#13;
</pre>&#13;
<p><strong>コマンドライン上でテスト</strong></p>&#13;
<pre>$ rails c&#13;
&gt; mail = ApplicationMailer.mailtest&#13;
&gt; mail.deliver&#13;
</pre>&#13;
<p>動いた</p>&#13;
<p><br /><br /><strong>P.S. On heroku</strong></p>&#13;
<p>herokuだとmailgunのaddonで直ぐ出来る。</p>&#13;
<pre>$ heroku addons:add mailgun:free&#13;
application.rb&#13;
&#13;
ActionMailer::Base.smtp_settings = {&#13;
  :port           =&gt; ENV['MAILGUN_SMTP_PORT'],&#13;
  :address        =&gt; ENV['MAILGUN_SMTP_SERVER'],&#13;
  :user_name      =&gt; ENV['MAILGUN_SMTP_LOGIN'],&#13;
  :password       =&gt; ENV['MAILGUN_SMTP_PASSWORD'],&#13;
  :domain         =&gt; 'yourapp.heroku.com',&#13;
  :authentication =&gt; :plain,&#13;
}&#13;
ActionMailer::Base.delivery_method = :smtp&#13;
&#13;
https://devcenter.heroku.com/articles/mailgun&#13;
</pre> 