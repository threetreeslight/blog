+++
date = "2012-07-26T06:36:06+00:00"
draft = false
tags = ["rails", "rspec", "bundle", "rvm"]
title = "[rails][rspec][bundle][rvm]railsプロジェクトを新しく作成するときのおすすめ"
+++
<p>railsプロジェクトを新しく作成するときのすすめ。</p>&#13;
<p><br />1. .rvmrcを利用してgemsetをプロジェクト用で利用する。</p>&#13;
<div>2. rspcを利用する</div>&#13;
<p>3. bundleは実行しない</p>&#13;
<p><br />$ mkdir <em>projectname<br /></em>$ cd  ./<em>projectname</em><em><br /></em>$ touch ./.rvmrc<br />$ rvm use 1.9.3@プロジェクト名<br />$ cd ../<br />$ rails new <em>projectname</em> --skip-bundle -T</p>&#13;
&#13;
&#13;
 