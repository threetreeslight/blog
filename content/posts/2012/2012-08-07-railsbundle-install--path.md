+++
date = "2012-08-07T03:54:00+00:00"
draft = false
tags = ["rails", "bundle", "bundler"]
title = "[rails]bundle installの設定変更と--pathの必要性"
+++
<p>以下のファイルを弄る</p>&#13;
<p>$ vim ./.bundle/config</p>&#13;
<p><br />bundlerでは、"--path vendor/bundle"オプションを指定する事をお勧めしているっぽいけど、rvmを利用している場合は其の限りではない。</p>&#13;
<p><br />gemsetを利用する事によってproject毎のgemsetを管理する事が出来るからである。</p>&#13;
<p><br />もちろんこれは運用次第であって、サーバの構築に合わせて"rvm"で管理したgemを参照するか、"bundle"で指定したgemを参照するか決める事に依存する</p> 