+++
date = "2013-01-26T09:32:00+00:00"
draft = false
tags = ["instagram", "api"]
title = "instagram APIを利用してユーザーの写真表示してみる。"
+++
instagram APIを利用して自分写真を表示してみる。


友達がやろうとしてたので、ちょっとAPIをいじってみた。



### developer登録

http://instagram.com/developer

developer登録をして、client applicationを作成する。

ユーザー単位の写真を取得する場合は、Access tokenが必要になるので、
auth先にgeneratorを指定しておく。

http://jelled.com/instagram/access-token


### Application にauthしてAccess tokenを生成

http://jelled.com/instagram/access-token


### 実装

簡単なラッパーがあったのでそれを利用。

https://github.com/potomak/jquery-instagram

    
    
    
    <script src="http://code.jquery.com/jquery-1.9.0.min.js" type="text/javascript"></script>
    <script src="jquery.instagram.js" type="text/javascript"></script>
    <script type="text/javascript">
    $(function() {
    $(".instagram").instagram({userId: "999999999", clientId: 'hogehogehogehogehogehogehoge', accessToken: "foobarfoobarfoobar"
    });
    });
    </script>
    
    
    <div class="instagram"></div>
    
    
    

出るね。うんうん。
このやり方だとaccessTokenが丸見えになるので、やらないけど。
