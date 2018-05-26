+++
date = "2012-05-24T06:19:46+00:00"
draft = false
tags = ["rails", "routes"]
title = "controllerのメソッド追加した際にroutesの編集をお忘れなく"
+++
<p>controllerでメソッド追加すると「no routes matches」とか良く出る。</p>&#13;
<p>この時は大体 config/routes.rbに設定が漏れている。</p>&#13;
&#13;
<p>ex)</p>&#13;
<p>コントローラー作る: </p>&#13;
<p>$ rails g controller Post index</p>&#13;
<p><br />views/post/index.html.rbにフォームタグ使って飛ばそうとする : </p>&#13;
<p>&lt;% form_tag :action =&gt; "twitter" %&gt; <br />  ごにゃごにゃ<br />&lt;% end %&gt;</p>&#13;
<p><br />PostController.rbに処理内容を記述 :</p>&#13;
<p>def twitter<br />  ごにゃごにゃ<br />end</p>&#13;
<p><br /><br />ここのまま表示しようとするとroutes周りでエラー。これはroutesを以下で解決。</p>&#13;
<p><br />edit config/route.rb : </p>&#13;
<p>get "post/twitter"</p>&#13;
&#13;
 