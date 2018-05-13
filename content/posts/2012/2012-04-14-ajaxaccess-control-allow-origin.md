+++
date = "2012-04-14T15:45:04+00:00"
draft = false
tags = ["ajax", "jqm", "jquery"]
title = "ajaxで\"Access-Control-Allow-Origin\"って怒られる"
+++
<p>ajaxで"Access-Control-Allow-Origin"って怒られる。</p>&#13;
<p><span>same origin policyってことらしい。</span><span>つまりAPIとajaxでやりとりは殆ど使えなくね？ってことじゃない？</span></p>&#13;
<blockquote>&#13;
<p>詳細<br /><a href="http://www.muratayusuke.com/2011/05/28/access-control-allow-origin/">http://www.muratayusuke.com/2011/05/28/access-control-allow-origin/</a> </p>&#13;
</blockquote>&#13;
<p>いやなので調べるとjsonpなら対応可能との事。<br /><br /> </p>&#13;
<p>なんでjsonだとダメで、jsonpだと大丈夫なのか。<br />要はパラを全部隠して（埋め込んで）、受け取るのをコールバック関数で処理する事で、URLからごちゃごちゃされるのを防いでいるってことなのかな？</p>&#13;
<p><br />とりあえず</p>&#13;
<blockquote>&#13;
<p>○：ホットペッパー</p>&#13;
<p>×：ぐるなび</p>&#13;
<p>×：食べログ </p>&#13;
</blockquote>&#13;
&#13;
<p>ぐるなび食べログの試験はサーバーサイド組むか。</p>&#13;
 