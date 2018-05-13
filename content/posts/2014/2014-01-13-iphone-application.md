+++
date = "2014-01-13T07:05:00+00:00"
draft = false
tags = ["iOS", "iPhone Application"]
title = "iPhone Applicationを実機でテスト"
+++
## Apple IDの取得

<https://appleid.apple.com/jp/>

## Apple Developerへの登録

<https://developer.apple.com/jp/>

## iOS Developer Programへの参加

<https://developer.apple.com/membercenter/index.action#progSummary>

購入してから、準備が完了するまで２４時間ぐらい掛かります。

届いたコードを利用してactivateしてください。

## 証明書の作成

KeyChain Access -> certificate assistant -> request certificate form certificate authority

common nameは鍵の名前にあんるので、分かりやすくiOSDeveloperProgram

check

* save disc
* Let's me specify key pair information

officialより

> Create a CSR file.
> 
> * In the Applications folder on your Mac, open the Utilities folder and launch Keychain Access.
	* Within the Keychain Access drop down menu, select Keychain Access > Certificate Assistant > Request a Certificate from a 
	Certificate Authority.
	* In the Certificate Information window, enter the following information:
	* In the User Email Address field, enter your email address.
	* In the Common Name field, create a name for your private key (e.g., John Doe Dev Key).
	vThe CA Email Address field should be left empty.
	* In the "Request is" group, select the "Saved to disk" option.
* Click Continue within Keychain Access to complete the CSR generating process.


## Certificates, Identifiers & Profilesにて証明書を作成

<https://developer.apple.com/account/ios/certificate/certificateLanding.action>

select

* iOS App Development 
* upload created cert files.

**safariで実行しましょう！**

## サンプル配布用にも登録

<https://developer.apple.com/account/ios/certificate/certificateList.action?type=development>

Select 

* App Store and Ad Hoc

**safariで実行しましょう！**
 
## App idsの追加

どんなアプリにも使えるデバッグ用App IDの作成

<https://developer.apple.com/account/ios/identifiers/bundle/bundleCreate.action>


Attribute | data
--- | ---
App id Discription | Everything
App ID prefix | Wildcard App ID
Bundle ID | *

**safariで実行しましょう！**

## Deviseの登録

1. Xcode > window > organizer > devises
1. MacにiPhoneを接続
1. identiferを記録
1. <https://developer.apple.com/account/ios/device/deviceCreate.action>にてdevises > all
1. 登録機のUUID(identifier)とNameを登録

> 登録が完了しているとこのような画面になります。端末の登録は他とは違い、年間100台までという制限があるほか、一度登録すると無効にはできますが削除はできないようです。なのである程度慎重に端末を選ぶ必要があります。まぁ個人ならば100台も登録しないとは思いますが念のため。端末のUUIDは端末をMacにつないだ状態でiTunesやXcodeなどで確認できます。

**safariで実行しましょう！**

## Provisioning Profileの追加

1. access <https://developer.apple.com/account/ios/profile/profileList.action>
2. all > development > iOS App Development
3. App ID : Everything
4. select All certificate
5. select All devise
6. Name this profile and generate. > Profilename : Everything
7. Generate
8. Download Profile


## Provisioning ProfileをXcodeのdeviseに追加

1. Xcode > window > organizer > devises
1. provisioning file > Add
1. Everything.mobileprovisionを追加

## certファイルの登録

downloadした以下の２ファイルを実行

* ios_development.cer
* ios_distribution.cer

## サンプルプログラムを転送

iPhoneを選択して、Run

## 参考

* <http://blog.gclue.jp/2013/06/xcode.html>
* <http://r-dimension.xsrv.jp/classes_j/ios_test/>

