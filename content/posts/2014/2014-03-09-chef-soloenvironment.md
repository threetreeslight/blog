+++
date = "2014-03-09T12:48:06+00:00"
draft = false
tags = ["knife", "chef", "chef-solo", "environment"]
title = "[chef-solo]environmentの追加の仕方"
+++
chef-soloを本番環境で運用して半年、最近environmentの警告がうざい。

というわけで、その警告の解決策とともにenvironmentの設定方法をまとめました。

で、使って見るとlocal, staging, productionそれぞれrunlist作って設定変えたり、hashで環境毎に変数書き換えるattributeとか特殊な事しなくてよいから超便利だった。

## environmentとは？

naoyaさんのブログと公式ドキュメント参考

[Chef Solo の Environments - naoyaのはてなダイアリー](
http://d.hatena.ne.jp/naoya/20131222/1387700058)

> Environments とは
> 
> Chef の Environments は、例えば development や production など環境ごとに設定内容を切り分ける場合に使える機能です。Rails における RAILS_ENV みたいなものだと思えばだいたい合ってる。実際には環境ごとに設定を切り分けると言っても、できることは Attribute の値を環境によって差し換えることができる、程度。
> 
> つまり、Attribute によってうまく環境差を吸収するようなクックブックを構成しておく必要はあります。

[Chef - About Environments](
http://docs.opscode.com/essentials_environments.html)

> An environment is a way to map an organization’s real-life workflow to what can be configured and managed when using server. Every organization begins with a single environment called the _default environment, which cannot be modified (or deleted). Additional environments can be created to reflect each organization’s patterns and workflow. For example, creating production, staging, testing, and development environments. Generally, an environment is also associated with one (or more) cookbook versions.

という事。

## 設定方法

environmentのpathを指定します。

	$ vim .chef/knife.rb
	environment_path "environments"

	$ mkdir environments
	
するとこんな感じ。

	$ tree . -L 1
	.
	├── Berksfile
	├── Berksfile.lock
	├── Gemfile
	├── Gemfile.lock
	├── LICENSE
	├── README.md
	├── Thorfile
	├── Vagrantfile
	├── chefignore
	├── cookbooks
	├── data_bags
	├── environments
	├── metadata.rb
	├── nodes
	├── roles
	└── site-cookbooks


次に設定ファイルを作ります。

形式はrubyでもjsonでもok

ruby
	
	name "environment_name"
	description "environment_description"
	cookbook OR cookbook_versions  "cookbook" OR "cookbook" => "cookbook_version"
	default_attributes "node" => { "attribute" => [ "value", "value", "etc." ] }
	override_attributes "node" => { "attribute" => [ "value", "value", "etc." ] }

json

	{
	  "name": "dev",
	  "default_attributes": {
	    "apache2": {
	      "listen_ports": [
	        "80",
	        "443"
	      ]
	    }
	  },
	  "json_class": "Chef::Environment",
	    "description": "",
	    "cookbook_versions": {
	    "couchdb": "= 11.0.0"
	  },
	  "chef_type": "environment"
  }


動的にenviromentを指定する事も可能。

	$ knife exec -E 'nodes.transform("chef_environment:dev") { |n| n.chef_environment("production") }'

