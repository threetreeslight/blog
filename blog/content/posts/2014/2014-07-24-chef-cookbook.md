+++
date = "2014-07-24T08:41:57+00:00"
draft = false
tags = ["chef"]
title = "[chef] 複数環境を管理するcookbookをリファクタしてみた"
+++
Chefマスターから見たら「えっそんなこともちゃんとやってなかったの？情弱」的な感じかもしれませんが、とりあえず自分で気をつけたポイントをメモしてみました。

ほんとはこう分けた方が良いよ！とかありましたら教えてもらえると嬉しいです！

## 課題

やっとサービスが成長してきたので、ちゃんとChefで３環境(local, staging, production)を管理しているのですが、

「3rd partyのcookbookも使ってるし、attributeのoverrideをrunlistで行っていて、環境ごとのrunlistに差分が出る。ヤバい。目diff無理」

という素敵な課題が勃発

## 対策

このrunlist問題に対して、以下のような対策を打って、リファクタしました。

## 1. バージョンをattribute化してあるものは必ずserver specでテスト

これは当たり前ですね。なんでやってなかったんだって怒られそう。

## 2. site-cookbooks内のcookbookのまとまり感を揃える

リファクタ前は、あるpakcageのインストールをcookbook内のrecipeとして管理したり、独立したcookbookとして管理したり、粒度や方針がバラバラでした。

例えば以下のようなものがバラッバラでした。

- [papertrail](https://papertrailapp.com/)
- [monit](http://mmonit.com/monit/)
- [unicorn](http://unicorn.bogomips.org/)


そうなると当然、チーム内で新しいpackageを追加したいときに「これって切り出すべき？それともどっかのrecipeにするべき？」って話し合う事が多くなる感じです。

そこで、以下のような大きく４つのcookbookを作って整理した結果、runlistへの見通しも良くなりました。
（分け方は趣味です）

- initialize
    - 最初にやっておくべき事(sudoとかuserの追加とか、iptablesとか）
- languages
	- node, ruby, pythonとか
- db
	- db接続とかdbそのものなど
- sites
	- nginx周りの設定とかweb server絡み



ただ、recipeの内容が複雑になる場合やtemplateを多用する場合は、まとめてしまうとメンテし難くなるのでcookbookとして切り出し、include_recipeするwrap recipeを上記のcookbookに食わせるようにしました。


## 3. 3rd partyのcookbookを直接runlistから実行せず、包む。

runlistを長くなる原因の一つとして、3rd partyのcookbookをそのままrunlistから実行する事が挙げられると思います。

対策としては、ほぼ2のcookbook切り出した場合と同じで、3rd partyのcookbookをincludeするwarp recipeを作り、attributeもそのcookbook内でまず上書きする方針にしました。

例えばgitの3rdpartyを以下のようにrunlistで記載するのではなく、warpすると以下になるイメージです

### リファクタ前


```js
// runlist
{
  "environment": "production",
  "git": {
    "version: "1.9.0",
    "url": "https://git-core.googlecode.com/files/git-1.9.0.tar.gz"
  },
  "run_list": [
    "git::source"
  ]
}
```

### リファクタ後

wrapするrecipeを作って

```ruby
# initialize::git
include_recipe "git::source"
```

attributeで上書きして

```ruby
# attribute
# git
default['git']['version'] = '1.9.0'
default['git']['url']     = 'https://git-core.googlecode.com/files/git-1.9.0.tar.gz'
```

runlistはこんな感じに

```js
// runlist
{
  "environment": "production",
  "run_list": [
    "initialize::git"
  ]
}
```

このとき、attributeに記載するデフォルト値はstaging環境にしてみました。


理由としては以下２つです。

- productionにすると、環境を増やしたときに繋がれてしまう恐れが有る
- local(development)にすると、papertrailなど環境を増やしたときにattribute設定の漏れが出る恐れが有る


## 4. environmentを利用してrunlistからattributeを分離

環境ごとに異なるtokenやdbのつなぎ先などはenvironmentで管理します。

中を見ると以下のようになっているのですが、

```js
{
  "name": "production",
  "description":"This is it",
  "chef_type": "environment",
  "json_class": "Chef::Environment",
  "default_attributes": {
  },
  "override_attributes": {
  }
}
```

override attributeは、優先度の高い値として、attributeを強制的に上書きされるので、overrideを使います。

reference: http://docs.opscode.com/essentials_environments.html


で、そこで明示的に示しておくべきattributeは、defaultにあったとしてもそれぞれattributeで明示的に書いておくことにしました。

例えば、database.ymlの設定や.envファイルの設定です。これは、環境を別途切り出した場合の設定ミスを防ぐ目的で行いました。

## 5. runlist内の重複は、roleで回避する

ある程度整理できてくるとnodeの重複が出てきます。

### リファクタ前

local

```js
{
  "environment": "local",
  "run_list": [
    "initialize::default",
    "initialize::manage",
    "initialize::users",
    "initialize::sudo",
    "initialize::ssh",
    "initialize::hosts",
    "initialize::iptables",
    "initialize::git",
	...
    // only staging, local
    "db::mysql_server",
    "sites::memcached"
	...
  ]
}

```

production

```js
{
  "environment": "production",
  "run_list": [
    "initialize::default",
    "initialize::manage",
    "initialize::users",
    "initialize::sudo",
    "initialize::ssh",
    "initialize::hosts",
    "initialize::iptables",
    "initialize::git",
	...
  ]
}
```

### リファクタ後

common, db, web, dev(dbやらcacheやら、productionでは外に出すけど、stagingとかではお腹に置くもの）とか切り出します

```js
// roles/common.json
{
  "name": "common",
  "chef_type": "role",
  "json_class":"Chef::Role",
  "default_attributes":{},
  "override_attributes":{},
  "description":"webserver’s role",
  "run_list": [
    "initialize::default",
    "initialize::manage",
    "initialize::users",
    "initialize::sudo",
    "initialize::ssh",
    "initialize::hosts",
    "initialize::iptables",
    "initialize::git"
	...
  ]
}
```

runlist

```js
{
  "environment": "local",
  "run_list": [
	"role[common]",
	...
	"role[dev]"
  ]
}

```

ただ、以下のサイトにもあるようにrunlistはバージョン管理できない事も有り、問題が有るかもしれません。

[[和訳] 初心者Chefアンチパターン by Julian Dunn #opschef_ja](http://www.creationline.com/lab/3080)

  
