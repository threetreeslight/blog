+++
date = "2014-02-11T09:37:08+00:00"
draft = false
tags = ["xcode", "ios", "framework search path", "build setting"]
title = "[ios][Xcode]framework search pathの指定"
+++
複数人で開発していたらあるあるですが、

framework search pathが基本絶対パスです。そうすると動きませんもちろん。

というわけで、人に依存しないframework search pathを指定する必要が有りました。


## Xcode のbuild settingで利用できる変数が有る


たとえば、$(SRCROOT)とかBuild Settingで使う事が出来ます。

上記を利用し、project_home/vendor配下にframeworkを入れた場合、framework search pathは以下の通りです。

framework search path

	$(SRCROOT)/vendor


こうすることで、開発者の環境に依存する事は無くなります。

## 変数の確認

	$ xcodebuild -showBuildSettings

## build settingのドキュメント


[Xcode Build Setting Reference - introduction](https://developer.apple.com/library/ios/documentation/DeveloperTools/Reference/XcodeBuildSettingRef/0-Introduction/introduction.html)