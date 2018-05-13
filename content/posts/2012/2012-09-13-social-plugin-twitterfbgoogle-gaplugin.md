+++
date = "2012-09-13T07:24:03+00:00"
draft = false
tags = ["bootstrap", "HTML5", "normalize.css", "HTML5 Boilerplate", "social plugin", "Twitter", "facebook", "google+", "google analytics"]
title = "[social plugin] twitter,fb,google+, gaのplugin高速化"
+++
<p>social pluginの高速化についてもう少し突っ込んでいたら、normalize.cssが便利だよって記事をみつけた。</p>&#13;
<p>えっそんなコードあるの？CSSなのに？的な。<br />で、ちゃんとソース見ていると書いてあった。 </p>&#13;
&#13;
<p>そもそもnormalize.cssについて気になっていたのでもう少し調べてみたら、twitter bootstrapにnormalize.cssって使われているのね。<br />で、normalize.cssの作者が作ったシンプルなテンプレートがHTML5 Boilerplateの様子。<br /> </p>&#13;
<blockquote>&#13;
<p><span>Reset via Normalize</span></p>&#13;
<p><span>With Bootstrap 2, the old reset block has been dropped in favor of </span><a href="http://necolas.github.com/normalize.css/" target="_blank">Normalize.css</a><span>, a project by </span><a href="http://twitter.com/necolas" target="_blank">Nicolas Gallagher</a><span> that also powers the</span><a href="http://html5boilerplate.com/" target="_blank">HTML5 Boilerplate</a><span>. While we use much of Normalize within our </span><strong>reset.less</strong><span>, we have removed some elements specifically for Bootstrap.</span></p>&#13;
</blockquote>&#13;
<p><br /><br />そして、本題のソーシャルプラグインの高速化に関してはこちらの記事を参照。</p>&#13;
<p><a href="http://tokkono.cute.coocan.jp/blog/slow/index.php/xhtmlcss/asynchronous-loading-of-major-social-buttons/">http://tokkono.cute.coocan.jp/blog/slow/index.php/xhtmlcss/asynchronous-loading-of-major-social-buttons/</a></p>&#13;
<p> <br /><strong><a href="https://dev.twitter.com/discussions/3369">twitter</a></strong></p>&#13;
<blockquote>&#13;
<p>↑の最後辺り</p>&#13;
</blockquote>&#13;
<p><strong><a href="https://developers.google.com/+/plugins/+1button/">google+</a></strong></p>&#13;
<blockquote>&#13;
<p><strong>Asynchronous JavaScript loading</strong></p>&#13;
<p><span></span><span>Asynchronous inclusion allows your web page to continue loading while your browser fetches the +1 JavaScript file. By loading these elements in parallel, you ensure that loading +1 button JavaScript file does not increase your page load time.</span>To include the +1 button JavaScript asynchronously, use the following code:</p>&#13;
</blockquote>&#13;
&#13;
<p><a href="https://developers.facebook.com/docs/reference/javascript/">facebook</a></p>&#13;
<blockquote>&#13;
<p><span>This code loads the SDK asynchronously so it does not block loading other elements of your page. This is particularly important to ensure fast page loads for users and SEO robots.</span> </p>&#13;
</blockquote>&#13;
&#13;
<p>念のためコードも記載</p>&#13;
<pre><code class="javascript"> /*<br /> * Updated to use the function-based method described in http://www.phpied.com/social-button-bffs/<br /> * Better handling of scripts without supplied ids.<br /> * * N.B. Be sure to include Google Analytics's _gaq and Facebook's fbAsyncInit prior to this function. <br /> */ <br />(function(doc, script) {<br /> var js, fjs = doc.getElementsByTagName(script)[0], <br /> add = function(url, id) {<br /> if (doc.getElementById(id)) {return;} js = doc.createElement(script);<br /> js.src = url;<br /> id &amp;&amp; (js.id = id); <br /> fjs.parentNode.insertBefore(js, fjs); <br /> }; <br /><br /> // Google Analytics<br /> add(('https:' == location.protocol ? '//ssl' : '//www') + '.google-analytics.com/ga.js', 'ga'); <br /> // Google+ button <br /> add('https://apis.google.com/js/plusone.js'); <br /> // Facebook SDK <br /> add('//connect.facebook.net/en_US/all.js', 'facebook-jssdk'); <br /> // Twitter SDK <br /> add('//platform.twitter.com/widgets.js', 'twitter-wjs'); <br />}(document, 'script')); </code></pre> 