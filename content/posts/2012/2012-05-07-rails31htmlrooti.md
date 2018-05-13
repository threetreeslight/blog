+++
date = "2012-05-07T12:35:14+00:00"
draft = false
tags = ["rails", "rails3.1"]
title = "rails3.1になって変わったポイント(html文の解釈、rooti周り（再掲））"
+++
<p class="p1"><strong>・root周りで意識しておくべき事</strong></p>&#13;
<blockquote>&#13;
<p class="p1">config/routs.rbを弄るように</p>&#13;
<p class="p1"># You can have the root of your site routed with "root"<br /># just remember to delete public/index.html.<br /># root :to =&gt; 'welcome#index'</p>&#13;
</blockquote>&#13;
<p class="p1"><strong>・html文の解釈</strong></p>&#13;
<blockquote>&#13;
<p class="p1">rails2<br />&lt;%= '&lt;p&gt;hoge&lt;/p&gt;' %&gt;</p>&#13;
<p class="p1">rails3.1<br />sanitize('&lt;p&gt;hoge&lt;/p&gt;')</p>&#13;
</blockquote>&#13;
<p class="p1">・layout</p>&#13;
<blockquote>&#13;
<p class="p1">rails2<br />コントローラー名にマッチしたlayout file</p>&#13;
<p class="p1">rials3.1<br />views/layouts/application.html.erbのみ<br />-&gt;整理が楽になった 気がする</p>&#13;
</blockquote>&#13;
<p class="p1"><strong>・stylesheetsの読み込み</strong></p>&#13;
<blockquote>&#13;
<p class="p1">rails3.1<br />assets/stylesheetsのaplication.css内に"*=require_tree "記述がある。<br />これで、assets/stylesheets内の全cssを読み込む模様。</p>&#13;
</blockquote>&#13;
<p class="p1"><strong><br />・レコードの結びつけ</strong></p>&#13;
<blockquote>&#13;
<p class="p1">cartにline_itemsを結びつけ</p>&#13;
<p class="p1">app/models/cart.rb<br />has_many :line_items, dependent: :destroy<br />-&gt;外部キー的に利用 もしくは制約を設ける場合</p>&#13;
<p class="p1">app/models/line_items<br />belongs_to :cart <br />-&gt;外部キー  </p>&#13;
</blockquote>&#13;
<p class="p1"><br />・session</p>&#13;
<blockquote>&#13;
<p class="p1">rails3.1<br />何もせずsession使えちゃう罠</p>&#13;
</blockquote>&#13;
&#13;
<p class="p1">・ findメソッド</p>&#13;
<blockquote>&#13;
<p class="p1">"cart.find_by_ほにゃらら"とコードに書くだけで、cart classにfind メソッドを動的に追加してくれる。</p>&#13;
&#13;
</blockquote>&#13;
 