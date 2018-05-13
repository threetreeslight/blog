+++
date = "2012-09-06T02:55:00+00:00"
draft = false
tags = ["where", "find", "rails"]
title = "[rails]where句の利用方法とfindとの違い"
+++
<p><strong>where句の利用方法</strong></p>&#13;
<p><a href="http://d.hatena.ne.jp/sinsoku/20110415/1302842107">http://d.hatena.ne.jp/sinsoku/20110415/1302842107</a></p>&#13;
<p>Arelについて</p>&#13;
<ul><li><a href="https://github.com/rails/arel">https://github.com/rails/arel </a></li>&#13;
<li><a href="http://gihyo.jp/dev/serial/01/ruby/0043">http://gihyo.jp/dev/serial/01/ruby/0043</a></li>&#13;
</ul><p><strong><br />where句とfind句の違い<br /> </strong></p>&#13;
<p>find：<br />オブジェクト一個返すよ。 </p>&#13;
<p>where : <br />配列でオブジェクト返すよ。<br />findと同じ動きにしたいのなら、firstメソッドとかlimitメソッドとかつけるといいよ。た。 </p>&#13;
<p><a href="http://stackoverflow.com/questions/5213358/difference-between-find-and-where-with-relationships">http://stackoverflow.com/questions/5213358/difference-between-find-and-where-with-relationships</a> </p> 