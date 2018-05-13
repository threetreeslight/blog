+++
date = "2012-09-14T09:28:26+00:00"
draft = false
tags = ["rails", "button_to", "link_to"]
title = "[rails]忘れがちなbutton_toはpost method"
+++
<p>良く設定し忘れるのだけれども、button_toはデフォルトでpostメソッドとして動作するので、link_toと同じ書き方するとrouting erroを吐き出す。</p>&#13;
<p>getメソッドに指定してあげなければ行けない。</p>&#13;
<p>例：</p>&#13;
<pre><code class="ruby">&lt;%= link_to "new", new_posts_path %&gt;<br /> =&gt; work <br /><br />&lt;%= button_to "new", new_posts_path %&gt;<br /> =&gt; dont work <br /><br />should set option<br />&lt;%= button_to "new", new_posts_path, :method =&gt; :get %&gt;</code></pre>&#13;
<p><br />自分への戒めを込めて。</p> 