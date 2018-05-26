+++
date = "2012-08-05T13:54:49+00:00"
draft = false
tags = ["facebook", "sandbox", "app"]
title = "[facebook][app][sandbox]facebookのsandbox modeには気をつけよう"
+++
&#13;
<p><span>facebookログインが出来ず、以下のエラーが出まくる</span></p>&#13;
<blockquote>&#13;
<ul><li>"/auth/facebook/callback?error_reason=user_denied&amp;error=access_denied&amp;error_description=The+user+denied+your+request.&amp;state=6b82e274e633aeddf35fb14f42eb9da14050d22840642db5"</li>&#13;
<li>/auth/facebook/callback?error_code=1&amp;error_msg=kError 1349040: 無効なアプリケーションID: 指定されたアプリケーションIDが無効です。</li>&#13;
</ul></blockquote>&#13;
<p><span><br />【原因】<br /></span><span>facebook appのsandbox modeが”有効”になっていたのが原因でした。</span></p>&#13;
&#13;
<p>【解決策】<br />http://stackoverflow.com/questions/5862360/facebook-authentication-returns-denied-even-if-i-click-allow  </p>&#13;
<p>以下重要な所<br />The issue is related to the fact that you are in sandbox mode,</p>&#13;
<p>To remove the pending status, you need the person who you've granted the role to to log into their account. In their notifications you will see that they have been granted the role for the Facebook app.</p>&#13;
 