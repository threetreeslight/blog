+++
date = "2012-05-19T15:10:10+00:00"
draft = false
tags = ["rails", "heroku", "deploy"]
title = "herokuのdeployとsqliteについて"
+++
&#13;
<p>deploy in heroku :</p>&#13;
<p>https://devcenter.heroku.com/articles/git</p>&#13;
&#13;
<p>heroku push したときにsqlite3でgem install errorになる。<br />だってherokuはposgreだもん！ </p>&#13;
&#13;
<p><br />という訳でsqliteはdevelopmentとtest時に利用するようにする。<br />ついでにherokuではpg gemも必要なのでインスコ </p>&#13;
<p><br /><br />edit Gemfile : </p>&#13;
<p>gem 'sqlite3', :group =&gt; [:development, :test]<br />group :production do<br />  gem 'pg'<br />end</p>&#13;
<p>詳しくはherokuのdevをちゃんと読む事</p>&#13;
 