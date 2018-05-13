+++
date = "2012-04-15T01:58:59+00:00"
draft = false
tags = ["jquery", "jqm", "css"]
title = "jqmで.contentや.ui-block-aのwidthが取得できない"
+++
<p>jqmで.contentや.ui-block-aのwidthが取得できない</p>&#13;
<p>jquery mobileを利用しているときに、.ui-lock-aクラスをdivにおけるwidthを利用して画像のサイズを変更するコードを以前書いたのだが、何か変だ。</p>&#13;
<blockquote>&#13;
<p>以下みたいな感じ。</p>&#13;
<p>$("img").width($(".ui-block-a").width())</p>&#13;
</blockquote>&#13;
<p><br />とりあえずバシバシコンソールログをはきまくってみると以下の通り。</p>&#13;
<blockquote>&#13;
<p>&lt;対象ページ読み込み時(init時)&gt;<br />.ui-block-a : 正しい</p>&#13;
<p>&lt;pageshow、pagebeforeshow&gt;</p>&#13;
<p>.ui-block-a : 小さい値が表示される。 </p>&#13;
<p>.content : 0になる。</p>&#13;
</blockquote>&#13;
<p>jqmが読み込むときふにゃふにゃしているのだろう。<br />これだからブラックボックスは(ry</p>&#13;
<p><br />%で設定すると上手く行く。が、%は使いたくない理由は以下の通り。</p>&#13;
<blockquote>&#13;
<p>前提条件<br />・imgをdraggable要素として扱う。(jquery ui利用）<br />・cloneする<br />・cloneする画像サイズが実際の表示画面に対する%として適用されてしまう。 <br />-&gt;cloneする画像めっちゃでか！ってなる。</p>&#13;
</blockquote>&#13;
<p><br />もうこれはしょうがないので、windowサイズから算出して対応する事にした。</p>&#13;
 