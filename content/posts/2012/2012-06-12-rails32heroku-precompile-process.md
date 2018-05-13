+++
date = "2012-06-12T14:35:00+00:00"
draft = false
tags = ["rails", "heroku", "precompile", "deploy"]
title = "[rails3.2][heroku] precompile processでこける"
+++
<p>こんな感じで怒られる。</p>&#13;
<p>昨日の大阪出張中に書いたコードが原因なのかやたらとこける。<br /><br /> </p>&#13;
<blockquote>&#13;
<p>-----&gt; Preparing app for Rails asset pipeline</p>&#13;
<p>       Running: rake assets:precompile</p>&#13;
<p>       rake aborted!</p>&#13;
<p>       could not connect to server: Connection refused</p>&#13;
<p>       Is the server running on host "127.0.0.1" and accepting</p>&#13;
<p>       TCP/IP connections on port 5432?</p>&#13;
<p>       Tasks: TOP =&gt; environment</p>&#13;
<p>       (See full trace by running task with --trace)</p>&#13;
<p>       Precompiling assets failed, enabling runtime asset compilation</p>&#13;
<p>       Injecting rails31_enable_runtime_asset_compilation</p>&#13;
<p>       Please see this article for troubleshooting help:</p>&#13;
<p>       http://devcenter.heroku.com/articles/rails31_heroku_cedar#troubleshooting</p>&#13;
</blockquote>&#13;
<p><br /><br />原因（本当は良くわからないが、大体読むと同じ事が書いてある）：</p>&#13;
<p><span>The issue was rails was trying to connect to the database during the precompile process, and heroku is setup not to allow that. I am guessing that this issue is due to a change in the rails initialization setup in rails 3.2.</span></p>&#13;
<p>参考：</p>&#13;
<p><a href="https://devcenter.heroku.com/articles/rails3x-asset-pipeline-cedar">https://devcenter.heroku.com/articles/rails3x-asset-pipeline-cedar</a></p>&#13;
<p><a href="http://www.simonecarletti.com/blog/2012/02/heroku-and-rails-3-2-assetprecompile-error/">http://www.simonecarletti.com/blog/2012/02/heroku-and-rails-3-2-assetprecompile-error/</a></p>&#13;
<p><a href="http://blog.nathanhumbert.com/2012/01/rails-32-on-heroku-tip.html">http://blog.nathanhumbert.com/2012/01/rails-32-on-heroku-tip.html</a></p>&#13;
<p><br /><br /><br /><br />追記（解決策）：</p>&#13;
<p class="p1">If you set config.assets.initialize_on_precompile to false, be sure to test rake assets:precompile locally before deploying. It may expose bugs where your assets reference application objects or methods, since those are still in scope in development mode regardless of the value of this flag.</p>&#13;
<p class="p1">要はgemによって影響が出るので、ローカルでprecompileしてねって事らしい。というわけで以下のコマンドをローカルで叩くべし。</p>&#13;
<p class="p1">$ bundle exec rake assets:precompile<br />$ git add .<br />$ git commit -a -m "precompile local" </p>&#13;
<p class="p1"><br />すると通るが、別の問題が有でてきた。これは後ほど。</p>&#13;
<p class="p1">参考：<br /><a href="http://guides.rubyonrails.org/asset_pipeline.html">http://guides.rubyonrails.org/asset_pipeline.html</a> </p> 