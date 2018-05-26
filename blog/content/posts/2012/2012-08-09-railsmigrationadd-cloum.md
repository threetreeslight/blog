+++
date = "2012-08-09T13:04:01+00:00"
draft = false
tags = ["rails", "migration", "defalut"]
title = "[rails][migration]add cloumしたときの初期値の適用"
+++
<p>add cloumしたけど、初期値が既存レコードに適用されないという事象は多々有る。</p>&#13;
<p>えっ？sql叩くの？っていうのはやっぱrails的にはいけてないだろう。</p>&#13;
<p>そういうときに、を利用すると便利便利。</p>&#13;
<p> update.all(["<em>clum_name</em>=?","<em>default_value</em>"])</p>&#13;
&#13;
&#13;
<p>参考</p>&#13;
<p><a href="http://blogs.yahoo.co.jp/katashiyo515/676404.html">http://blogs.yahoo.co.jp/katashiyo515/676404.html</a></p> 