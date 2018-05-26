+++
date = "2012-05-03T11:41:10+00:00"
draft = false
tags = ["ror", "rails", "rails3.1"]
title = "rails3.1になって変わったポイント（assets, routing, session）"
+++
<p>気をつけたい。</p>&#13;
<p><strong>・cssやimagesの参照先がassetsになっている</strong></p>&#13;
<blockquote>&#13;
<p>stylesheetsやimagesの格納先がpublic配下からapp/assets配下になっている。</p>&#13;
</blockquote>&#13;
<p><strong><br /><br />・routing方法</strong></p>&#13;
<blockquote>&#13;
<p>routing方法が厳密になっている</p>&#13;
<p>$rails generate controller sotre index<br />$rails server</p>&#13;
<p>でコントローラー生成</p>&#13;
<p>・3.0<br /> localhost:3000/sotre<br />-&gt; store/index.htmlにアクセス出来る</p>&#13;
<p>・3.1 <br />localhost:3000/sotre<br />-&gt;アクセスできない</p>&#13;
<p>localhost:3000/store/index <br />-&gt;アクセスできる</p>&#13;
</blockquote>&#13;
<p><br />config/routes.rbを見ると以下の通り記述がある。</p>&#13;
<blockquote>&#13;
<p>get "store/index"</p>&#13;
</blockquote>&#13;
<p><br />対応方法</p>&#13;
<blockquote>&#13;
<p>routes.rbの一番最後のコメントアウトを外す</p>&#13;
<p><span class="s1">match </span>':controller(/:action(/:id(.:format)))'</p>&#13;
</blockquote>&#13;
<p><strong><br /><br />・session 設定の有効化</strong></p>&#13;
<blockquote>&#13;
<p class="p1">rails2x?<br />$ rake db:sessions:create<br />$ rake db:migrate<br />config/environment.rbのconfig.action_controller.session_store = :active_record_storeのコメントアウトを外す</p>&#13;
<p class="p1">rails3.1<br />$ rails generate session_migration<br />config/initializers/session_store.rbの最後のコメントを外すう </p>&#13;
</blockquote>&#13;
<p><br /><br /></p> 