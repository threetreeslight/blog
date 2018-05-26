+++
date = "2014-04-27T06:11:37+00:00"
draft = false
tags = ["ios", "xode", "mobileprovision"]
title = "[Xcode][iOS]mobileprovision fileの削除方法"
+++
普通に削除できるかなーと思ったら無い。どこにも無い。what!?

たまってきてうざいし、どれがどれだか分からないなんて多々ある。参った。


provisionファイルどこにあるのーって探したらここにあった。


	$ cd ~/Library/MobileDevice/Provisioning\ Profiles
	$ ls -la
	-rw-r--r--  1 foobar  staff  7629  3  2 10:06 48E6A489-CF37-430C-8B4D-6373833FB292.mobileprovision
	-rw-r--r--  1 foobar  staff  7809  4 24 14:32 509D4090-45E1-4699-8FBC-D0BBFBEB42D4.mobileprovision
	-rw-r--r--  1 foobar  staff  7650  3 10 20:13 6C8B1921-4370-40F3-A39C-6D1C77E5270C.mobileprovision
	-rw-r--r--  1 foobar  staff  7568  2 14 13:58 72FC28D4-3CD2-4788-A274-F99EF68E44EF.mobileprovision
	-rw-r--r--  1 foobar  staff  7749  3 31 10:07 7481573A-1DB5-4CAD-BC8A-A45B9568B1C6.mobileprovision
	-rw-r--r--  1 foobar  staff  7869  4 24 14:42 E2905BBB-BEFD-4822-A606-0129A5BE4F5F.mobileprovision
	-rw-r--r--  1 foobar  staff  7749  3 29 23:51 F7FC5613-2C00-4766-9F66-9B0C90F8DDF4.mobileprovision


よし、全部削除して新しく入れてキレイキレイだ。
