+++
date = "2012-08-03T11:24:53+00:00"
draft = false
tags = ["rails", "select_tag", "form"]
title = "[rails][select_tag]セレクトタグを利用した絞り込み"
+++
<p>セレクトタグを利用した絞り込みはこうやるよ！</p>&#13;
<p><br />view : </p>&#13;
<p>&lt;%= form_tag(boards_path, :method =&gt; :get) do -%&gt;<br />  &lt;%= select_tag :tag, options_for_select([,'Acoustic', 'Blues', 'Bossa Nova']),{ :onChange =&gt; 'this.form.submit();' } %&gt;<br />&lt;% end %&gt; </p>&#13;
&#13;
 