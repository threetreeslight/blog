+++
date = "2012-08-10T09:07:00+00:00"
draft = false
tags = ["rails", "javascript", "assets", "include"]
title = "[rails][javascript][assets]javascriptファイルのinclude"
+++
<p>railsで独自のjavascriptファイルを読み込ませたい事が有る。</p>&#13;
<p>このとき、"&lt;%= javascript_include_tag "application" %&gt;"を使うのはイケテナイ。</p>&#13;
<p>理由としては、ソースコードの管理が煩雑になるし、assets pieplineで一本のjsファイルにまとめるという本領を発揮できないから（多分）<br /><br />例えば、jsのライブラリをどっかに置きたい時は以下のようにする。</p>&#13;
<p>put file : <br />vender/asests/hogehoge.js</p>&#13;
<p>application.js : </p>&#13;
<pre><code>#= require hogehoge.js</code></pre>&#13;
<p><br />参考<br /><a href=" http://guides.rubyonrails.org/asset_pipeline.html"> http://guides.rubyonrails.org/asset_pipeline.html</a></p> 