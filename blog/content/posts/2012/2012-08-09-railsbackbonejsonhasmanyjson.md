+++
date = "2012-08-09T13:11:33+00:00"
draft = false
tags = ["rails", "backbone", "json", "has_many"]
title = "[rails][backbone][json]has_manyに対応したjson渡し"
+++
<p>bakcbone.jsをrailsに適用させているときに、親の値だけではなく、子の値もjsonとして渡して上げたい場合が有る。</p>&#13;
<p>そんなときには以下の方法を使おう。</p>&#13;
<p><br />前提条件</p>&#13;
<blockquote>&#13;
<p>model x : <br />has_many y<br /><br />model y : <br />blongs_to x</p>&#13;
</blockquote>&#13;
<p><br />json化</p>&#13;
<blockquote>&#13;
<p>@x.json( :include =&gt; :y )</p>&#13;
<ul><li>xのmethodを制限したい場合は、exceptオプションもしくはonlyオプションを利用する。</li>&#13;
</ul></blockquote>&#13;
<p><br />このとき、気をつけなければいけないのは、xの持っているメソッドもしくは子のメソッドしか抽出できないという事。<br /><br /> </p>&#13;
<p>参考：to_json</p>&#13;
<p><a href="http://stackoverflow.com/questions/4653844/json-include-syntax">http://stackoverflow.com/questions/4653844/json-include-syntax</a></p>&#13;
<p><br />参考：to_jsonで良く引っかかる罠</p>&#13;
<p><a href="http://stackoverflow.com/questions/1930267/ruby-on-rails-to-json-problem-with-include">http://stackoverflow.com/questions/1930267/ruby-on-rails-to-json-problem-with-include</a></p>&#13;
<p>参考：onlyとかexceptの使い方</p>&#13;
<p><a href="http://apidock.com/rails/ActiveRecord/Serialization/to_json">http://apidock.com/rails/ActiveRecord/Serialization/to_json</a></p> 