+++
date = "2014-06-03T23:59:12+00:00"
draft = false
tags = ["pdb", "python", "debugg"]
title = "[python]pdbでデバッグする"
+++
システム連携とかしていると、print debugとかやってられない。

printしているものが足りなかったりとか面倒で、bindingしたい！

と思っていたら標準で出来る模様。

## スクリプトにbindingを仕込む

set_traceを埋め込む事で、当該箇所からトレースできる。

	import pdb; pdb.set_trace()
	
ステキ。

	$ python ./foo.py
	> /Users/foobar/dev/work/foo/foo.py(196)bar()
	-> if not hoge : return
	(Pdb)
	

くわしくはこちら

[26.2. pdb — Python デバッガ](http://docs.python.jp/2/library/pdb.html)

## pudb

他にも、debug toolとしてpudbなどがある。

[pudb 2014.1](https://pypi.python.org/pypi/pudb)

[Python の CUI デバッガ PudB が便利すぎた件](http://momijiame.tumblr.com/post/79011616659/python-cui-pudb)


便利そうだけど、なんかスタンス違うかもと思って試してません。
	
