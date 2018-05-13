+++
date = "2012-08-20T16:47:00+00:00"
draft = false
tags = ["rails", "csrf"]
title = "[rails][CSRF]CSRFタグの埋め込みをオフにする"
+++
<p>railsで試しにpublicディレクトリのファイルからjsonでほにゃほにゃやろうとすると、CSRFがないからダメって怒られる。</p>&#13;
<p><br />いちいち追加するのもめんどくさい（本来遣るべきなんだろうけど）</p>&#13;
<p>手っ取り早くテストする方法として、以下の内容をコントローラーに追記する事でオフに出来る。</p>&#13;
<pre>protect_from_forgery :except =&gt; :create &#13;
</pre>&#13;
<p>参考<a><br />http://stackoverflow.com/questions/5669322/turn-off-csrf-token-in-rails-3</a></p> 