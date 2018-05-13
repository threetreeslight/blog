+++
date = "2012-08-07T08:48:16+00:00"
draft = false
tags = ["rails", "gem", "install"]
title = "[rails][gem]installするときに起こるミス"
+++
<p>gemを入れて、installするときに以下のerrorが発生する事が有る。</p>&#13;
<p><strong><br />error<br /></strong>/Users/<em>hogehoge</em>/.rvm/gems/ruby-1.9.3-p0@mashroom/gems/thor-0.15.4/lib/thor/actions/inject_into_file.rb:99:in `binread': No such file or directory - /<em>hogehogehoge</em>/app/assets/javascripts/application.js (Errno::ENOENT)</p>&#13;
&#13;
<p><br />原因は至極単純で、例えば・・・</p>&#13;
<ol><li>routes.rbファイルを理由があって分けていたり</li>&#13;
<li>application.cssをscssを適用するために"application.css.scss"にしていたり</li>&#13;
<li>application.jsにcoffeescriptを適用するために、"application.js.coffee.erb"としていたり</li>&#13;
</ol><p>などなど、つまりデフォルトのファイルが無いから怒られる。</p>&#13;
<p>こういうときは、暫定的にemptyな怒られたファイルを創る。<br />上記エラーの場合は、emptyなapplication.jsを 作成したら通る。</p>&#13;
 