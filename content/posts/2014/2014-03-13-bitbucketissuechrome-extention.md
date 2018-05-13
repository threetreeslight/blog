+++
date = "2014-03-13T07:18:00+00:00"
draft = false
tags = ["bitbucket", "chrome", "extention", "issue", "pretty"]
title = "bitbucketがissueがあまりにも見難いからChrome Extention作った"
+++
bitbucketがissueにおけるmailstoneがあまりにも見難い。辛い。

というわけで、chrome extension作りました

* votesを削除
* created_atを削除
* updated_atを削除
* milestoneの幅を広げる

Chrome Extension作るにあたって、

## まずはgetting started

http://developer.chrome.com/extensions/getstarted


サンプルプログラムをロード

	$ mkdir ./sample-extension
	$ wget http://developer.chrome.com/extensions/examples/tutorials/getstarted/manifest.json
	$ wget http://developer.chrome.com/extensions/examples/tutorials/getstarted/icon.png
	$ wget http://developer.chrome.com/extensions/examples/tutorials/getstarted/popup.html
	$ wget http://developer.chrome.com/extensions/examples/tutorials/getstarted/popup.js

Unpacking Extensionとして追加


1. open chrome://extensions 
2. check Developer mode
3. Load unpacked extension…


こういう作りに成っているのね。なるほど。


## contentsの操作は

表示しているweb pageにinjectionしたりするのはcontent_scriptを使う

[Content Scripts](http://developer.chrome.com/extensions/content_scripts)


## で、作った

[ae06710/bitbucket-issues-prettify-extension](https://github.com/ae06710/bitbucket-issues-prettify-extension)

