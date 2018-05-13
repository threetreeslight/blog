+++
date = "2013-11-12T09:14:00+00:00"
draft = false
tags = ["git", "svn", "submodule"]
title = "git-svnだとgit submoduleをよしなにされない。"
+++
掲題の所為で、めちゃくちゃgit rebaseで歴史改竄することになった。


	$ git svn dcommit
	...
	9c39d447e3e53d969a370f8fd02529488fa71a8f doesn't exist in the repository at /opt/boxen/homebrew/Cellar/git/1.8.2.3-boxen1/lib/Git/SVN/Editor.pm line 395.
	Failed to read object 9c39d447e3e53d969a370f8fd02529488fa71a8f at /opt/boxen/homebrew/Cellar/git/1.8.2.3-boxen1/libexec/git-core/git-svn line 996.

気をつけましょう。

[using-git-submodules-in-a-git-svn-project](http://stackoverflow.com/questions/4519679/using-git-submodules-in-a-git-svn-project)

> ## Using git submodules in a git-svn project
> 
> answer:
> 
> You can't do this, git submodules can't be pushed upstream into a svn repository via git-svn, it doesn't support this.
> 
> comment: 
> 
> Yeah, we meanwhile moved our entire source code to a paid GitHub account. Problem solved.

わろた