+++
date = "2012-11-22T04:39:34+00:00"
draft = false
tags = ["heroku", "toolbelt", "uninstall"]
title = "[heroku]heroku toolbeltのuninstall"
+++
<p>heroku toolbeltがバグってしまった。どう治すべきかも分からないのでとりあえず消そうと思う。</p>&#13;
<p>削除手順は以下のとおり。<br /> </p>&#13;
<pre>$ rm -rf /usr/local/heroku&#13;
# rm -rf /usr/bin/heroku&#13;
&#13;
herokuの複数ログインを使っている場合は以下も削除&#13;
$ rm -rf ~/.heroku</pre>&#13;
<p><br />参考：<br /><a href="http://johntwang.com/blog/2011/09/13/remove-heroku-toolkit/">http://johntwang.com/blog/2011/09/13/remove-heroku-toolkit/</a> </p> 