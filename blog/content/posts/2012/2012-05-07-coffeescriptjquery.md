+++
date = "2012-05-07T12:59:43+00:00"
draft = false
tags = ["coffee script", "jquery"]
title = "CoffeeScriptとjqueryでこんなに短縮化できる"
+++
<p>画像をクリックしたら、同じdiv要素内のsubmitを動かす</p>&#13;
<p>・coffeeScript + jQuery</p>&#13;
<blockquote>&#13;
<p>$ -&gt;<br />  $("img").click -&gt;<br />    $(this).parent().find(":submit").click() </p>&#13;
</blockquote>&#13;
<p>・jQuery</p>&#13;
<blockquote>&#13;
<p>こんな感じなのかな？<br />$.ready(function(){<br />  $("img").click(function(e){<br />    $(this).parent().find(":submit").click()<br />  })<br />})<br /> </p>&#13;
</blockquote>&#13;
<p>すごい簡単な例だけど、非常に楽だ。</p> 