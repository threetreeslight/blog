+++
date = "2013-08-28T09:53:00+00:00"
draft = false
tags = ["vagrant", "sahara"]
title = "[vagrant]saharaちゃんと使う"
+++
vagrant上でsandbox modeがいじれる良い子。

良く使い方を忘れるのでメモ。


#### install

	$ vagrant plugin install sahara
	$ vagrant plugin list
	sahara (0.0.15)

#### sandbox mode on

	$ vagrant sandbox on
	0%...10%...20%...30%...40%...50%...60%...70%...80%...90%...100%
	$ vagrant sandbox status
	[default] Sandbox mode is on

#### 変更をrollback

	$ vagrant sandbox rollback
	0%...10%...20%...30%...40%...50%...60%...70%...80%...90%...100%
	
#### 変更をcommit

	$ vagrant suspend
	$ vagrant sandbox commit
	
#### sandbox mode off

	$ vagrant sandbox off


boxen設定に入れておこう。


## P.S
***

boxenでsaharaはいらねぇ・・・

vagrant-saharaという名前でpluginが存在しないのが原因。
これはpull reqする必要は無いんだろう。。。
