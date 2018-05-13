+++
date = "2013-08-30T05:24:28+00:00"
draft = false
tags = ["chef", "centos", "cent", "nginx", "epel", "yum"]
title = "centosにchefでnginxを入れようとするとこける"
+++
## 現状
***

cookbook作って
	
	$ knife cookbook create nginx -o cookbooks

設定
	
	$ vi cookbooks/nginx/recipes/default.rb
	package "nginx" do
	  action :install
	end
	
	$ vi localhost.json
	// localhost.json
	{
	  "run_list" : [
	    "nginx"
	  ]
	}
	
	$ vi solo.rb

	# solo.rb
	file_cache_path "/tmp/chef-solo"
	cookbook_path ["/home/vagrant/chef-repo/cookbooks"]

実行
	
	$ sudo chef-solo -c solo.rb -j ./localhost.json
	Starting Chef Client, version 11.6.0
	Compiling Cookbooks...
	Converging 1 resources
	Recipe: nginx::default
	  * package[nginx] action install
	    * No version specified, and no candidate version available for nginx
	================================================================================
	Error executing action `install` on resource 'package[nginx]'
	================================================================================
	
	
	Chef::Exceptions::Package
	-------------------------
	No version specified, and no candidate version available for nginx
	
	
	Resource Declaration:
	---------------------
	# In /home/vagrant/chef-repo/cookbooks/nginx/recipes/default.rb
	
	  9: package "nginx" do
	 10:   action :install
	 11: end
	 12:
	
	
	
	Compiled Resource:
	---------------

んん？？？？？
	
### 原因
***
	
` No version specified, and no candidate version available for nginx`ってことはもしや、、、

	$ yum info nginx
	Failed to set locale, defaulting to C
	Loaded plugins: fastestmirror
	Loading mirror speeds from cached hostfile
	 * base: www.ftp.ne.jp
	 * extras: www.ftp.ne.jp
	 * updates: www.ftp.ne.jp
	Error: No matching Packages to list

無い。remiとepel調べる
	
	$ yum info --enablerepo=remi nginx
	Failed to set locale, defaulting to C
	Loaded plugins: fastestmirror
	Loading mirror speeds from cached hostfile
	 * base: www.ftp.ne.jp
	 * extras: www.ftp.ne.jp
	 * remi: mirror.smartmedia.net.id
	 * updates: www.ftp.ne.jp
	Error: No matching Packages to list
	
	$ yum info --enablerepo=epel nginx
	Failed to set locale, defaulting to C
	Loaded plugins: fastestmirror
	Loading mirror speeds from cached hostfile
	 * base: www.ftp.ne.jp
	 * epel: ftp.kddilabs.jp
	 * extras: www.ftp.ne.jp
	 * updates: www.ftp.ne.jp
	Available Packages
	Name        : nginx
	Arch        : x86_64
	Version     : 1.0.15
	Release     : 5.el6
	Size        : 397 k
	Repo        : epel
	Summary     : A high performance web server and reverse proxy server
	URL         : http://nginx.org/
	License     : BSD
	Description : Nginx is a web server and a reverse proxy server for HTTP, SMTP, POP3 and
	            : IMAP protocols, with a strong focus on high concurrency, performance and low
	            : memory usage.

epelにあるのね。

### 対策
***

yumのリポジトリを追加も出来ればchefでやりたいよね。

というわけで、opscodeのcookbookを利用します。

[knife cookbook site](http://docs.opscode.com/knife_cookbook_site.html)

	$ knife cookbook site install yum -o cookbooks
	
	$ vi localhost.json
	// localhost.json
	{
	  "run_list" : [
	    "yum::epel",
	    "nginx"
	  ]
	}

これでepel入る。

できればepelの利用はdefaultなしにしたいので、それは後で。

とりあえずnginxのアクションにoptionを追加して実行。

	$ vi cookbooks/nginx/recipes/default.rb
	package "nginx" do
	  action :install
	  option '--enablerepo=epel'
	end
	

	$ sudo chef-solo -c solo.rb -j ./localhost.json
	Compiling Cookbooks...
	Converging 3 resources
	Recipe: yum::epel
	  * yum_key[RPM-GPG-KEY-EPEL-6] action add (up to date)
	  * yum_repository[epel] action add (up to date)
	Recipe: nginx::default
	  * package[nginx] action install
	    - install version 1.0.15-5.el6 of package nginx
	
	Chef Client finished, 1 resources updated
	
はいったぽ。

参考：[Chefでnginxを導入してみる](http://www.piyox.info/2013/04/16/chef-nginx/)
