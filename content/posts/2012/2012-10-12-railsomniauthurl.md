+++
date = "2012-10-12T14:02:53+00:00"
draft = false
tags = ["omniauth", "rails", "callback", "user", "facebook"]
title = "[Rails][omniauth]ユーザーを元居たURLにリダイレクト"
+++
<p>Omniauthにてfacebook認証した後、ユーザーを元居たURLにリダイレクトする。</p>&#13;
&#13;
<p>view :</p>&#13;
<pre> "login" %&gt;&#13;
</pre>&#13;
<p>application_helper.rb :</p>&#13;
<pre>  def signup_url&#13;
    if params[:back_to].blank?&#13;
      '/auth/facebook'&#13;
    else&#13;
      '/auth/facebook?origin=' + params[:back_to]&#13;
    end&#13;
  end&#13;
</pre>&#13;
<p>sessions_controller.rb : </p>&#13;
<pre>  def callback&#13;
    ...&#13;
    redirect_to back_to || root_path<br />end&#13;
  end&#13;
&#13;
&#13;
  private&#13;
  &#13;
  def back_to&#13;
      if request.env['omniauth.origin'].presence &amp;&amp; back_to = CGI.unescape(request.env['omniauth.origin'].to_s)&#13;
        uri = URI.parse(back_to)&#13;
        return back_to if uri.relative? || uri.host == request.host&#13;
      end&#13;
      nil&#13;
    rescue&#13;
      nil&#13;
  end&#13;
</pre>&#13;
&#13;
<p>参考：<br /><a href="https://github.com/intridea/omniauth/wiki/Saving-User-Location">omniauth help</a></p>&#13;
 