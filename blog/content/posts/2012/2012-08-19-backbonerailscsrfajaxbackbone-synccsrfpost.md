+++
date = "2012-08-19T12:28:00+00:00"
draft = false
tags = ["CSRF", "backbone", "rails", "ajax"]
title = "[backbone][rails][CSRF][ajax]backbone syncでcsrfタグもpostする方法"
+++
<p>backbone syncが$.ajaxのラッパークラスなので、やり方は色々ある様子。</p>&#13;
<p>調べた結果、csrfトークンが挟む方法として、toJsonに挟むのがお薦めの様子。</p>&#13;
<p>（まーbackbone-rails gemを利用すればいいよね？っていうのは今回無しで）</p>&#13;
<p><br />javascriptに以下のコマンドを追加する。</p>&#13;
<pre>var token = $('meta[name="csrf-token"]').attr('content');&#13;
Backbone.Model.prototype.toJSON = function() {&#13;
    return _(_.clone(this.attributes)).extend({&#13;
        authenticity_token: token&#13;
    });&#13;
};<span> </span></pre>&#13;
<p><br />参考：<a href="http://qiita.com/items/8fdef98329012255fa1d"><br />http://qiita.com/items/8fdef98329012255fa1d</a></p> 