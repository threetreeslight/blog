+++
date = "2012-04-09T23:50:00+00:00"
draft = false
tags = ["heroku", "git", "rails"]
title = "herokuにupdしてみる"
+++
<p>herokuに上げようとしたらパーミッションエラー出た</p>&#13;
<blockquote>&#13;
<p>Warning: Permanently added the RSA host key for IP address '50.19.85.156' to the list of known hosts.<br />Permission denied (publickey).<br />fatal: The remote end hung up unexpectedly</p>&#13;
</blockquote>&#13;
<p>とりあえず鍵追加</p>&#13;
<blockquote>&#13;
<p>$ <span>heroku keys:add</span></p>&#13;
</blockquote>&#13;
<p><span>いけたっぽい。</span><span>だが、アプリ表示されず。</span>db:migrateしてなくね？と先輩にいわれ。</p>&#13;
<blockquote>&#13;
<p><span>$ heroku log</span></p>&#13;
<p>-&gt; それっぽい感じ</p>&#13;
<p><span>$ heroku run rake db:migrate</span></p>&#13;
<p><span>$ heroku open</span></p>&#13;
<p><span>-&gt; 当該パスへurl移動すると動いてる。</span></p>&#13;
</blockquote>&#13;
<p>herokuのdev centerにちゃんとかいてあるじゃーーーん！！！</p>&#13;
&#13;
&#13;
<p>rorアプリ部分は動くようになった。だが・・・webアプリ部分動かない。<br />gitでindex作ってなくね？って気付きgit commtしたらエラー。</p>&#13;
<blockquote>&#13;
<pre class="syntax-highlight">$ git commit&#13;
error: There was a problem with the editor <span class="synStatement">'</span><span class="synConstant">vi</span><span class="synStatement">'</span>.&#13;
Please supply the message using either <span class="synSpecial">-m</span> or <span class="synSpecial">-F</span> option.&#13;
</pre>&#13;
</blockquote>&#13;
<div>gitで利用するエディターを明示的に示せばいいらしい。</div>&#13;
<div>bashrcを編集してGIT_EDITOR変数を追加</div>&#13;
<blockquote>export GIT_EDITOR="/usr/bin/vim"</blockquote>&#13;
<blockquote>$ git commit</blockquote>&#13;
<p>むむ？はじかれる？</p>&#13;
&#13;
<p>コミットするときにコメント書かないとはじかれる事を理解。<br />コメントは以下の通り。</p>&#13;
<blockquote>&#13;
<pre> 1.  コミットの理由と内容（1行かつ50文字以内。）&#13;
 2.&#13;
 3.  詳細なコミットの内容や変更した理由（行数、文字数の制限はない。）&#13;
 4. 　〜（詳細な記述の続き）〜 </pre>&#13;
</blockquote>&#13;
<pre>そんでもってherokuにdeploy</pre>&#13;
<blockquote>&#13;
<div>$ git push heroku master</div>&#13;
</blockquote>&#13;
<p>動いた</p>&#13;
&#13;
<p>参考：heroku周り</p>&#13;
<p><a href="https://devcenter.heroku.com/articles/rails3">https://devcenter.heroku.com/articles/rails3</a></p>&#13;
<p><a href="http://d.hatena.ne.jp/opamp_sando/20110914/1316011399">http://d.hatena.ne.jp/opamp_sando/20110914/1316011399</a></p>&#13;
<p>参考：git周り</p>&#13;
<p><a href="http://d.hatena.ne.jp/tentete/20100417/1271500653">http://d.hatena.ne.jp/tentete/20100417/1271500653</a></p>&#13;
<p><a href="http://es.sourceforge.jp/projects/setucocms/wiki/Git_%E9%96%8B%E7%99%BA%E4%B8%AD%E3%81%AEGit%E6%93%8D%E4%BD%9C%E3%83%AA%E3%83%95%E3%82%A1%E3%83%AC%E3%83%B3%E3%82%B9#h3-.E3.82.B3.E3.83.9F.E3.83.83.E3.83.88.E3.81.99.E3.82.8B.EF.BC.88git.20commit.EF.BC.89">http://es.sourceforge.jp/projects/setucocms/wiki/Git_%E9%96%8B%E7%99%BA%E4%B8%AD%E3%81%AEGit%E6%93%8D%E4%BD%9C%E3%83%AA%E3%83%95%E3%82%A1%E3%83%AC%E3%83%B3%E3%82%B9#h3-.E3.82.B3.E3.83.9F.E3.83.83.E3.83.88.E3.81.99.E3.82.8B.EF.BC.88git.20commit.EF.BC.89</a></p> 