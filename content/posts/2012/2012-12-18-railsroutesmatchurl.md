+++
date = "2012-12-18T09:29:31+00:00"
draft = false
tags = ["rails", "routes", "match", "path", "via"]
title = "[rails][routes]matchのメソッド指定やurlの変換"
+++
<p>match で取ってくるとき、get か postのメソッドを指定して挙げたい場合</p>&#13;
<pre>match "hoge/" =&gt; "hoge#index", :via =&gt; :get&#13;
</pre>&#13;
&#13;
<p>resourcesの表示URLを置き換えたい場合</p>&#13;
<p>例 /user/hogehoge =&gt; /hogehoge</p>&#13;
<pre>resources :user, :path =&gt; "foo"&#13;
</pre>&#13;
 