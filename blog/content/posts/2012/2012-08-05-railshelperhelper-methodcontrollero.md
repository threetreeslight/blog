+++
date = "2012-08-05T15:29:00+00:00"
draft = false
tags = ["rails", "helper", "method"]
title = "[rails][helper]helper methodをcontroller以外で探すo方法"
+++
<p>以下の通りです。</p>&#13;
<p><br />独自メソッドの場合</p>&#13;
<ul><li>ApplicationController.helpers.<em>methodname</em>()</li>&#13;
</ul><p>既存メソッドの場合</p>&#13;
<ul><li>ActionController::Base.helpers.asset_path(<em>image_name</em>)</li>&#13;
</ul><p>参考</p>&#13;
<ul><li><a href="http://www.pistolfly.jp/weblog/2010/03/helpercontrollerview.html">http://www.pistolfly.jp/weblog/2010/03/helpercontrollerview.html</a> </li>&#13;
<li><a href="http://stackoverflow.com/questions/7827078/access-asset-path-from-rails-controller">http://stackoverflow.com/questions/7827078/access-asset-path-from-rails-controller</a></li>&#13;
</ul>