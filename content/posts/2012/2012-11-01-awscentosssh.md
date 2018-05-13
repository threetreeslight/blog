+++
date = "2012-11-01T08:44:00+00:00"
draft = false
tags = ["AWS", "CentOS", "EC2", "RHL", "ssh", "keypair", "AMI", "Elastic IPs"]
title = "[AWS][CentOS]何となくシンガポールにサーバーを作ってsshログインまで"
+++
<p>EC2をシンガポールリージョン（東京より安いので）にCentOS6.3を立ててとりあえず最低限の設定してみる。<br /> </p>&#13;
<p><strong>KeyPairを作成</strong></p>&#13;
<p>webadminって名前で作ってみる。webadmin.pemの権限は400で。 </p>&#13;
<p><br /><strong>セキュリティグループの作成</strong></p>&#13;
<ul><li>web  / All public facing web (port 80 and 443( instances )</li>&#13;
<li>rule : tcp / port : 22 / source :0.0.0.0/0</li>&#13;
<li>rule : tcp / port : 80 / source :0.0.0.0/0</li>&#13;
<li>rule : tcp / port : 443 / source :0.0.0.0/0</li>&#13;
</ul><p><strong><br />AMIの選定</strong></p>&#13;
<p>２０１２年１１月１日現在最新のCentOS6.3のAMIを選定</p>&#13;
<p>ami-92084bc0 を利用してコンソールからlaunch!</p>&#13;
<p><strong><br />Elastic IPsの作成とassociate</strong></p>&#13;
<p>コンソールから作ってインスタンスに割当 </p>&#13;
<p><br /><strong>sshでログイン</strong></p>&#13;
<pre>ssh ./webadmin.pem root@xxx.xxx.xx.xx</pre>&#13;
<p><br /><strong>topとymlリストで状態確認</strong></p>&#13;
<pre># top&#13;
&#13;
top - 04:21:39 up 10 min,  1 user,  load average: 0.00, 0.00, 0.00&#13;
Tasks:  64 total,   1 running,  63 sleeping,   0 stopped,   0 zombie&#13;
Cpu(s):  0.0%us,  0.3%sy,  0.0%ni, 99.7%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st&#13;
Mem:    604836k total,    93372k used,   511464k free,     9628k buffers&#13;
Swap:     2040k total,        0k used,     2040k free,    33472k cached&#13;
&#13;
</pre>&#13;
<p>変なの動いてなさそう。 <br />※メモリを食べられていたりしたらinstallされているpackageを確認</p>&#13;
<pre># yml list installed</pre>&#13;
<p><a href="http://dqn.sakusakutto.jp/2012/09/amazonec2.html">http://dqn.sakusakutto.jp/2012/09/amazonec2.html</a></p>&#13;
<p><strong><br />webadminユーザーの追加とrootログインをPW無しに変更</strong></p>&#13;
<pre># useradd webadmin&#13;
# vim /etc/pam.d/su&#13;
- #auth            sufficient      pam_wheel.so trust use_uid&#13;
+ auth            sufficient      pam_wheel.so trust use_uid&#13;
# gpasswd -a webadmin wheel&#13;
# visudo&#13;
&#13;
## Allows people in group wheel to run all commands&#13;
- # %wheel        ALL=(ALL)       ALL&#13;
+ %wheel        ALL=(ALL)       ALL&#13;
&#13;
# getent shadow webadmin<br />webadmin:!!:...<br /># passwd -u -f webadmin</pre>&#13;
<p><a href="http://kumagonjp2.blog.fc2.com/blog-entry-61.html">http://kumagonjp2.blog.fc2.com/blog-entry-61.html</a></p>&#13;
<p><strong><br />aliasの設定</strong></p>&#13;
<pre># su webadmin&#13;
$ vim ~/.bashrc&#13;
alias ll='ls -la'&#13;
alias rm='rm -i'&#13;
alias vi='vim'&#13;
alias g='git'&#13;
alias be='bundle exec'&#13;
alias gg='git grep'&#13;
</pre>&#13;
<p><strong><br />ローカルユーザーの公開鍵でsshログイン設定</strong></p>&#13;
<pre># useradd hoge&#13;
# su hoge&#13;
$ mkdir ~/.ssh&#13;
$ vim ~/.ssh/authorized_keys&#13;
-&gt; ローカルの公開鍵をかいておく&#13;
$ chmod 600 ./.ssh/authorized_keys&#13;
$ chmod 700 ./.ssh<br /># getent shadow akira<br />akira:!!:...<br /># passwd -u -f akira&#13;
</pre>&#13;
<p><br /><strong>その他（元からamiの中にはいってた）</strong></p>&#13;
<p>yum-updateを止める</p>&#13;
<pre># yum-updatesd stop&#13;
# yum -y remove yum-updatesd&#13;
</pre>&#13;
<p>yumのインストールを高速化するために</p>&#13;
<pre># yum -y install yum-fastestmirror</pre>&#13;
<p>packageのupdate</p>&#13;
<pre># yum -y update&#13;
</pre>&#13;
<p>参考<br />http://www.a-magic-web.com/2009/04/vmware-centos-6/</p> 