+++
date = "2012-09-29T23:44:00+00:00"
draft = false
tags = ["neste", "model", "rails", "commit", "carrierwave"]
title = "[rails]（carrierwaveが通った）nested modelを含む一括更新方法"
+++
<p>今まで使っていた方法ではcarrierwaveなどしっかり通らなかったので、ネストしたモデルの一括更新方法について変えてみた。そうしたら通った。</p>&#13;
<p><strong>例：postモデル作成時に、初期コメントを同時に生成する方法。</strong></p>&#13;
<p><br />post model : </p>&#13;
<pre>has_many :comment<br />accepts_nested_attributes_for :post_attributes</pre>&#13;
<p>comment model : </p>&#13;
<pre>blongs_to :post</pre>&#13;
<p>post/new.html : </p>&#13;
<pre>&lt;h1&gt;post new&lt;/h1&gt;<br />&lt;% form_for(@post) do |f| %&gt;<br />  &lt;%= f.text_field :title %&gt;<br />  &lt;% f.field_for :comment do |c| %&gt;<br />    &lt;%= c.text_field :body %&gt;<br />  &lt;% end %&gt;<br />  &lt;%= f.submit %&gt;<br />&lt;% end %&gt; </pre>&#13;
<p>posts_controller.rb : </p>&#13;
<pre>def create<br />  @post = Post.new(params[:post])<br />  if @post.save<br />    redirect_to @post<br />  end<br />end </pre>&#13;
<p>ネストしたモデルでcarrierwaveを利用したfileuploadをした際に詰まってたポイント</p>&#13;
<ul><li>f.field_for　の <strong>f.</strong>の関連づけを忘れてた事</li>&#13;
</ul><p>参考：<br /><a href="http://railscasts.com/episodes/196-nested-model-form-part-1">http://railscasts.com/episodes/196-nested-model-form-part-1</a> </p>&#13;
<p><br />ちょっと恥ずかしい</p> 