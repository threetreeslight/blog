+++
date = "2012-09-15T08:44:47+00:00"
draft = false
tags = ["model", "rails", "form", "form_for", "field_for", "has_one", "has_many"]
title = "[rails]複数tableへの同時commit (railsのdocumentをちゃんと読みたい)"
+++
<p>複数tableへの同時commitをさせたい。<br />以下の例で言うと、postのviewからcommentとattachmentを保存したい場合など。</p>&#13;
<p>&lt;model sample&gt;</p>&#13;
<p><strong>post model :</strong><br />has_many :comments </p>&#13;
<p><strong>comment model : </strong><br />has_one :attachment<br />belong_to :model </p>&#13;
<p><strong>attachment model : <br /></strong>belong_to :comment</p>&#13;
<p><br />そういうときはfields_for。</p>&#13;
<p>controller of post show</p>&#13;
<pre>@comment = @post.comments.build<br />@attachement = @comment.build_attachment </pre>&#13;
<p>post show view</p>&#13;
<pre>&lt;%= form_for ([@post, @comment]) do |f| %&gt;<br />  &lt;%= field_for (@comment.attachments) do |t| %&gt;<br />     &lt;%= t.text_field :name %&gt;<br />  &lt;% end %&gt;<br />  &lt;%= f.submit %&gt;<br />&lt;% end %&gt; </pre>&#13;
<p>create method in comments controller</p>&#13;
<pre>@comment = Post.find(params[:post_id]).comments.build(params[:comment])<br />@attachment = @comment.build_attachment(params[:attachment]) <br /><br />@comment.save!<br />@attachement.save! </pre>&#13;
<p><br />参考</p>&#13;
<ul><li><a href="http://qiita.com/items/7709710a45c14e20ad3a" title="Rails3で複数のモデルを扱うフォーム">Rails3で複数のモデルを扱うフォーム</a></li>&#13;
<li><a href="http://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-fields_for">ActionView::Helpers::FormHelper</a></li>&#13;
</ul>