+++
date = "2013-10-31T11:30:28+00:00"
draft = false
tags = ["tty", "sudo"]
title = "sudo: sorry, you must have a tty to run sudo"
+++
> 「Defaults requiretty」という設定は、sudo するときに TTY を要求するもので、クラッキング目的で侵入したプログラム等から sudo されないようにするのが目的のようです。

回避する方法は、以下の通り。

特定ユーザーのみttyの要求をしない！

	$ visudo
	Defaults:develop !requiretty

requirettyしない！

	$ visudo
	# Defaults	requiretty

