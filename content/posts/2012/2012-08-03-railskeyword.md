+++
date = "2012-08-03T11:22:36+00:00"
draft = false
tags = ["rails", "keyword"]
title = "[rails]keyword検索の実装"
+++
<p>ある特定のカラム内容からキーワード検索を実装したいときに遣る事。</p>&#13;
<p><br /><strong>検索機能の実装</strong></p>&#13;
<blockquote>&#13;
<p>models: <br />scope :keyword_search, lambda{ |keyword| where 'title like :q', :q =&gt; "%#{keyword}%" }</p>&#13;
&#13;
<p>views : <br />&lt;%= search_field_tag :keyword, nil, :placeholder =&gt; "keyword", :class =&gt; "span3" %&gt;</p>&#13;
</blockquote>&#13;
&#13;
<p><br /><strong>検索結果の表示</strong> </p>&#13;
&#13;
<blockquote>&#13;
<p>if params[:keyword].present?<br />　@boards = Board.keyword_search(params[:keyword])<br />end </p>&#13;
</blockquote>&#13;
 