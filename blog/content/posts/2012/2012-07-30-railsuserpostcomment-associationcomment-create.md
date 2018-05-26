+++
date = "2012-07-30T08:48:09+00:00"
draft = false
tags = ["rails", "model"]
title = "[rails]user/post/comment associationにおけるcomment create"
+++
<p>とてもつまらない所で嵌ったときに、stack over flow先生が助けてくれたのでメモ。</p>&#13;
<p>以下のアソシエーションにおけるコメントポストの方法。<br />ポイントは、commentがuserとpostの子なので、どうcreateするべきなのか？ </p>&#13;
<p>post model : </p>&#13;
<blockquote>&#13;
<p>has_many :comments<br />belongs_to :user </p>&#13;
</blockquote>&#13;
<p>comment model : </p>&#13;
<blockquote>&#13;
<p>belongs_to :user<br />belongs_to :comment </p>&#13;
</blockquote>&#13;
<p>user model : </p>&#13;
<blockquote>&#13;
<p>has_many :comments<br />has_many :posts</p>&#13;
</blockquote>&#13;
<p>comment controller :</p>&#13;
<blockquote>&#13;
<p>@comment = Post.find(<em>id</em>).comments.create(<em>params</em>)<br />@comment.user = User.find(<em>id</em>) <br /><br />@comment.save! </p>&#13;
</blockquote>&#13;
&#13;
<p><br />stack over flowはとても便利</p>&#13;
<p><a href="http://stackoverflow.com/questions/3732198/rails-associations-belongs-to-has-many-cant-save-2-ids-in-table-with-a-creat">http://stackoverflow.com/questions/3732198/rails-associations-belongs-to-has-many-cant-save-2-ids-in-table-with-a-creat</a><a href="http://stackoverflow.com/questions/3732198/rails-associations-belongs-to-has-many-cant-save-2-ids-in-table-with-a-creat"> </a></p>&#13;
<p>検索キーワードを頑張って工夫しなくちゃ行けない事も理解した<br />use keyword : rails association of post comment user</p> 