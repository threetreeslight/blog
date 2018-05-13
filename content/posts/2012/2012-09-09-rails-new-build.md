+++
date = "2012-09-09T09:27:44+00:00"
draft = false
tags = ["rails", "new", "build", "create"]
title = "[rails] new, buildの違いが気になった"
+++
<p>new, build, createの違いが気になった。</p>&#13;
<p><strong>new</strong></p>&#13;
<p>普通にインスタンスを生成する。</p>&#13;
<p><strong><br /><br />build</strong></p>&#13;
<p>アソシエーション先の情報を含んだままインスタンス化？ </p>&#13;
<pre>post:&#13;
has_many :comments&#13;
&#13;
comment:&#13;
blongs_to :post&#13;
&#13;
&#13;
1. Post.find(foo).comments.build(params[:id])<br />2. Post.find(foo).comments.new(params[:id])&#13;
&#13;
</pre>&#13;
<p>問題は１と２が変わらなかった件。<br />これはなぜ？ </p>&#13;
<p><a href="http://stackoverflow.com/questions/4954313/build-vs-new-in-rails-3">build-vs-new-in-rails-3</a></p>&#13;
<p>ココに書いてあるような内容に成るかと思って同じ事試したら、newで遣っても変わらなかった。</p>&#13;
<p>apiから読み解くとこういう事なのかしら？</p>&#13;
<ul><li>blongs_toモデルであれば、build_commentメソッドを提供する </li>&#13;
<li>has_and_belongs_to_manyモデルであれば、buildメソッドの本領発揮。</li>&#13;
<li>has_manyモデルのとき、collection.buildするとこいつが参照している外部キーまわりも合わせてごにょごにょするよ？</li>&#13;
</ul><p>うーん。とりあえず親からチェインでオブジェクト化するときはbuildでいこう。</p>&#13;
<p><strong><br />create</strong></p>&#13;
<p>インスタンスを生成する事も無く、ゴリっとcommitまでしてる？みたい。</p>&#13;
<p><br /><br />参考：</p>&#13;
<p><a href="http://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html">http://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html</a></p>&#13;
<p><a href="http://stackoverflow.com/questions/403671/the-differences-between-build-create-and-create-and-when-should-they-be-us">The differences between .build, .create, and .create! and when should they be used?</a></p> 