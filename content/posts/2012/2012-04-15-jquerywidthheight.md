+++
date = "2012-04-15T07:41:15+00:00"
draft = false
tags = ["jquery", "jqm", "css"]
title = "jqueryで何度も画像のwidth,heightを弄る時の注意"
+++
<p>やろうとしている事</p>&#13;
<blockquote>&#13;
<p>・契機はhtmlのinit時とpagebeforeshowなど<br />・ 画像サイズをwidth, height弄る</p>&#13;
</blockquote>&#13;
&#13;
<p>事象</p>&#13;
<blockquote>・initialize時はちゃんと調整できる。<br />・２回目以降$(jqueryオブジェクト).width() or height()が０になる事がある。</blockquote>&#13;
<p>原因</p>&#13;
<blockquote>&#13;
<p>widthもしくはheight片方でも値が入っていた場合、値がセットされていない方の値は０として認識されてしまう。</p>&#13;
<p>例）画像サイズ200px x 200pxを使う</p>&#13;
<p>・ロード前<br />200px x 200px(css無指定、デフォルトサイズのまま）</p>&#13;
<p>・initialize<br />同一サイズと認識し、widthに200pxを代入</p>&#13;
<p>・2回目以降<br />サイズをチェックするとheightに値が入っていないため、width200px x height0pxと認識する。</p>&#13;
</blockquote>&#13;
&#13;
<p>気をつけた方が良い。</p> 