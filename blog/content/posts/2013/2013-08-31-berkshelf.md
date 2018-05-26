+++
date = "2013-08-31T06:29:08+00:00"
draft = false
tags = ["berkshelf", "chef"]
title = "berkshelf導入"
+++
[berkshelf](http://berkshelf.com/)

berkshelfは、opscodeが公開している3rd partyのcookbookをrubyのbundlerのように管理が出来るツール。

[opscode community](http://community.opscode.com/)

いちいち


	$ knife cookbook site vendor yum

とかしなくて大丈夫。使い方も超シンプル


## vagrant
***


setting

	$ mkdir vagrant-berkshelf
	$ cd vagrant-chef
	$ vagrant init centos64
	$ vagrant up
	
ssh

	$ vagrant ssh-config --host harmony >> $HOME/.ssh/config
	$ ssh harmony
	vagrant %


## knife-solo init
***

	$ knife solo init chef-repo
	$ cd chef-repo
	$ vim Gemfile
	source 'https://rubygems.org'
	
	gem 'chef'
	gem 'knife-solo'
	gem 'berkshelf'
		
	$ bundle install --path vendor/bundle
	$ vim .gitignore
	*.gem
	*.rbc
	.bundle
	vendor/bundle
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
	
	# chef
	/cookbooks/
	vendor/cookbooks
	
	$ git add .
	$ git commit -am "Initial commit"
	

## berkshelf
***

	$ vim Berksfile
	site :opscode

	cookbook 'yum'
	cookbook 'mysql'
	cookbook 'nginx'

	$ berks install --path vendor/cookbooks
	Installing yum (2.3.2) from site: 'http://cookbooks.opscode.com/api/v1/cookbooks'
	Installing mysql (3.0.4) from site: 'http://cookbooks.opscode.com/api/v1/cookbooks'
	Installing nginx (1.8.0) from site: 'http://cookbooks.opscode.com/api/v1/cookbooks'
	Installing openssl (1.1.0) from site: 'http://cookbooks.opscode.com/api/v1/cookbooks'
	Installing build-essential (1.4.2) from site: 'http://cookbooks.opscode.com/api/v1/cookbooks'
	Installing apt (2.1.1) from site: 'http://cookbooks.opscode.com/api/v1/cookbooks'
	Installing runit (1.2.0) from site: 'http://cookbooks.opscode.com/api/v1/cookbooks'
	Installing ohai (1.1.12) from site: 'http://cookbooks.opscode.com/api/v1/cookbooks

	$ git add .
	$ git commit -am "Impl berkshelf"


## prepare and cook
***

	$ knife solo prepare harmony
	$ knife solo cook harmony
	
	
便利だ。