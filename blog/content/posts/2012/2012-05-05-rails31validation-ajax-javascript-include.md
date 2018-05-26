+++
date = "2012-05-05T02:09:00+00:00"
draft = false
tags = ["rails", "rails3.1"]
title = "rails3.1になって変わったポイント(validation, ajax通信, javascript include)"
+++
<p><strong>・validation( presence)</strong></p>&#13;
<blockquote>&#13;
<p>rails2<br />validate_presence_of</p>&#13;
<p>rails3.1<br />validates :hoge , presence: true<br />-&gt;”presence:[スペース]”の記述に気をつけるように <br />-&gt;validate"s"になったね。 </p>&#13;
</blockquote>&#13;
<p><br /><strong>・validation( number )</strong></p>&#13;
<blockquote>&#13;
<p>rails2<br /><span class="s1">validate </span>:price_must_be_at_least_a_cent<br />-&gt; :price_must_be_at_least_a_centメソッドにゴリゴリ</p>&#13;
<p>rails3<br />validates <span class="s1">:price</span>, numericality: {greater_then_or_equal_to: <span class="s1">0.01</span>} <br />-&gt; validatesになったね。 </p>&#13;
</blockquote>&#13;
<p><br /><strong>・validation(unique)</strong></p>&#13;
<blockquote>&#13;
<p>rails2<br /> validates_uniqueness_of <span class="s1">:title</span></p>&#13;
<p><span class="s1"></span>rails3<br />validates :title, uniqueness: true <br />-&gt;SQLスキーマっぽい書き方に成ったなぁ・・・ </p>&#13;
</blockquote>&#13;
<p><br /><strong>・ajax通信</strong></p>&#13;
<blockquote>&#13;
<p>rails2<br />&lt;% form_remote_tag :url =&gt; {action: =&gt; 'foo', id =&gt; 'bar'} do %&gt;</p>&#13;
<p>rails3<br /><span>&lt;%= form_tag(url_for(</span><span class="synIdentifier">:action</span><span> =&gt; </span><span class="synSpecial">'</span><span class="synConstant">create</span><span class="synSpecial">'</span><span>), </span><span class="synIdentifier">:remote</span><span> =&gt; </span><span class="synConstant">true</span><span>, </span><span class="synIdentifier">:id</span><span> =&gt; </span><span class="synSpecial">"</span><span class="synConstant">result_form</span><span class="synSpecial">"</span><span>) </span><span class="synStatement">do</span><span> %&gt;</span> </p>&#13;
<p>参考<br />http://d.hatena.ne.jp/ryopeko/20101117/1289991194 </p>&#13;
</blockquote>&#13;
<p><br /><br /><strong>・javascript_include</strong></p>&#13;
<blockquote>&#13;
<p>rails2x, 3<br />javascript_include_tag :defaults<br />-&gt; 色々読み込んでくれる </p>&#13;
<p>rails3<br />javascript_include_tag :defaults<br />-&gt; assets/javascripts/defaults.jsを読みに行く</p>&#13;
<p>解決策<br />javascript_include_tag :application<br />-&gt; assets/javascripts/application.jsを読む<br />-&gt;これしかないっぽい </p>&#13;
<p>参考<br />http://d.hatena.ne.jp/sea_mountain/20110627/1309188029</p>&#13;
</blockquote> 