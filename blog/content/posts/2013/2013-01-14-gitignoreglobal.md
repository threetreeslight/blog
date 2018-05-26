+++
date = "2013-01-14T03:18:15+00:00"
draft = false
tags = ["git", "gitignore"]
title = "gitignoreのglobal設定"
+++
<p>gitignoreのglobal設定</p>&#13;
<pre>$ git config --global core.excludesfile ~/.gitignore_global&#13;
$ cd&#13;
$ vim ./.gitignore_global&#13;
&#13;
# mac&#13;
.DS_Store&#13;
*.sublime-*&#13;
&#13;
</pre> 