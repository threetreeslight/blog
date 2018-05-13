+++
date = "2012-10-13T16:16:00+00:00"
draft = false
tags = ["rails", "i18n", "IP"]
title = "[Rails]Userのlocaleを取得して接続するサーバーを制御する"
+++
<p>一つのサーバーでお話しした内容を元に接続先のサーバーを制御したりするのに利用するため、Userのlocaleを意識した作りをしたいと思う。</p>&#13;
<p>方法としてはいくつか有る。</p>&#13;
<ol><li>接続先ドメイン名からの割り出し</li>&#13;
<li>サブドメインからの割り出し</li>&#13;
<li>HTTP_ACCEPT_LANGUAGEからの割り出し</li>&#13;
<li>IP addressからの割り出し</li>&#13;
<li>HTML5の現在地取得</li>&#13;
</ol><p>１と２については、ドメイン名は１種類、サブドメインは利用できない。<br />３もサーバーの接続先とブラウザの主要利用言語が地域と一致する訳ではないので利用は難しい。<br />５ではユーザーのアクセス許可が必要になる。（それは有り得ない）</p>&#13;
<p>という訳で実質的に４になる。</p>&#13;
<p>参考リンク先のコードをコピペさせて頂きつつ。</p>&#13;
<p><br />dat落としてlib配下にセット</p>&#13;
<ul><li><a href="http://www.maxmind.com/en/opensource">http://www.maxmind.com/en/opensource</a></li>&#13;
</ul><p><br />Gemfile</p>&#13;
<pre>gem 'geoip'&#13;
</pre>&#13;
<p><br />application_controller.rb</p>&#13;
<pre>class ApplicationController &lt; ActionController::Base&#13;
  require 'geoip'&#13;
  before_filter :set_locale&#13;
&#13;
  ...&#13;
&#13;
  private&#13;
&#13;
  def set_locale&#13;
    extracted_locale = extract_locale_from_ip&#13;
    I18n.locale = (I18n::available_locales.include? extracted_locale.to_sym) ? &#13;
                    extracted_locale : I18n.default_locale&#13;
  end&#13;
&#13;
  def extract_locale_from_ip&#13;
    @geoip ||= GeoIP.new(Rails.root.join("lib/GeoIP.dat")) &#13;
    country_location = @geoip.country(request.remote_ip) &#13;
    country_location.country_code2.downcase&#13;
  end&#13;
end&#13;
</pre>&#13;
<p><br />動いた。<br /><br />参考<br /><a href="http://guides.rubyonrails.org/i18n.html">http://guides.rubyonrails.org/i18n.html</a></p>&#13;
<p><a href="http://rails3try.blogspot.com/2011/12/rails3-i18n.html">http://rails3try.blogspot.com/2011/12/rails3-i18n.html</a> </p>&#13;
<p><a href="https://github.com/cjheath/geoip">https://github.com/cjheath/geoip</a></p>&#13;
&#13;
<p>P.S.</p>&#13;
<p>application_controllerにセットするのはCPUに負荷を掛ける事にしか成らないので、<br />単純に制御が必要な部分にだけ入れておくのが良いかもしれない。 </p> 