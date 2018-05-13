+++
date = "2012-08-05T16:36:00+00:00"
draft = false
tags = ["rails", "controller", "host"]
title = "[rails][controller]controller内でのhost名の取得方法"
+++
<p>controllerでhost名を取得する方法は難しい。</p>&#13;
<p>なぜかというとrequireを使えないからだ。しかし環境によってhost名は変わるもの。</p>&#13;
<p><br />そういう時は、もう定数だ。</p>&#13;
<blockquote>&#13;
<p>initialize/host.rb</p>&#13;
<p>if Rails.env.production?<br />  ENV['HOST'] = 'production.hogehoge.com'</p>&#13;
<p>elsif Rails.env.development?<br />  ENV['HOST'] = 'development.hogehoge.com'</p>&#13;
<p>elsif Rails.env.localhost? <br />  ENV['HOST'] = 'local.hogehoge.com'</p>&#13;
<p>end</p>&#13;
</blockquote> 