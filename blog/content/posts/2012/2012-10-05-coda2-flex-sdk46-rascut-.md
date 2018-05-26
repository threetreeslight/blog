+++
date = "2012-10-05T08:13:00+00:00"
draft = false
tags = ["compile", "debug", "environment", "flash", "flex", "sdk", "trace", "rescat"]
title = "coda2 + Flex SDK4.6 + rascut で開発しようと思う。"
+++
<p>FlashBuilder4.5を利用して開発していたのだけど、もっさりしているのでcada2 + Flex SDK4.6 + rascut で開発しようと思う。</p>&#13;
<p><br />1. SDKをダウンロード</p>&#13;
<blockquote>&#13;
<p><a href="http://www.adobe.com/devnet/flex/flex-sdk-download-all.html">http://www.adobe.com/devnet/flex/flex-sdk-download-all.html</a></p>&#13;
</blockquote>&#13;
<p><br />2. application配下に設置してパスを通す</p>&#13;
<pre>$ mv ./flex_sdk_4.6 /Application/&#13;
$ vim ~/.bashrc&#13;
&#13;
+ export PATH=$PATH:$HOME/Applications/flex_sdk_4.6/bin&#13;
&#13;
$ source ~/.bashrc&#13;
</pre>&#13;
<p>3. DefaultのエンコードをUTF-8に変更</p>&#13;
<pre>$ vim /Applications/flex_sdk_4.6/bin/mxmlc&#13;
&#13;
- java $VMARGS $D32 $SETUP_SH_VMARGS -jar "$FLEX_HOME/lib/mxmlc.jar" +flexlib="$FLEX_HOME/frameworks" "$@"<br />+ java -Dfile.encoding=UTF8 $VMARGS $D32 $SETUP_SH_VMARGS -jar "$FLEX_HOME/lib/mxmlc.jar" +flexlib="$FLEX_HOME/frameworks" "$@"&#13;
</pre>&#13;
<p>4. static-link-runtime-shared-librariesをtrueに変更し、コンパイル時の警告を出なくする</p>&#13;
<pre>$ vim /Applications/flex_sdk_4.6/frameworks/flex-config.xml&#13;
&#13;
- false&#13;
+ true&#13;
&#13;
</pre>&#13;
<p>5. debugのためにトレースを吐くようにする</p>&#13;
<pre>※ debugPlayerは最新のFlashPlayerにimplementeされているらしくインストールは不要&#13;
&#13;
$ cd /Library/Application\ Support/Macromedia/&#13;
$ touch ./mm.cfg&#13;
$ vim ./mm.cfg&#13;
&#13;
+ ErrorReportingEnable=1&#13;
+ TraceOutputFileEnable=1&#13;
&#13;
コンパイル&#13;
$ mxmlc hoge.as -debug=true&#13;
&#13;
$ tail -f /Users/ae06710/Library/Preferences/Macromedia/Flash Player/Logs/flashlog.txt&#13;
&#13;
</pre>&#13;
<p>参考：<a href="http://d.hatena.ne.jp/teikou/20110702">http://d.hatena.ne.jp/teikou/20110702</a> <br /> </p>&#13;
<p>6. 開発効率を上げるためにrescatを導入しよう</p>&#13;
<pre>※ rvmはhomeblowからいれておいてね&#13;
<br />$ rvm install 1.8.7&#13;
$ rvm use 1.8.7@flex&#13;
$ gem install rascut&#13;
&#13;
</pre>&#13;
<p>7. 自動的にrvmrcを読むようにする</p>&#13;
<pre>$ cd $develop_derectory<br />$ vim ./.rvmrc<br /><br />+ rvm use 1.8.7@flex<br /><br />$  </pre>&#13;
<p>8. 試してみる</p>&#13;
<pre>$ rascut -s HelloWorld.as&#13;
</pre>&#13;
<p>参考：<a href="http://subtech.g.hatena.ne.jp/secondlife/20070903/1188788498">http://subtech.g.hatena.ne.jp/secondlife/20070903/1188788498</a></p>&#13;
<p>とりあえずここまで</p> 