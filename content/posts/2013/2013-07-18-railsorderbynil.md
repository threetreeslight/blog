+++
date = "2013-07-18T13:15:29+00:00"
draft = false
tags = ["rails", "order", "nil", "desc"]
title = "[rails]order_byにおけるnilの順序"
+++

ASCの場合は、大抵nilレコードのデータはお尻にきてくれるので嬉しい。

DESCの場合でもnilデータのレコードはお尻に持ってきたい。

mysql

	Photo.order('collection_id IS NULL, collection_id DESC')  # Null's last
	Photo.order('collection_id NOT NULL, collection_id DESC') # Null's first

postgres

	Photo.order('collection_id DESC NULLS LAST')  #Null's Last
	Photo.order('collection_id DESC NULLS FIRST') #Null's First
	
参考：[Rails: Order with nulls last](http://stackoverflow.com/questions/5826210/rails-order-with-nulls-last)

めもめもっと。