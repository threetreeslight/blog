+++
date = "2012-05-26T11:32:00+00:00"
draft = false
tags = ["rails", "routes"]
title = "[rails3.2][routes] posts_pathとpost_path"
+++
<p>一瞬間違えたので、気をつけておきたい。</p>&#13;
<p>config/routes.rb : <br />resources :posts</p>&#13;
<p><br />&lt;%= link_to 'hoge',  posts_path %&gt;<br />-&gt;  Posts#indexへrouting</p>&#13;
<p><br /><br />&lt;%= link_to 'hoge', post_path %&gt; <br />-&gt; Posts#showへrouting</p> 