+++
date = "2014-03-13T03:04:07+00:00"
draft = false
tags = ["nslookup", "network"]
title = "nslookupでmxレコードを確認する"
+++
windows live admin domainにてMXレコードが正しく認証されず、果てはてと困っていたときに知りました。


    $ nslookup -p=mx example.com


備忘録