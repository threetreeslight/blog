+++
date = "2012-10-01T08:55:04+00:00"
draft = false
tags = ["model", "rails", "default"]
title = "[rails][model]hoge.rbによるdefault valueの設定"
+++
<p>migrationファイルに書くのが一番良いんだけど、ちょっと思う所が有ったのでmodelファイルにてデフォルト値設定を行いたいと思った。</p>&#13;
<p><br />実行する方法はいくつか有ると思うけど、何がベストかなーと思って検索すると、これでいいんじゃねっていう方法がstack over flowに乗っていたので転載します。</p>&#13;
&#13;
<pre>class Person&#13;
  has_one :address&#13;
  after_initialize :init&#13;
&#13;
  def init&#13;
    self.number  ||= 0.0           #will set the default value only if it's nil&#13;
    self.address ||= build_address #let's you set a default association&#13;
  end&#13;
end    &#13;
</pre>&#13;
<p>参考<br /><a href="http://stackoverflow.com/questions/328525/what-is-the-best-way-to-set-default-values-in-activerecord">what-is-the-best-way-to-set-default-values-in-activerecord</a></p> 