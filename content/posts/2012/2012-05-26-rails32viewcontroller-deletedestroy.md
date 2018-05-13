+++
date = "2012-05-26T12:22:27+00:00"
draft = false
tags = ["rails", "controller"]
title = "[rails3.2][view][controller] deleteメソッド呼ぶとdestroyメソッド実行される"
+++
<p>ActiveRecodeを介して削除するのがdestroy</p>&#13;
&#13;
<p>下記のように削除リンクを追加したとき、<br />&lt;%= link_to 'hoge', post' , :method =&gt; :delete %&gt;</p>&#13;
<p>controllerで呼び出されるのは、以下のメソッド<br />def destroy<br />end </p>&#13;
<p>rake routesを読むと下記の通り。<br />          DELETE /posts/:id(.:format)      posts#destroy</p>&#13;
<p><br />つまり、deleteメソッドに対してposts#destroyメソッドへroutingされているという認識なのだろうか？</p>&#13;
<p>ふーむ。</p>&#13;
&#13;
<p>参考：<br />http://d.hatena.ne.jp/POCHI_BLACK/20101026</p> 