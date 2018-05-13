+++
date = "2012-09-18T09:30:00+00:00"
draft = false
tags = ["rails", "scss", "sass", "less", "css"]
title = "[rails][scss][less]cssファイルの読み込み順序"
+++
<p>railsでcssの読み込み順序を制御したい場合、以下の内容を削除し、明示的に各々インポートする必要が有る。</p>&#13;
<pre>- //require_tree .<br />+ @import "foo"&#13;
+ @import "bar"&#13;
+ @import "hoge"&#13;
</pre>&#13;
<blockquote>&#13;
<p>参考<br /><a href="http://railscasts.com/episodes/268-sass-basics?language=ja&amp;view=asciicast">#268 Sass Basics</a></p>&#13;
</blockquote>&#13;
<p><br />そもそも何でこんな事をする必要が合ったかというと、</p>&#13;
<ol><li>vendor配下にlessのtwitter bootstrapを入れておいて、application.css.scss.erbでtwitter bootstrapのcssを上書きしていた。</li>&#13;
<li>anywarefontに適応している事も有り、twitter-bootstrap-less gemを導入する。</li>&#13;
<li>bootstrap_and_overrides.css.lessが生成。</li>&#13;
<li>applicaton.css.scss.erbの上書きが3の項目で上書きされる。南無三ッ！！</li>&#13;
</ol><div>となってしまったため。<br />実際に行った対処としては、application.css.scss.erbでtwitter bootstrapのoverrideをせず、専用のscssファイルを用意し、各scssファイル上でimportするようにしました。</div>&#13;
<div></div> 