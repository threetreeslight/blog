+++
date = "2012-04-22T13:13:01+00:00"
draft = false
tags = ["local storage", "storage"]
title = "localStorageにてjsonを管理する"
+++
<p>非常に単純な作業だが、メモしておおきたい。</p>&#13;
<p>localStorageは現時点ではオブジェクトを格納できない（W３Cでは格納できるようになるような示唆あり）。<br />格納できるのは文字列のみである。</p>&#13;
<p><br />そのため、 以下の処理で対応する。</p>&#13;
<p>・書き込み：JSON.stringifyを利用してstringに変換して保存</p>&#13;
<p>・読み込み：JSON.parseを利用してjsonに変換</p>&#13;
&#13;
<blockquote>&#13;
<p>参考</p>&#13;
<p>http://dev.screw-axis.com/doc/chrome_extensions/tips/localstorage/</p>&#13;
&#13;
</blockquote>&#13;
&#13;
 