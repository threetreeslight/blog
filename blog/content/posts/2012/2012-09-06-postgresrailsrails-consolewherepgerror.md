+++
date = "2012-09-06T02:24:00+00:00"
draft = false
tags = ["Postgres", "rails", "DB"]
title = "[Postgres][rails]rails console上でwhere句発行したときのPG::Error"
+++
<p>rails console上でwhere句を発行しようとしたら嵌った罠。</p>&#13;
<p>Model/Post<br />  name:string </p>&#13;
<pre><code class="bash">$ rails c --sandbox</code>&#13;
</pre>&#13;
<pre><code class="ruby">&gt; Post.where( :id =&gt; 1 ) <br />ActiveRecord::StatementInvalid: PG::Error: ERROR:  current transaction is aborted, commands ignored until end of transaction block </code></pre>&#13;
<p><br />参った。"PG"って時点でPostgres依存な訳だが・・・。<br />調べてみた所、 </p>&#13;
<p><em># On PostgreSQL, the transaction is now unusable. The following <br /># statement will cause a PostgreSQL error, even though the unique <br /># constraint is no longer violated:</em></p>&#13;
<ul><li>参考サイト：<a href="http://apidock.com/rails/ActiveRecord/Transactions/ClassMethods">http://apidock.com/rails/ActiveRecord/Transactions/ClassMethods</a></li>&#13;
</ul><p>何となく理解。ってことらしいってことはsandboxオプションを外してやれば良いという事で解決しそう。</p>&#13;
<pre><code class="bash">$ rails c</code>&#13;
</pre>&#13;
<pre><code class="ruby">&gt; Post.where( :id =&gt; 1 ) <br />=&gt; 発行</code></pre>&#13;
<p>無事完了。</p> 