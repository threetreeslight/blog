+++
date = "2012-11-23T03:51:00+00:00"
draft = false
tags = ["node", "nvm"]
title = "[node]node.jsのインストール"
+++
<p>何となくnode.js for macのインストール方法を。</p>&#13;
<p>require</p>&#13;
<ul><li>mac OS X</li>&#13;
<li>Homebrew</li>&#13;
</ul><pre>$ git clone git://github.com/creationix/nvm.git ~/nvm&#13;
&#13;
(if you installed node, remove this.)&#13;
$ brew uninstall node&#13;
&#13;
$ nvm ls&#13;
       N/A&#13;
current: 	v0.6.14&#13;
&#13;
$ nvm install 0.8.14&#13;
######################################################################## 100.0%&#13;
Checksums do not match.&#13;
Binary download failed, trying source.&#13;
Additional options while compiling: &#13;
######################################################################## 100.0%&#13;
Checking for program g++ or c++          : /usr/bin/g++ &#13;
Checking for program cpp                 : /usr/bin/cpp &#13;
Checking for program ar                  : /usr/bin/ar &#13;
Checking for program ranlib              : /usr/bin/ranlib &#13;
Checking for g++                         : ok  &#13;
Checking for program gcc or cc           : /usr/bin/gcc-4.2 &#13;
Checking for gcc                         : ok  &#13;
Checking for library dl                  : yes &#13;
Checking for openssl                     : yes &#13;
Checking for library util                : yes &#13;
Checking for library rt                  : not found &#13;
Checking for fdatasync(2) with c++       : no &#13;
...&#13;
&#13;
$ vim ~/.bashrc&#13;
if [[ -f $HOME/nvm/nvm.sh ]]; then&#13;
  . ~/nvm/nvm.sh&#13;
  nvm use 0.8.14&#13;
  export NODE_PATH=${NVM_PATH}_modules${NODE_PATH:+:}${NODE_PATH}&#13;
fi&#13;
&#13;
$ source ~/.bashrc&#13;
&#13;
</pre>&#13;
<p>ライブラリー無いよ言われているけどsuccessしているから気にしない。</p>&#13;
<p>参考：</p>&#13;
<ul><li><a href="https://github.com/creationix/nvm">https://github.com/creationix/nvm</a></li>&#13;
</ul><p><br /><br />次はサンプルプログラムを動かしてみる</p>&#13;
<pre>% vim hoge/example.js&#13;
&#13;
var http = require('http');&#13;
http.createServer(function (req, res) {&#13;
  res.writeHead(200, {'Content-Type': 'text/plain'});&#13;
  res.end('Hello World\n');&#13;
}).listen(1337, '127.0.0.1');&#13;
console.log('Server running at http://127.0.0.1:1337/');&#13;
&#13;
$ node example.js&#13;
Server running at http://127.0.0.1:1337/&#13;
&#13;
</pre>&#13;
<p>http://127.0.0.1:1337/　にアクセスしてHellow Worldが表示されれば完了！</p>&#13;
<p><br />参考</p>&#13;
<ul><li><a href="http://nodejs.org/">http://nodejs.org/</a></li>&#13;
</ul>