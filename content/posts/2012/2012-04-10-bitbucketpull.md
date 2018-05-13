+++
date = "2012-04-10T00:55:53+00:00"
draft = false
tags = ["bitbuket"]
title = "bitbucketがpullしたら？って怒る"
+++
<p>えいやーってコミットしてbitbucket へpushしようとした</p>&#13;
<blockquote>&#13;
<p>$ git commit<br />$ git push http://hoge.git master</p>&#13;
</blockquote>&#13;
<p>情報が最新じゃないっぽいよって怒ってくれる。pullでもしたら？って感じで<br />git cloneしたのが古いからなのかな？って妄想。<br /> </p>&#13;
<p><br />とりあえず最新のソースを取得</p>&#13;
<blockquote>&#13;
<p>$ git fetch https://hote.git master<br />$ git marge FETCH_HEAD<br />$ git diff FETCH_HEAD </p>&#13;
</blockquote>&#13;
<p><br />diffが楽しい。そんで更新</p>&#13;
<blockquote>&#13;
<p>$ git add<br />$ git commit<br />$ git push https://hoge.git master</p>&#13;
</blockquote>&#13;
<p>あっなんとなく美味く言ったっぽい。</p>&#13;
<p>しかもちゃんとローカルでコミットした内容とかも表示されている。<br />bitbucket素晴らしい！いや、git 素晴らしい！ </p> 