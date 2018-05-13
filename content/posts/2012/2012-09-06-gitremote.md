+++
date = "2012-09-06T07:38:08+00:00"
draft = false
tags = ["git", "Branch"]
title = "[git]remoteブランチの削除"
+++
<p><strong>remoteブランチの削除</strong></p>&#13;
<pre><code class="bash"> % git branch -a * master hoge origin/hoge % git branch -d hoge % git push origin :hoge </code></pre>&#13;
<p>参考：<br /><a href="http://d.hatena.ne.jp/strkpy/20090719/1247970185">http://d.hatena.ne.jp/strkpy/20090719/1247970185</a></p> 