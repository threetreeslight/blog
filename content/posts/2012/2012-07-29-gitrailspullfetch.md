+++
date = "2012-07-29T06:29:00+00:00"
draft = false
tags = ["git", "rails"]
title = "[git][rails]pullよりfetchしたいので手順をメモ"
+++
<p>pull = fetch + margeという事だけど、ちゃんとdiffってからやるべきなのではないかと思い始めたので、fetchを利用する方法をメモしておく。</p>&#13;
<p><br /><br /></p>&#13;
<p>最新バージョンのソースをフェッチ</p>&#13;
<blockquote>&#13;
<p>$ git fetch git@hogehoge master</p>&#13;
</blockquote>&#13;
<p>マージ</p>&#13;
<blockquote>&#13;
<p>$ git marge FETCH_HEAD</p>&#13;
</blockquote>&#13;
<p>比較確認</p>&#13;
<blockquote>&#13;
<p>$ git diff FETCH_HEAD</p>&#13;
</blockquote>&#13;
&#13;
&#13;
<p><br />参考：</p>&#13;
<p><a href="http://d.hatena.ne.jp/murank/20110320/1300619118">http://d.hatena.ne.jp/murank/20110320/1300619118</a></p>&#13;
 