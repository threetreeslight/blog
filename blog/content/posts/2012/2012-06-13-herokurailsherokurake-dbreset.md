+++
date = "2012-06-13T12:24:00+00:00"
draft = false
tags = ["rails", "rake", "heroku"]
title = "[heroku][rails]herokuだとrake db:resetが使えない"
+++
<p>herokuではrake db:resetが使えないらしい。そりゃーPaaSのDB権限早々渡せないっすよね的な感じだろうか？まいった。</p>&#13;
<p>$ heroku pg:reset --db SHARED_DATABASE_URL</p>&#13;
&#13;
<p>参考：<br /><a href="http://d.hatena.ne.jp/mat_aki/20110322/1300798955">http://d.hatena.ne.jp/mat_aki/20110322/1300798955</a></p>&#13;
<p><a href="http://ichigotarte.seesaa.net/article/236241882.html">http://ichigotarte.seesaa.net/article/236241882.html</a><a href="http://d.hatena.ne.jp/mat_aki/20110322/1300798955"> </a></p> 