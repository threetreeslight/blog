+++
date = "2012-07-27T05:26:27+00:00"
draft = false
tags = ["omniauth", "auth", "oauth", "rails", "facebook"]
title = "[omniauth][rails][facebook]ローカルでfacebook認証を動かす方法"
+++
<p>現在、facebook dev のappでは、ドメイン名にlocalhostを許容しない形に成っている。</p>&#13;
<p>対策としては、localhostとは別のドメイン名でhostsに定義してしまえばすむ。</p>&#13;
<blockquote>&#13;
<p>1. hosts に ローカルホストを設定<br />$ sudo vim /etc/hosts<br />+ 127.0.0.1 hogehoge.com</p>&#13;
<p><br /> 2. facebook app のドメインをステージング環境と同じドメイン名を設定</p>&#13;
<p>Domain : hogehoge.com<br />webURL : http://www.hogehoge.com</p>&#13;
<p><br />3.  hogeho.com:3000にアクセスして試してみる。</p>&#13;
</blockquote>&#13;
&#13;
<p>以上完了</p> 