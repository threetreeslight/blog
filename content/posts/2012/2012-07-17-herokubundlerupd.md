+++
date = "2012-07-17T12:36:26+00:00"
draft = false
tags = ["bundler", "heroku"]
title = "[heroku]bundlerをupdしてもだめだった。"
+++
<p>bundler 1.2系に更新してbundle installしたところから</p>&#13;
<blockquote>&#13;
<p>Your bundle is complete! It was installed into ./vendor/bundle</p>&#13;
<p>Post-install message from rdoc:<br />Depending on your version of ruby, you may need to install ruby rdoc/ri data:</p>&#13;
<p>&lt;= 1.8.6 : unsupported<br /> = 1.8.7 : gem install rdoc-data; rdoc-data --install<br /> = 1.9.1 : gem install rdoc-data; rdoc-data --install<br />&gt;= 1.9.2 : nothing to do! Yay!</p>&#13;
<p>Post-install message from heroku:<br />!    Heroku recommends using the Heroku Toolbelt to install the CLI.<br />!    Download it from: https://toolbelt.heroku.com </p>&#13;
&#13;
</blockquote>&#13;
<p>良く読んだら、"nothing to do! Yay!" だった Yay !</p>&#13;
&#13;
<p>でもだめだった。。。</p>&#13;
<blockquote>&#13;
<p>$ git push heroku master</p>&#13;
<p>-----&gt; Installing dependencies using Bundler version 1.2.0.pre</p>&#13;
<p>       Running: bundle install --without development:test --path vendor/bundle --binstubs bin/ --deployment<br />       You are trying to install in deployment mode after changing<br />       your Gemfile. Run `bundle install` elsewhere and add the<br />       updated Gemfile.lock to version control.<br />       You have deleted from the Gemfile:<br />       * less-rails-bootstrap</p>&#13;
<p> !<br /> !     Failed to install gems via Bundler.<br /> !<br /> !     Heroku push rejected, failed to compile Ruby/rails app</p>&#13;
<div></div>&#13;
</blockquote>&#13;
<div>助けてドラえもん！と思ってstackflowを探すと出るわ。</div>&#13;
<div></div>&#13;
<div>&#13;
<blockquote>&#13;
<p>The instructions are probably a bit confusing. It's saying that you've modified your <code>Gemfile</code> on your development machine and just pushed those changes rather than running <code>bundle install</code> BEFORE committing the changes.</p>&#13;
<p>「ちょっと混乱しやすいけど、変更をちゃんとコミットしないとダメだよ。」的な？</p>&#13;
</blockquote>&#13;
</div>&#13;
<div></div>&#13;
<div>なんだ、そういう事だったのかと納得。</div>&#13;
<div></div>&#13;
<blockquote>&#13;
<div>$ git add .<br />$ git commit -a -m "update Gemfile.lock"<br />$ git push heroku master </div>&#13;
</blockquote>&#13;
<div>通った。</div>&#13;
<div></div>&#13;
<div></div>&#13;
<div>参照：</div>&#13;
<div><a href="http://stackoverflow.com/questions/6785626/unable-to-update-gems-on-production-server">http://stackoverflow.com/questions/6785626/unable-to-update-gems-on-production-server</a></div> 