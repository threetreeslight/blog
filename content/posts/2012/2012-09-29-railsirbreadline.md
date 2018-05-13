+++
date = "2012-09-29T09:05:00+00:00"
draft = false
tags = ["irb", "rails", "console", "readline"]
title = "[rails]irbが動かないのでreadline入れた"
+++
<p>rails consoleをAWSで動かそうとしたらこんなエラー出た。</p>&#13;
<pre>$ rails c<br />/var/www/.rvm/rubies/ruby-1.9.3-p194/lib/ruby/1.9.1/irb/completion.rb:9:in `require': cannot load such file -- readline (LoadError)&#13;
	from /var/www/.rvm/rubies/ruby-1.9.3-p194/lib/ruby/1.9.1/irb/completion.rb:9:in `'&#13;
	from /var/www/app/shared/bundle/ruby/1.9.1/gems/railties-3.2.8/lib/rails/commands/console.rb:3:in `require'&#13;
	from /var/www/app/shared/bundle/ruby/1.9.1/gems/railties-3.2.8/lib/rails/commands/console.rb:3:in `'&#13;
	from /var/www/app/shared/bundle/ruby/1.9.1/gems/railties-3.2.8/lib/rails/commands.rb:38:in `require'&#13;
	from /var/www/app/shared/bundle/ruby/1.9.1/gems/railties-3.2.8/lib/rails/commands.rb:38:in `'&#13;
	from script/rails:6:in `require'&#13;
	from script/rails:6:in `'&#13;
</pre>&#13;
<p>明日クローズドベータオープンなのにruby入れ直し・・・と思いながらドキドキしていたが、以下の作業ですんなり通った。</p>&#13;
<pre># <span>rvm package install readline<br /># </span><span>rvm remove 1.9.3<br /></span><span># rvm install 1.9.3<br />$ gem install rails</span></pre>&#13;
<p>参考</p>&#13;
<ul><li><a href="http://thekindofme.wordpress.com/2011/02/14/fixing-irbcompletion-rb9in-require-no-such-file-to-load-readline-loaderror-on-rvm/">Fixing: /irb/completion.rb:9:in `require’: no such file to load — readline (LoadError) on rvm</a></li>&#13;
</ul><p>ふぅ。。。。</p> 