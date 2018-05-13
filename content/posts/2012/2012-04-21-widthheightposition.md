+++
date = "2012-04-21T14:10:00+00:00"
draft = false
tags = ["jquery", "css", "position"]
title = "画像のwidth,height,positionを動的に変更しようとする際の注意。"
+++
<p>そんなに対した事ではないが、少し（かなりだが）詰まったのでメモしておく。</p>&#13;
<p>画像を連続的に入れ替えるとともに、widthやheightを自動調整し、positionも自動調整する処理を仕様とした時、上手く行かなかった。<br /><br /> </p>&#13;
<blockquote>&#13;
<p>＜原因＞</p>&#13;
<p>・css width, heightを削除していない。<br />・css position left , topを削除していない。 <br />・img width, heightを削除していない。</p>&#13;
</blockquote>&#13;
<p><br />単純では有るが、上記をちゃんと削除する事で奇麗にリサイズ出来る。</p> 