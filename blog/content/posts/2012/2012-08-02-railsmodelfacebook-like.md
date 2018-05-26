+++
date = "2012-08-02T16:54:37+00:00"
draft = false
tags = ["model", "rails", "like"]
title = "[rails][model][多対多]facebook likeっぽい機能の作り方その１"
+++
<p>like modelの作り方</p>
<blockquote>
<p>$ rails g like references:user references:post<br>$ rails db:migrate&nbsp;</p>
</blockquote>
<p>user modelとpost modelにhas_many設定と持ち主設定</p>
<blockquote>
<p>models/post</p>
<p>has_many :likes, dependant: destroy<br>has_many :likers, through: :likes, source: :user</p>
<p>models/user</p>
<p>has_many :likes, dependent: destroy<br>has_many :liked_posts, through: :likes, source: :post</p>
<p>models/like</p>
<p>attr_accessible :board_id, :user_id<br>belong_to :user<br>belong_to :board</p>
</blockquote>
<p><br>likeのrules</p>
<ul><li>userがあって、且つlikeしていないpostである事</li>
</ul><blockquote>
<p>models/user</p>
<p>&nbsp; # liker rule<br>&nbsp; def likable_for?(user)<br>&nbsp; &nbsp; user &amp;&amp; !likes.exists?( user_id: user.id )&nbsp;<br>&nbsp; end</p>
</blockquote>
<p><br>like rules : likeのvalidation</p>
<blockquote>
<p>models/like</p>
<p>&nbsp;validate do<br>&nbsp; &nbsp; unless user &amp;&amp; user.tunedinable_for?(user)<br>&nbsp; &nbsp; &nbsp; errors.add(:base, :invalid)<br>&nbsp; &nbsp; end<br>&nbsp; end</p>
</blockquote>
<p><br>likeのrouting :　postsのルーティング設定</p>
<ul><li>個別オブジェクトアクセスのmember</li>
<li>collectionでlikedされたpostsを持って来れるようにする</li>
</ul><blockquote>
<p>routes</p>
<p>resources :posts do<br>&nbsp; member { put "liked", "unliked" }<br>&nbsp; collection { get "liked" }<br>end&nbsp;</p>
</blockquote>
<p><br>likedメソッド</p>
<blockquote>
<p>def liked</p>
<p>&nbsp; @post = Post.find(params[:id])<br>&nbsp; @current_user.liked_post &lt;&lt; @post<br>&nbsp; redirect_to posts_path(@post)<br>end</p>
</blockquote>

<p><br>unlikeメソッド</p>
<blockquote>
<p>def unliked<br>&nbsp; @current_user.liked_posts.delete(Post.find(params[:id]))<br>&nbsp; redirect_to posts_path(@post)<br>end</p>
</blockquote>
<p><br>viewへ設定</p>
<blockquote>
<p>&lt;% if current_user %&gt;<br>&nbsp; &lt;% if current_user.likable_for?(@post) %&gt;<br>&nbsp; &nbsp; &lt;%= link_to "like", [:liked, @post], :method =&gt; :put -%&gt;<br>&nbsp; &lt;% else %&gt;<br>&nbsp; &nbsp; &lt;%= link_to "unlike", [:unliked, @post], :method =&gt; :put -%&gt;<br>&nbsp; &lt;% end %&gt;<br>&lt;% end %&gt;&nbsp;</p>
</blockquote>
<p><br>like数を出す</p>
<blockquote>
<p>&lt;%= @post.likes.count -%&gt;</p>
</blockquote>

<p>likeしたユーザーの顔を出す。</p>
<blockquote>
<p>&lt;% @post.likers.order("likers.created_at").each do |liker| -%&gt;<br>&nbsp; &lt;%= image_tag liker.image %&gt;<br>&lt;% end -%&gt;&nbsp;</p>
</blockquote>

<p>その２ではAjax化ぐらい書きます（多分）</p>