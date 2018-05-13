+++
date = "2012-09-19T05:22:59+00:00"
draft = false
tags = ["rails", "jquery", "jquery-ui", "gem"]
title = "[rails]jquery-uiの利用方法"
+++
<p><a href="https://github.com/indirect/jquery-rails">jquery-rails</a> gemにて、jquery-uiのjsを読み込めばok。</p>&#13;
<p>利用する場合は以下の記述を追加</p>&#13;
<pre>application.js.coffee :&#13;
&#13;
+ //= require jquery-ui&#13;
&#13;
<br />if use application.js.coffee.erb :&#13;
&#13;
+ #= require jquery-ui&#13;
</pre>&#13;
<p><br />また、jquery-rails gemに有る通り、jquery-uiのjsファイルは assets piplineを通したときにしか利用出来ないよって成っている。（assets pipline disable時の利用）</p>&#13;
<blockquote>&#13;
<p><span>Rails 3.1 or greater (with asset pipeline</span><span> </span><em>enabled</em><span>)</span></p>&#13;
<p><span></span><span>The jquery and jquery-ujs files will be added to the asset pipeline and available for you to use. If they're not already in</span><code>app/assets/javascripts/application.js</code><span> </span><span>by default, add these lines:</span><span></span></p>&#13;
</blockquote>&#13;
<p><br />というわけで、assets precompileを走らせて完了。</p>&#13;
<pre>$ rake assets:precompile</pre>&#13;
<p><br />これでok。</p>&#13;
<p><br />また、jquery-uiのテーマなどcss周りを使いたいのなら、<a href="https://github.com/joliss/jquery-ui-rails">jquery-ui-rails</a>を利用する事をjquery-ui gemは推奨しています。</p>&#13;
 