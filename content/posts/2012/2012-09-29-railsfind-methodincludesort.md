+++
date = "2012-09-29T10:35:06+00:00"
draft = false
tags = ["include", "sort", "rails", "find"]
title = "[rails]find methodにてincludeしたオブジェクトのsort"
+++
<p>大した話ではないけれど、find methodはincludeするとorderをチェイン出来なくなる模様。</p>&#13;
<pre>&gt; @posts = Garage.find(:all, :include =&gt; :comment).order('posts.updated_at DESC')&#13;
NoMethodError: undefined method `order' for #&#13;
</pre>&#13;
<p><br />なのでfind methodの中にくるむと通る。</p>&#13;
<pre>&gt; @posts = Garage.find(:all, :include =&gt; : comment, :order =&gt; 'posts.updated_at DESC')<br />通る</pre>&#13;
<p><br />あんまし調べてないけど、そういうもんなんだね。</p> 