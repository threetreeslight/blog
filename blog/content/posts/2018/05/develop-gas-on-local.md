+++
date = "2018-05-29T10:00:00+09:00"
title = "Develop GAS on local"
tags = ["gas", "google app script"]
categories = ["programming"]
+++

業務改善のために[GAS (Google Apps Script) ](https://developers.google.com/apps-script/) は書かせません

ただ、script editorを使ってweb上でデバッグするのは少し効率の悪い作業です。
また、テストを記述することもできません。

そのため、localで如何にgoogle apps scriptを開発するべきか考えをまとめました。


## manage and deploy google apps script by clasp

[Collaborating with Other Developers](https://developers.google.com/apps-script/guides/collaborating) は必読。

localでgoogle apps scriptを管理するために [google/clasp](https://github.com/google/clasp) を利用します。

Claspはgasをgitのようにgasのversioning、push/pullなどをサポートします。

## Prepare to use clasp

Then enable Apps Script API: script.google.com/home/usersettings

![](/images/blog/2018/05/gas-enable-app-script-api.png)

install clasp

```sh
sudo npm i @google/clasp -g
```

OAuth loginする。このとき、以下の通りownkey optionをつけて手元に持ってくる必要がある

> https://github.com/google/clasp/blob/4bc1e32d742e686532d4d51633b59e7c091dba53/index.ts#L766
> * Note: to use this command, you must have used `clasp login --ownkey`

```sh
clasp login --ownkey
```

既存projectを管理するための準備をする

```sh
mkdir -p project_name/src
cd project_name
```

`File > Project properties > info` よりscript idを手に入れコードをcloneする。

![](/images/blog/2018/05/gas-project-properties-info.png)

```sh
echo "{
  "scriptId": "<script_id>",
  "rootDir": "src"
}" > .clasp.json
```

gasで利用しないコードがgasにpushされてしまうと困るので、`src` というdirectoryを切って管理します。また、必要に応じて `.claspignore` を作成してpushしたくないコードが含まれないようにすることも可能です。

コードを持ってきます。

```sh
clasp pull
```

これでgit管理する準備が整いました。

google apps script editor上にuploadするには以下のようにpushすることで実現できます。

```sh
clasp push
```

## How to quick debug?

さて、コードは持ってきたものの、実行環境がlocalに無いことはとても不便です。

この問題を解決するためには以下の２つの方法が考えられます。

1. 頑張ってmockを書いて、`reuqire`で必要なコードを読み込みlocalのnode環境で動くようにする
1. pushないしdeployしたコードをlocalから実行し、そのログをAPI経由で取得する

spreadsheetの操作を行って確認することや、gasのmockを書く労力、なによりもruntimeの違いを鑑みると2の方法が良さそうです。

今回は `spreadsheet` に付帯する gas project を実行する準備について記述します。

以下のようなscriptであることをサンプルコードとして書いておきます。

```js
function myFunction() {
  Logger.log("called myFunction");
  console.info('Timing the %s function (%d arguments)', 'myFunction', 1);
}
```

## Debug on web console

web consoleからdebugする設定をする方法は以下のとおりです。

`File > Project properties > scope` より OAuthで利用する権限の確認しておく。

必要に応じて特別に権限を設定しておく必要があるため。

![](/images/blog/2018/05/gas-project-properties-scopes.png)

`Publish > Deploy as API Executable` より自分を対象に公開する。

`clasp deploy` でも :ok_women:

![](/images/blog/2018/05/gas-deployas-api-executable.png)

`Resources > Cloud Platform Project` より [google cloud console](https://console.cloud.google.com)へ移動し、以下のサービスをenableにする

1. Google Sheets API
1. Apps Script API

OAuthで当該権限が使えるようOAuthに利用するclient idを取得します

https://developers.google.com をOAuthで利用できるようにする

![](/images/blog/2018/05/gas-oauth-client-id.png)

`Google Sheets API` の管理画面にある `Try this API` より `script.scripts.run` をより試します。

client_idを設定

![](/images/blog/2018/05/gas-try-thihs-api-set-client-id.png)


必要項目を設定し実行

![](/images/blog/2018/05/gas-execute-test.png)

200 OK!

[stack driver](https://console.cloud.google.com/logs)上にもlogが現れていることを確認します。

![](/images/blog/2018/05/gas-stack-driver.png)

## Debug on terminal

最新のコードをデプロイ

```
clasp deploy
```

deployした設定を引っ張る。初回だけ実施。このあとはdeployするだけで :ok_women:

```
clasp pull
```

指定したfunctionを走らせてlogをみる。

```
clasp run myFunction
clasp logs
```
