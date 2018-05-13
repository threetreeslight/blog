+++
date = "2013-10-28T08:04:24+00:00"
draft = false
tags = ["OSX 10.9", "Mavericks", "git svn"]
title = "osx 10.9 Mavericksでgit svnが動かない。"
+++
git svnが動かない。まずい。

どうやら、SVNへのパスが何処にも見つからない模様。

	$ git svn rebase 
	Can't locate SVN/Core.pm in @INC (@INC contains: /opt/boxen/homebrew/Cellar/git/1.8.2.3-boxen1/lib /Library/Perl/5.16/darwin-thread-multi-2level /Library/Perl/5.16 /Network/Library/Perl/5.16/darwin-thread-multi-2level /Network/Library/Perl/5.16 /Library/Perl/Updates/5.16.2 /System/Library/Perl/5.16/darwin-thread-multi-2level /System/Library/Perl/5.16 /System/Library/Perl/Extras/5.16/darwin-thread-multi-2level /System/Library/Perl/Extras/5.16 .) at /opt/boxen/homebrew/Cellar/git/1.8.2.3-boxen1/lib/Git/SVN/Utils.pm line 6.
	
command line toolはいれており、SVNは存在する。

	$ svn --version
	svn, version 1.7.10 (r1485443)
	   compiled Aug 13 2013, 15:31:22

そうしたら、command line toolsで入れたSVNライブラリを、@INCの検索先であるライブラリのどこかへぶっ込む。

今回はperl 5.1.6の下へ入れます。

	$ sudo ln -s /Applications/Xcode.app/Contents/Developer/Library/Perl/5.16/darwin-thread-multi-2level/SVN /System/Library/Perl/Extras/5.16/SVN


すると、、、、

	$ git svn rebase 	
	Can't locate loadable object for module SVN::_Core in @INC (@INC contains: /opt/boxen/homebrew/Cellar/git/1.8.2.3-boxen1/lib /Library/Perl/5.16/darwin-thread-multi-2level /Library/Perl/5.16 /Network/Library/Perl/5.16/darwin-thread-multi-2level /Network/Library/Perl/5.16 /Library/Perl/Updates/5.16.2 /System/Library/Perl/5.16/darwin-thread-multi-2level /System/Library/Perl/5.16 /System/Library/Perl/Extras/5.16/darwin-thread-multi-2level /System/Library/Perl/Extras/5.16 .) at /System/Library/Perl/Extras/5.16/SVN/Base.pm line 59.
	
SVN::_Coreを繋いであげる。autoはあれか、SVNで使うモジュール群っぽいのだろうか。

何にせよ試す。

	$ sudo ln -s /Applications/Xcode.app/Contents/Developer/Library/Perl/5.16/darwin-thread-multi-2level/auto/SVN/ /System/Library/Perl/Extras/5.16/auto/SVN
	
これで勝てる！

	$ git svn rebase
	svnserve: warning: cannot set LC_CTYPE locale
	svnserve: warning: environment variable LC_CTYPE is UTF-8
	svnserve: warning: please check that your locale name is correct
	Current branch master is up to date.
	
勝った。


参考

[Solved: git svn Broken in Mavericks (or Mountain Lion)](http://blog.victorquinn.com/fix-git-svn-in-mountain-lion)