+++
date = "2014-05-05T13:40:48+00:00"
draft = false
tags = ["python", "exception"]
title = "[python] pythonで例外をthrow"
+++
汎用的なExceptionとしてthrowする。


	raise Excetion , "Have some error"

独自のExceptionを定義して発行する事も出来る

	class InputError(Error):
	    """Exception raised for errors in the input.
	
	    Attributes:
	        expr -- input expression in which the error occurred
	        msg  -- explanation of the error
	    """
	
	    def __init__(self, expr, msg):
	        self.expr = expr
	        self.msg = msg


	raise InputError , "Have some input Error"


### 参考

* [Python Documentation - 6. 組み込み例外](http://docs.python.jp/2/library/exceptions.html)
* [Python Documentation - 8. エラーと例外](http://docs.python.jp/2/tutorial/errors.html)