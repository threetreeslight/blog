+++
date = "2012-04-08T11:44:31+00:00"
draft = false
tags = ["ror", "rails", "imageMagic"]
title = "image magickインストール時にこける"
+++
<p>作って頂いたapiをローカルで動かそうとすると「イメージマジックインスコするよろし」と怒られる。</p>&#13;
&#13;
<p>とりあえずimage magickをhome brewでインストールしようとしたらこけた。</p>&#13;
<blockquote>&#13;
<p>SHA1 mismatch</p>&#13;
</blockquote>&#13;
<p>調べてみたことろ、どうやらhomebrewをupdate すればいいらしい。</p>&#13;
<blockquote>&#13;
<p>$ brew update</p>&#13;
<p>$ brew -v</p>&#13;
<p>$ brew install ImageMagick</p>&#13;
</blockquote>&#13;
<p>xcodeをupdしろとか、mac portsにインスコされてんじゃないのとか怒られているけど気にしない。</p>&#13;
<p>通ったっぽい。</p>&#13;
<blockquote>&#13;
<p>$ brew list</p>&#13;
</blockquote>&#13;
<p>imagemagickが居るので大丈夫だろう。</p>&#13;
<p>とりあえずメモ。</p> 