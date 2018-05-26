+++
date = "2012-07-27T05:34:00+00:00"
draft = false
tags = ["rails", "AWS", "assets sync", "precompile"]
title = "[rails][AWS][assets sync]assets precompileによるサーバー負荷軽減について"
+++
<p>assets precompileはサーバー上で実行すると意外に負荷が掛かる（らしい）</p>&#13;
<p>ということで、出来ればローカルでprecompileしたときに、サーバーに展開してくれるのが望ましい。</p>&#13;
<p>そういうときに役立つのが、assets sync gemになる。</p>&#13;
<p>assets sync gemは、local環境で以下のコマンド実行時した際に、</p>&#13;
<p><br />$ bundle exec rake assets:precompile</p>&#13;
<p>precompileにて生成されたハッシュダイジェスト付きのファイルをS3サーバーやheroku上にupdする事が出来る。</p>&#13;
<p><br /><br /><br />注意点としては、RAILS_ENV 環境変数を設定しておく必要が有る。</p>&#13;
<p>$ export $RAILS_ENV=localhost</p> 