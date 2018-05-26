+++
date = "2013-06-08T03:00:00+00:00"
draft = false
tags = ["media query", "IE"]
title = "IE8におけるmedia queryの実装"
+++
今更ながら、IEで正常に動作していない事に気付いた。


### 実装
***

respond.jsをIEの場合に読み込むように

### でも動かない。why?
***



importするとだめ
	
	%style
		@import hoge
		
		
MediaQueries

	だめ
	@media (min-width: 1200px) {}

	正しい
	@media screen and (min-width: 1200px) {}
	
