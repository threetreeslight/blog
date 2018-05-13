+++
date = "2013-10-21T09:04:27+00:00"
draft = false
tags = ["git", "chef", "rbenv", "Permission denie"]
title = "[chef]unable to access '/vagrant/.config/git/config': Permission denied"
+++
まいったなー。と０．３日ぐらい使った。

require

* cent os 5.4
* git 1.8.2

problem
-------

rbenvの3rd party cookbookを利用してrubyをいれようとしていたらこけた。

	---- Begin output of git ls-remote sampleuser@samplehost:/path/myrepo.git HEAD ----
	STDOUT: 
	STDERR: fatal: unable to access '/vagrant/.config/git/config': Permission denied
	---- End output of git ls-remote sampleuser@samplehost:/path/myrepo.git HEAD ----
	Ran git ls-remote sampleuser@samplehost:/path/myrepo.git HEAD returned 128

以下のissueにもある。

[Chef::Provider::Git with user attribute queries /root/.conf/git/config](https://tickets.opscode.com/browse/CHEF-3940)


course
-----

犯人は、ヤス。もとい、もちろん犯人はgit

[git / Documentation / RelNotes /](https://github.com/git/git/tree/master/Documentation/RelNotes)

1.8系で必須ファイル系が変更されているのね。

安易な対策
--------

原因はgitのversionが高いから。

現在利用しているgitは、1.8.2 by epel経由。

このこをrpmforgeにある1.7.6に置き換えてあげるだけで良い。

	yum_package "git" do
	  version "1.7.6-1.el5.rf"
	  options "--enablerepo=epel,remi,rpmforge"
	end

こんな感じ。

根本的な解決
----------

gitconfigファイルが無いのが問題。

[Oops! fatal: unable to access '/root/.config/git/config': Permission denied](https://groups.google.com/forum/#!topic/gitlist/FB8DQhTZtQY)

> Same here.
>
> the solution in my case, maybe it will help someone,
I'm running uwsgi (1.9.12) in emperor mode
and since it is ran as root and dropping privileges to the user and group passes the root's environment
the HOME environment variable was set to /root
so it looked at /root/.gitconfig or /root/.config/git/config
since the unprivileged user didn't have access to /root
it threw an error.
> 
> So the solution was for me to set the HOME env to the user's HOME directory


というわけで、chefにここら辺を追加。

	template ".gitconfig" do
	  path "/home/vagrant/.gitconfig"
	  source ".gitconfig.erb"
	  owner "vagrant"
	  group "vagrant"
	  mode 0755
	end
	
	template ".gitignore_global" do
	  path "/home/vagrant/.gitignore_global"
	  source ".gitignore_global.erb"
	  owner "vagrant"
	  group "vagrant"
	  mode 0755
	end
	
よしなにnodeやattributesに追加して下さい。
