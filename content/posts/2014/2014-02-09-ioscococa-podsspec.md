+++
date = "2014-02-09T07:44:46+00:00"
draft = false
tags = ["cocoapods", "pod", "spec", "ios"]
title = "[iOS]cococa podsのspecリポジトリがぶっ壊れる"
+++
掲題の通り、チームメンバが`pod install`しようとしたら盛大にエラーを吐かれた模様。


## 事象

	$ git clone hogehoge
	$ bundle install
	$ bundle exec pod install
	
	Analyzing dependencies
	[!] Pod::Executable pull
	
	CONFLICT (rename/rename): Rename "CardIO/3.2.0/CardIO.podspec"->"CardIO/3.4.0/CardIO.podspec" in branch "HEAD" rename "CardIO/3.2.0/CardIO.podspec"->"CardIO/3.4.4/CardIO.podspec" in "16b5d92615c220b7a2f8b38effc03c6e54463d6f"
	
	CONFLICT (rename/rename): Rename "CardIO/3.2.2/CardIO.podspec"->"CardIO/3.4.4/CardIO.podspec" in branch "HEAD" rename "CardIO/3.2.2/CardIO.podspec"->"CardIO/3.4.1/CardIO.podspec" in "16b5d92615c220b7a2f8b38effc03c6e54463d6f"
	
	CONFLICT (rename/rename): Rename "CardIO/3.2.3/CardIO.podspec"->"CardIO/3.4.1/CardIO.podspec" in branch "HEAD" rename "CardIO/3.2.3/CardIO.podspec"->"CardIO/3.4.0/CardIO.podspec" in "16b5d92615c220b7a2f8b38effc03c6e54463d6f"
	
	Renaming CardIO/3.3.0/CardIO.podspec->CardIO/3.4.3/CardIO.podspec
	...

## 解決策

こんな感じでspec ディレクトリを直す

	$ pod repo remove master
    $ pod setup

## 参考
  
[cocoapods - Repairing Our Broken Specs Repository](http://blog.cocoapods.org/Repairing-Our-Broken-Specs-Repository/)

[stackoverflow - Error on pod install](http://stackoverflow.com/questions/18224627/error-on-pod-install)