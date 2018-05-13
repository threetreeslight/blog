+++
date = "2012-07-17T12:19:07+00:00"
draft = false
tags = ["gem", "heroku", "bundler"]
title = "[heroku][bundler]bundler1.2系に更新したら怒られた事"
+++
<p>記事ポイント</p>&#13;
<ul><li>bundler1.2系へアップデートする事をherokuから求められる</li>&#13;
<li>less-bootstrap-railsがbundler1.0系に依存している？</li>&#13;
<li>vendor/bundle配下とgemfile.lockを消すだけでbundle installをリフレッシュできなくなってる。</li>&#13;
</ul><p><br />gemの変更とかgemfile.lockとbundle/vendor配下がっつり消してただけでなんとかなってたんだ。前までは・・・</p>&#13;
<p><br />事の発端はherokuがbundler 1.2 preを入れないと受け付けないもんね！って言われた事になる。 </p>&#13;
<blockquote>&#13;
<p>errorはこんな感じ</p>&#13;
<p><span>undefined method `ruby' for #&lt;Bundler::Dsl:0x0000000250acb0&gt; (NoMethodError)</span> </p>&#13;
</blockquote>&#13;
<p><br />devcenterに解決策はもちろん書いてある（ここの一番した）<br /><a href="https://devcenter.heroku.com/articles/ruby-versions">https://devcenter.heroku.com/articles/ruby-versions</a></p>&#13;
<p><br />さて、ここまではよしよし。でも怒られる。</p>&#13;
<blockquote>&#13;
<p>error内容：<br />less-twitterbottstrap-railsの残骸が残っているよGemlockファイルにって。。。</p>&#13;
</blockquote>&#13;
<p><br />分かったよー消すよーって、gemfile.lockとvendor/bundle配下を削除し、bundle install --path vendor/bundleしたら怒られるのなんの</p>&#13;
<blockquote>&#13;
<p>error : <br />You are trying to install in deployment mode after changing<br />your Gemfile. Run `bundle install` elsewhere and add the<br />updated Gemfile.lock to version control.</p>&#13;
<p>If this is a development machine, remove the Gemfile freeze <br />by running `bundle install --no-deployment`.</p>&#13;
</blockquote>&#13;
<p><br />へーGemfile.lockにバージョンコントロールなんてあるのね？って思いながら。<br />力づく系コマンドを打つ。</p>&#13;
<blockquote>&#13;
<p>$ bundle install --no-deployment --path vendor/bundle</p>&#13;
</blockquote>&#13;
<p><br />bundle install通った。<br />そして、こんな内容が出てきた。</p>&#13;
<blockquote>&#13;
<p>Your bundle is complete! It was installed into ./vendor/bundle</p>&#13;
<p>Post-install message from rdoc:<br />Depending on your version of ruby, you may need to install ruby rdoc/ri data:</p>&#13;
<p>&lt;= 1.8.6 : unsupported<br /> = 1.8.7 : gem install rdoc-data; rdoc-data --install<br /> = 1.9.1 : gem install rdoc-data; rdoc-data --install<br />&gt;= 1.9.2 : nothing to do! Yay!</p>&#13;
<p>Post-install message from heroku:<br /> !    Heroku recommends using the Heroku Toolbelt to install the CLI.<br /> !    Download it from: https://toolbelt.heroku.com</p>&#13;
</blockquote>&#13;
<p>続きは今度。 </p>&#13;
 