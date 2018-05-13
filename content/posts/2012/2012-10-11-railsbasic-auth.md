+++
date = "2012-10-11T16:28:11+00:00"
draft = false
tags = ["rails", "basic auth", "authenticate", "auth"]
title = "[rails]特定の環境のみbasic auth"
+++
<p>綺麗な方法がRails Castに乗ってた。</p>&#13;
<pre>class ApplicationController &lt; ActionController::Base&#13;
  before_filter :authenticate_if_staging&#13;
&#13;
private&#13;
  def authenticate_if_staging&#13;
    if Rails.env == 'staging' # or request.host == 'staging.hogehoge.com'&#13;
      authenticate_or_request_with_http_basic 'Staging' do |name, password|&#13;
        name == 'username' &amp;&amp; password == 'secret'&#13;
      end&#13;
    end&#13;
  end&#13;
&#13;
end&#13;
</pre>&#13;
 