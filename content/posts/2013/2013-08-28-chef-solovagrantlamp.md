+++
date = "2013-08-28T08:05:00+00:00"
draft = false
tags = ["chef", "chef-solo", "ruby", "vagrant", "vertual box"]
title = "chef-soloでvagrant上の仮想サーバーにLAMP環境作る"
+++
基本はdotinstall先生でやった事や、本に書いてあった事をメモる。


## workstationの設定（chefをインストール）
***

[LEAN CHEF - Workstation Setup](https://learnchef.opscode.com/quickstart/workstation-setup/)

require

* ruby 2.0.0
* rbenv
* bundler

いれてきます。

	$ mkdir chef-temp
	$ cd chef-temp
	$ vim .ruby-version
	2.0.0-p247

	$ vim .gitignore
	*.gem
	*.rbc
	.bundle
	/vendor/bundle
	.config
	coverage
	InstalledFiles
	lib/bundler/man
	pkg
	rdoc
	spec/reports
	test/tmp
	test/version_tmp
	tmp
	
	# YARD artifacts
	.yardoc
	_yardoc
	doc/
	
	# vagrant
	/vendor/vagrant


	$ vim Gemfile
	source 'https://rubygems.org'

	gem 'chef'
	gem 'knife-solo'

	$ bundle install --path vendor/bundle
	$ be knife -v	
	Chef: 11.6.0
	
	$ be knife configure
	ひたすらエンター
	
## nodeの設定
***

require 

* virtual box
* vagrant
* CentOS 64

必要に応じてcentos 6.4をvagrantに追加

	$ vagrant box add http://developer.nrel.gov/downloads/vagrant-boxes/CentOS-6.4-x86_64-v20130427.box

設定

	$ mkdir vendor/vargrant
	$ cd vendor/vargrant
	$ vagrant init centos64
	A `Vagrantfile` has been placed in this directory. You are now
	ready to `vagrant up` your first virtual environment! Please read
	the comments in the Vagrantfile as well as documentation on
	`vagrantup.com` for more information on using Vagrant.
	
ローカルからアクセスできるよう設定。

	$ vim Vagrantfile
	…
	  # Create a private network, which allows host-only access to the machine
	  # using a specific IP.
	  config.vm.network :private_network, ip: "192.168.33.20"
	…

入れます。

	$ vagrant up
	$ vagrant status
	The VM is running. To stop this VM, you can run `vagrant halt` to
	shut it down forcefully, or you can run `vagrant suspend` to simply
	suspend the virtual machine. In either case, to restart it again,
	simply run `vagrant up`.

sshでアクセスできるようにする。名前はharmony

	$ vagrant ssh-config --host harmony >> $HOME/.ssh/config
	Host harmony
	  HostName 127.0.0.1
	  User vagrant
	  Port 2222
	  UserKnownHostsFile /dev/null
	  StrictHostKeyChecking no
	  PasswordAuthentication no
	  IdentityFile /Users/hogehoge/.vagrant.d/insecure_private_key
	  IdentitiesOnly yes
	  LogLevel FATAL
	  
	 $ ssh harmony
	 Welcome to your Vagrant-built virtual machine.
	[vagrant@localhost ~]$
	
ok. 

## 次はworkstationにchefのリポジトリを作る。
***

さっき作ったchef-temp内でchef初期化

	$ knife solo init chef-repo

Nodeをchef対応させる

	$ cd chef-repo
	$ knife solo prepare harmony
	Bootstrapping Chef...
	  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
	                                 Dload  Upload   Total   Spent    Left  Speed
	101  6790  101  6790    0     0   1125      0  0:00:06  0:00:06 --:--:-- 19511
	Downloading Chef 11.6.0 for el...
	Installing Chef 11.6.0
	warning: /tmp/tmp.1GErnvHQ/chef-11.6.0.x86_64.rpm: Header V4 DSA/SHA1 Signature, key ID 83ef826a: NOKEY
	Preparing...                ########################################### [100%]
	   1:chef                   ########################################### [100%]
	Thank you for installing Chef!
	Generating node config 'nodes/harmony.json'...

## Cookbookを作る
***

テンプレート作成

	$ knife cookbook create hello -o site-cookbooks

hello worldとlogに出力するように

	$ vim site-cookbooks/hello/recipes/default.rb
	log "hello world"

実行設定

	$ vim node/harmony.json
	{
	  "run_list":[
	    "recipe[hello]"
	  ]
	}

## 反映！
***

	$ knife solo cook harmony
	Running Chef on harmony...
	Checking Chef version...
	Uploading the kitchen...
	Generating solo config...
	Running Chef...
	Starting Chef Client, version 11.6.0
	Compiling Cookbooks...
	Converging 1 resources
	Recipe: hello::default
	  * log[hello world] action write
	
	Chef Client finished, 1 resources update


hello world。

## もう少しちゃんと設定
***

やりたい事はvagrantの仮想サーバーに

1. php, mysql, apacheを入れる
2. apacheの起動及びrestart時の自動起動
3. httpd.confの設定
4. httpd.confが変更されたときに自動でrestartする
5. 確認用にindex.htmlファイルを配置する


設定

	$ vim site-cookbooks/hello/recipes/default.rb
	%w{php mysql-server httpd}.each do |p| # <- 1
	  package p do
	    action :install
	  end
	end

	# httpd -k start
	# chkconfig httpd on
	service "httpd" do # <- 2
	  action [:start, :enable]
	end

	template "httpd.conf" do # <- 3
	  path "/etc/httpd/conf/httpd.conf"
	  source "httpd.conf.erb"
	  mode 0644
	  notifies :restart, 'service[httpd]' # <- 4
	end

	template "index.html" do # <- 5
	  path "/var/www/html/index.html"
	  source "index.html.erb"
	  mode 0644
	end

httpd.confどっかから持ってきてtemplate化

	$ vim site-cookbooks/hello/templates/default/httpd.conf.erb
	…
	Listen <%= node[:httpd][:port] %>
	…
	
あと、index.htmlファイルを配置

	$ vim site-cookbooks/hello/templates/default/index.html.erb
	
	<html> hello world! </html>

templateの変数を実行ファイルに記述

	$ vim node/harmony.json
	{
	  "httpd": {
	    "port": 8000
	  },
	  "run_list":[
	    "recipe[hello]"
	  ]
	}

実行！

	$ knife solo cook harmony

確かめる。
	
	$ open http://192.168.33.20:8000/

おーらくちんらくちん

もう一回実行しても冪等性キープされてる

	$ knife solo cook harmony


## ohai
***

また、パラメータについては、ノードのシステム情報も引っ張る事が出来ます。
	
	$ be ohai -v
	Ohai: 6.18.0
	
	$ be ohai 
	ずらずらと。。。
	
システム情報持ってくる
	
	$ vim site-cookbooks/hello/templates/default/index.html.erb
	
	<html> hello from <%= node[:platform] %>! </html>

	$ knife solo cook harmony	
	$ open http://192.168.33.20:8000/
	
## 参考
***

dot install先生さまさま。いつもお世話になりっぱなしです。

* [Chef入門 (全14回)](http://dotinstall.com/lessons/basic_chef)

package等のresourcesについては以下のwebを確認。

* [Resources and Providers Reference](http://docs.opscode.com/chef/resources.html)

あーインフラの構築方法を忘れてしまいそうになるぐらいの楽さだわ・・・

