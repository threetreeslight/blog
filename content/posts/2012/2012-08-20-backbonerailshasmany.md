+++
date = "2012-08-20T17:31:51+00:00"
draft = false
tags = ["rails", "backbone", "has_many"]
title = "[backbone][rails]has_many対応"
+++
<p>backbone.jsを利用したhas_many対応として、上手な方法がない物だろうか？</p>&#13;
<p>has_manyの情報をとりあえずbackboneに渡すために、to_json時にincludeしている。<br />そのため、backbone上のモデルとrails上のモデルは全てマッチしておらず、新しくcreateするときに不要な情報まで渡そうとする。</p>&#13;
<p>今の所、paramsをsliceする事で乗り切っている。</p>&#13;
&#13;
<p>example : todo application in ActionController</p>&#13;
<pre>(Todo.params[:id]).to_json( :include =&gt; { :user =&gt; { :only =&gt; :name}}).html_safe&#13;
</pre>&#13;
<pre>todo = Todo.create! params.slice(:content, :order, :done)&#13;
</pre>&#13;
&#13;
<p>参考<br /><a href="http://stackoverflow.com/questions/9460042/rails-3-functional-tests-cant-mass-assign-protected-attributes-controller-ac">http://stackoverflow.com/questions/9460042/rails-3-functional-tests-cant-mass-assign-protected-attributes-controller-ac</a></p> 