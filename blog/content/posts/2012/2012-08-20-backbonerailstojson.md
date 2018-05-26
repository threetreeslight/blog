+++
date = "2012-08-20T19:37:00+00:00"
draft = false
tags = ["rails", "backbone"]
title = "[backbone][rails]サーバーとのやり取りをするためには、to_jsonをオーバーライドする必要が有る。"
+++
<p>backbone.jsでは、fatchやsaveするときperseオブジェクトが呼ばれる。このperseオブジェクトがserverとのやりとりをjsonでえっちらおっちらするから、必要に応じてオーバーライドしてねって書いてある？</p>&#13;
<blockquote>&#13;
<p><strong class="header">parse</strong><code>model.parse(response)</code><span> </span><br /><strong>parse</strong><span> is called whenever a model's data is returned by the server, in </span><a href="http://backbonejs.org/#Model-fetch">fetch</a><span>, and </span><a href="http://backbonejs.org/#Model-save">save</a><span>. The function is passed the raw </span>response<span> object, and should return the attributes hash to be </span><a href="http://backbonejs.org/#Model-set">set</a><span> on the model. The default implementation is a no-op, simply passing through the JSON response. Override this if you need to work with a preexisting API, or better namespace your responses.</span></p>&#13;
</blockquote>&#13;
<p>もしbackendをrailsでやるんだったら、model毎の属性だけを渡すようなto_jsonを用意して上げてね。そのときはデフォルトのto_jsonメソッドをオフにしてね。</p>&#13;
<blockquote>&#13;
<p>If you're working with a Rails backend, you'll notice that Rails' default to_json implementation includes a model's attributes under a namespace. To disable this behavior for seamless Backbone integration, set:</p>&#13;
<pre>ActiveRecord::Base.include_root_in_json = false</pre>&#13;
</blockquote>&#13;
<p>各モデルにオーバーライドするto_jsonメソッド</p>&#13;
<p>include_root_in_jsonがtrueだとモデルの名前がJSONのルートに含まれるようになる<br /><a href="http://rails.g.hatena.ne.jp/willnet/20090914/1252899509">http://rails.g.hatena.ne.jp/willnet/20090914/1252899509</a> <br /> </p>&#13;
<pre class="ruby">  def to_json(options = {})&#13;
    super(options.merge(:only =&gt; [ :id, :content, :order, :done ]))&#13;
  end&#13;
</pre> 