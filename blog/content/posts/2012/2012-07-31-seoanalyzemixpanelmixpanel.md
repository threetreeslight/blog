+++
date = "2012-07-31T14:24:06+00:00"
draft = false
tags = ["SEO", "analyze", "mixpanel"]
title = "[SEO][analyze][mixpanel]mixpanel利用時の注意点"
+++
<p>mixpanelはevent based drivenのanalyticsツール。</p>&#13;
<p>ユーザーサイト内でのlinkやform、dragなどeventで取得できる事は何でも取得できるという強力なやつ。<br />さらにダッシュボードも見やすいし使いやすい。</p>&#13;
<p>という訳で、構築中のサービスに組み込みなうです。</p>&#13;
<p>しかし、注意しなければ行けない事が何点かあったのでメモしておきます。</p>&#13;
<p><br /><br /><strong>注意点</strong></p>&#13;
<ul><li>mixpanelの指定したレスポンス時間内にserviceからmixpanelへレスポンスが帰ってこないと記録されない。<br />（mixpanel.track_linkとmxpanel.track_formのみっぽい。）</li>&#13;
<li>preview時に生成されていないlinkは".track_link"で引張れない。</li>&#13;
</ul>&#13;
<p>参考</p>&#13;
<p>本家<br /><a href="https://mixpanel.com/docs/integration-libraries/javascript-full-api#track_links">https://mixpanel.com/docs/integration-libraries/javascript-full-api#track_links </a></p>&#13;
<p>その他<a href="http://kadoppe.com/archives/tag/javascript"><br />http://kadoppe.com/archives/tag/javascript</a></p> 