+++
date = "2012-08-20T19:57:58+00:00"
draft = false
tags = ["git", "branch"]
title = "[git]gitのブランチを使ってissue解決"
+++
<p>gitによる運用について詳しく書いてあったのでシェア。</p>&#13;
<p><br />あるある事象：</p>&#13;
<blockquote>&#13;
<p><br />masterであるissue X について作業しているんだけど、 それよりも先に対応しなければ行けないissueYが発生。</p>&#13;
<p>issueXの作業は終わっていない。中途半端。</p>&#13;
<p>さぁどうする？</p>&#13;
</blockquote>&#13;
<p><br />対応： </p>&#13;
<blockquote>&#13;
<p>$ git checkout issueX<br />$ git branch<br />  master<br />* issueX <br />$ git add .<br />$ git commit -a -m "work on issueX"<br /><br />$ git checkout master<br />$ git pull hogehoge master<br /><br />-- work --<br /><br />$ git add .<br />$ git push hogehoge master<br /><br />$ git checkout issue97<br />$ git pull origin master<br /><br /></p>&#13;
</blockquote>&#13;
<p>参考</p>&#13;
<p><a href="http://git-scm.com/book/ja/Git-%E3%81%AE%E3%83%96%E3%83%A9%E3%83%B3%E3%83%81%E6%A9%9F%E8%83%BD-%E3%83%96%E3%83%A9%E3%83%B3%E3%83%81%E3%81%A8%E3%83%9E%E3%83%BC%E3%82%B8%E3%81%AE%E5%9F%BA%E6%9C%AC">http://git-scm.com/book/ja/Git-%E3%81%AE%E3%83%96%E3%83%A9%E3%83%B3%E3%83%81%E6%A9%9F%E8%83%BD-%E3%83%96%E3%83%A9%E3%83%B3%E3%83%81%E3%81%A8%E3%83%9E%E3%83%BC%E3%82%B8%E3%81%AE%E5%9F%BA%E6%9C%AC</a></p> 