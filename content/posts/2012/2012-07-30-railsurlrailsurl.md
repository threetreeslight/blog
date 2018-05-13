+++
date = "2012-07-30T17:04:00+00:00"
draft = false
tags = ["rails", "url", "SEO", "OGP"]
title = "[rails][url]rails現在のurlを取得する方法"
+++
<p>システム上にOGPを設定するときに、現在のurlを取得した時が有る。</p>&#13;
<p>url_forを利用する方法やcontents_forを利用して制御する方法はあるものの、面倒だしいけてないよね。</p>&#13;
<p>そういうときにはコレを使うと直ぐ取得できる。</p>&#13;
<blockquote>&#13;
<p><span>http://#{request.host}:#{request.port.to_s + request.fullpath}</span></p>&#13;
<p><span>request_urlは今後のバージョンで排除される可能性があるので、利用しないようにしましょう</span></p>&#13;
</blockquote>&#13;
<p><br />参考：<br /><a href="http://stackoverflow.com/questions/2165665/how-to-get-current-url-in-rails">http://stackoverflow.com/questions/2165665/how-to-get-current-url-in-rails</a></p>&#13;
&#13;
<p><br />※追記</p>&#13;
<p><span>以下の通りらしい。</span></p>&#13;
<p><span>Do it in Rails, not via javascript. Search Engines will not execute your javascript.</span></p>&#13;
<p>参考<br /><a href="http://stackoverflow.com/questions/6203870/how-to-get-automatically-meta-description-and-keywords-in-rails">http://stackoverflow.com/questions/6203870/how-to-get-automatically-meta-description-and-keywords-in-rails</a> </p> 