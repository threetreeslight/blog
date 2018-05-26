+++
date = "2013-01-19T14:03:00+00:00"
draft = false
tags = ["brew", "homebrew", "PHP", "php", "package", "composer", "pear"]
title = "[PHP]brew + php composerを利用したpackage管理"
+++
<p>PHPでは依存、プラグイン管理の仕組みでcomposerのが一番いけてそう。<br /><span>rubyでいうbundler。</span></p>&#13;
<p><span><br />MACを使っている事もあるので、brewでグローバルインストールしたい。 </span></p>&#13;
<p>どっからでも新しいプロジェクト作れるように。</p>&#13;
<p>require</p>&#13;
<ul><li><span>PHP5.4.x</span></li>&#13;
<li><span>phpenv</span></li>&#13;
<li><span>php-build</span></li>&#13;
</ul><div><br />install composer</div>&#13;
<pre>$ brew search php&#13;
$ brew install composer&#13;
Missing PHP53 or PHP54 from homebrew-php. Please install one or the other before continuing&#13;
Error: An unsatisfied requirement failed this build.&#13;
</pre>&#13;
<p><br />だめぽ。brewのrequirementを見てみる。</p>&#13;
<pre>$ cat ./composer-requirement.rb<br />require File.join(File.dirname(__FILE__), 'homebrew-php-requirement')&#13;
&#13;
class ComposerRequirement &lt; HomebrewPhpRequirement&#13;
  COMMAND = 'curl -s http://getcomposer.org/installer | /usr/bin/env php -d allow_url_fopen=On -d detect_unicode=Off -d date.timezone=UTC -- --check'&#13;
&#13;
  def satisfied?&#13;
    @result = `#{COMMAND}`&#13;
    @result.include? "All settings correct"&#13;
  end&#13;
&#13;
  def message&#13;
      result_indented = @result.to_s.sub(/^#!.*\n/, '').gsub(/\n^/, "\n    ")<br />  end<br /><br />end &#13;
&#13;
$ curl -s http://getcomposer.org/installer | /usr/bin/env php -d allow_url_fopen=On -d detect_unicode=Off -d date.timezone=UTC -- --check&#13;
#!/usr/bin/env php&#13;
All settings correct for using Composer&#13;
</pre>&#13;
<p><br />composerのrequirementは通っている。<br />じゃぁphp-meta-requirementをきっちゃえーってことで。</p>&#13;
<pre>$ cd /usr/local/Library/Taps/josegonzalez-php/Formula&#13;
$ cp -p composer.rb composer.rb.old&#13;
$ vim ./composer.rb&#13;
- require File.join(HOMEBREW_LIBRARY, 'Taps', 'josegonzalez-php', 'Requirements', 'php-meta-requirement')&#13;
&#13;
- depends_on PhpMetaRequirement.new&#13;
</pre>&#13;
<p><br />もう一度インストール</p>&#13;
<pre>$ brew install composer&#13;
==&gt; Downloading http://getcomposer.org/download/1.0.0-alpha6/composer.phar&#13;
######################################################################## 100.0%&#13;
==&gt; Caveats&#13;
Verify your installation by running:&#13;
  "composer --version".&#13;
&#13;
You can read more about composer and packagist by running:&#13;
  "brew home composer".&#13;
==&gt; Summary<br />/usr/local/Cellar/composer/1.0.0-alpha6: 3 files, 628K, built in 22 seconds&#13;
&#13;
&#13;
$ composer -version &#13;
Composer version 1.0.0-alpha6&#13;
</pre>&#13;
<p><br />通ったうれしい。</p> 