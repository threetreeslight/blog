+++
date = "2012-09-12T12:14:02+00:00"
draft = false
tags = ["javascript", "js", "social plugin", "facebook"]
title = "[facebook]social pluginによる表示速度の低下対策"
+++
<p>ブログやwebサービスにソーシャルボタンを埋め込むと、重い。<br /> </p>&#13;
<p>事実、現在のローカル開発環境では、表示に７秒近く掛かる始末。<br />ネット接続切ると超高速。（回線速度は３M程度）</p>&#13;
<p><strong><br />解決策 : </strong></p>&#13;
<ol><li>facebook pluginのasync化<br />facebook pluginのjs上で"js.async = ture;"。<br /><a href="http://iphone-lab.net/archives/253683">http://iphone-lab.net/archives/253683</a><br /> </li>&#13;
<li>http://techcrunch.com/のように、mouseOverしたら読み込むようにする。</li>&#13;
</ol>