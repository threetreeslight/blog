+++
date = "2012-04-19T07:43:00+00:00"
draft = false
tags = ["git", "bitbucket", "heroku"]
title = "gitにGemfile.lockいれっぱでチームに迷惑をかけた"
+++
<p>掲題の通り、gitリポジトリ上にGemfile.lockを入れっぱなしにして、チームに「動かないよー」という事象をおこしてしまった。</p>&#13;
<p>以後、気をつけて行きたい。</p>&#13;
<blockquote>&#13;
<p>参考<br /><a href="http://www.terut.net/?p=523">http://www.terut.net/?p=523</a></p>&#13;
</blockquote>&#13;
<p> 対処方法</p>&#13;
<blockquote>&#13;
<p class="p1">git設定＆Gemfile.lockを消す</p>&#13;
<p class="p3">$ git rm -r --cached vendor/bundle<br />$ git rm --cached Gemfile.lock<br />$ git rm -r vendor/bundle<br />$ git rm Gemfile.lock</p>&#13;
<p class="p2">gitignore<span class="s1">を設定</span></p>&#13;
<p class="p2">$ vim .gitignore</p>&#13;
<p class="p3"> .bundle<br />db/*.sqlite3<br />log/*.log<br />tmp/<br />vendor/bundle/<br />vendor/bundler/<br />public/system/<br />.DS_Store<br />Gemfile.lock</p>&#13;
</blockquote>&#13;
<p class="p3">Dropbox上で作業していたりほんとすいませんですたいorz</p>&#13;
&#13;
&#13;
<p class="p3">P.S. </p>&#13;
<p class="p3">herokuのdeployにはgemlock.file必要みたい。</p>&#13;
<p class="p3">ちょっと運用を考えよう。</p> 