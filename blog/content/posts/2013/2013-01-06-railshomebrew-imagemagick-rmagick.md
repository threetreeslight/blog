+++
date = "2013-01-06T13:49:26+00:00"
draft = false
tags = ["imageMagic", "rmagick", "minimagick", "homebrew", "brew"]
title = "[rails]homebrew + ImageMagick + Rmagick"
+++
<p>homebrewでimageMagickを入れたい！第２弾。</p>&#13;
<p>前回はMackportという代打で依存系もごっそり入れる謎によって解決しましたが、新しいMBAを入手したこともあり、きれいな開発環境を維持使用と思いbrewでimageMagickを入れたいと思います。</p>&#13;
<p>そして、予想通りのエラー。</p>&#13;
<pre>Gem::Installer::ExtensionBuildError: ERROR: Failed to build gem native extension.&#13;
&#13;
        /Users/akira/.rvm/rubies/ruby-1.9.3-p362/bin/ruby extconf.rb &#13;
checking for Ruby version &gt;= 1.8.5... yes&#13;
extconf.rb:128: Use RbConfig instead of obsolete and deprecated Config.&#13;
checking for clang... yes&#13;
checking for Magick-config... yes&#13;
checking for ImageMagick version &gt;= 6.4.9... yes&#13;
checking for HDRI disabled version of ImageMagick... yes&#13;
checking for stdint.h... yes&#13;
checking for sys/types.h... yes&#13;
checking for wand/MagickWand.h... yes&#13;
checking for InitializeMagick() in -lMagickCore... no&#13;
checking for InitializeMagick() in -lMagick... no&#13;
checking for InitializeMagick() in -lMagick++... no&#13;
Can't install RMagick 2.13.1. Can't find the ImageMagick library or one of the dependent libraries. Check the mkmf.log file for more detailed information.&#13;
</pre>&#13;
<p><br />あきらめずに調べると、<br /><br />rmagickが読めないオブジェクトがあるので、./configureオプションで--with-sharedを追加してあげればよいとのこと。</p>&#13;
<p><br /><a href="http://stackoverflow.com/questions/131179/error-installing-rmagick-from-gem">http://stackoverflow.com/questions/131179/error-installing-rmagick-from-gem</a></p>&#13;
<p><br />homebrewでどうやるのか調べてみると、元いじる感じ。</p>&#13;
<p><a href="https://github.com/mxcl/homebrew/commits/master/Library/Formula/imagemagick.rb">https://github.com/mxcl/homebrew/commits/master/Library/Formula/imagemagick.rb</a></p>&#13;
<p><br /> せっかくだし最新のコミットログみよーと思って、中をのぞいてみると、同じエラーお困りの方あり。</p>&#13;
<p><a href="https://github.com/mxcl/homebrew/commit/883f5493d87e17b6c0a25a194a16988d43884214">https://github.com/mxcl/homebrew/commit/883f5493d87e17b6c0a25a194a16988d43884214</a></p>&#13;
<p>結論をだけいうと、</p>&#13;
<blockquote>&#13;
<p>rmagick全然更新されてないから、minimagick使うといいよ。</p>&#13;
</blockquote>&#13;
<p>ということ。</p>&#13;
&#13;
<p><br />とりあえず通ったしいいかな。</p>&#13;
 