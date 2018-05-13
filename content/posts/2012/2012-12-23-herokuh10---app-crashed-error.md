+++
date = "2012-12-23T08:37:00+00:00"
draft = false
tags = ["heroku", "H10", "error"]
title = "[heroku]H10 - App crashed error"
+++
<p>herokuにdeployしたらassets precompoileが走らずdeploy完了言われた。</p>&#13;
<p>エーと思ってアクセスしたらApplication Error。</p>&#13;
<p><br />1. ログを見てみる。</p>&#13;
<pre>$ heroku logs -t<br />2012-12-23T07:57:31+00:00 heroku[router]: at=error code=H10 desc="App crashed" method=GET path=/ host=production.tweetgogo.com fwd=126.65.220.156 dyno= queue= wait= connect= service= status=503 bytes=&#13;
2012-12-23T07:57:33+00:00 heroku[router]: at=error code=H10 desc="App crashed" method=GET path=/favicon.ico host=hogehogehoge.com fwd=126.65.220.156 dyno= queue= wait= connect= service= status=503 bytes=</pre>&#13;
<p><br />H10エラーって何？こんなエラー知らない。ソースコード以前の問題？</p>&#13;
<p>herokuのドキュメント見る。</p>&#13;
<p><a href="https://devcenter.heroku.com/articles/error-codes">https://devcenter.heroku.com/articles/error-codes</a></p>&#13;
<blockquote>&#13;
<div>&#13;
<p><span>A crashed web process or a boot timeout on the web process will present this error.</span></p>&#13;
</div>&#13;
</blockquote>&#13;
<p>web process crashedとか超怖い。どうしよう。と思って頑張って洗う。。。<br /><br /><br />原因はApplication.rbでproduction環境だと存在しない無い物をrequireしてた。</p>&#13;
<p><br />直して再度deploy。</p>&#13;
<p>動いた。</p>&#13;
<p><br /><br />config周りだとこういうエラー出すのね。ふぅ。。。</p> 