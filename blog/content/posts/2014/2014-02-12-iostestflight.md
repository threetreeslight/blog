+++
date = "2014-02-12T08:44:00+00:00"
draft = false
tags = ["ios", "profile", "distribution Profile", "AdHock"]
title = "[ios]TestFlightによるテスターへのアプリ配布"
+++
アプリの配布にはデファクトのTestFlightを利用します。

[TestFlight](https://testflightapp.com)

## 1. signup, create team, invite tester

[TestFlight - Getting started as a Developer](http://help.testflightapp.com/customer/portal/articles/1352859-getting-started-as-a-developer)


## 2. Add devise

safariよりtestflightへアクセスし、ログイン

<http://testflight.app/m/login>

チュートリアルに従って、ローカルにインストールします。

[TestFlight - Getting started as a Tester](http://help.testflightapp.com/customer/portal/articles/1339397-getting-started-as-a-tester#connecting_device)

そうすると、profileの登録とホーム画面にTestFlightのURLショートカットアイコンが追加されます。

## 3. generate IPA file and Upload

[Apple developer登録とデバイスの登録](http://threetreeslight.com/post/73186816257/iphone-application)は終わっている前提で進めます。

Apple developerにて、AdHock用Distribution Profileを作成してdownloadします。

* [Apple developer - Certificates, Identifiers & Profiles](https://developer.apple.com/account/ios/profile/profileList.action)

Xcode > Window > organizerにて、登録済みデバイスのprofileに作成したAdHock用profileを追加します。

あと、Xcodeで使える様、AdHock用Profileをダブルクリック。

その後、以下の手順でIPAを作成します。

* Build setting > Code Singing > Provisioning Profile > Releaseに`AdHock Profile`を設定
* Build対象のDeviseを接続している登録済みiOSデバイスを選択
* Product > Archive
* Organizer - Archivesより作成されたアプリを選択し、`Dsitribute`

これでIPAファイルが生成されます。

このファイルをTestFlightに上げればOKです。

詳しくは、TestFlightのSupportなどを参照して下さい。

* [TestFlight - How to create an IPA (Xcode 5)](http://help.testflightapp.com/customer/portal/articles/1333914-how-to-create-an-ipa-xcode-5-)
* [iOS用アプリのAdHoc版を作る（Xcode）](http://mushikago.com/i/?p=2083)


これでDeveloperの端末にはアプリをダウンロードできるようになりました。


## 4. register user devise

おつぎはテスターへのアプリインストールするための下準備です。

実際にアプリをAdHockで実行してもらうためには、TesterのdeviseをApp DeveloperのDeviseに登録する必要が有ります。

* 未登録ユーザーは、TestFlightのアプリページから確認
* devise登録ファイルをダウンロードします。
* [Apple Developer - Certificates, Identifiers & Profiles iOS Devises](https://developer.apple.com/account/ios/device/deviceList.action)よりファイルをアップロードし、デバイスを追加します。
* Distribution ProfileをEditし、Testerのデバイスも全て選択します。
* その後、Distribution Profileをdownloadします。
* downloadしたprofileをTestFlight > Apps > ${App} > Updated Provisioning Profileよりuploadします。
* Teammates In The Provisioning Profileより全ユーザーを選択し、Update & Notifyします。

こうすることでTesterがインストールする事が出来るようになります。
