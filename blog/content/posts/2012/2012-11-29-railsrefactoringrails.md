+++
date = "2012-11-29T07:56:16+00:00"
draft = false
tags = ["rails", "tuning", "refactoring"]
title = "[rails][refactoring]railsのボトルネック探しツール"
+++
<p>railsを実装しているときに、N+1問題回避するためにincludeしたり、処理をかき変えたりするが、やるんだったら最小で最大の効果を上げたい。</p>&#13;
<p>むしろ意味の無い所のチューニングには時間を費やしたくない。</p>&#13;
<p>そんなときにお薦めなツールをQiitaで見つけたのでご紹介</p>&#13;
<p><br /><strong>miniprofiler</strong></p>&#13;
<p>各ページ表示やSQLの処理時間を計測し、表示してくれるツール。</p>&#13;
<pre>class ApplicationController &lt; ActionController::Base&#13;
  protect_from_forgery&#13;
  &#13;
  before_filter :miniprofiler&#13;
  &#13;
  private&#13;
  def miniprofiler&#13;
    if Rails.env.development? || (current_user.try(:role) == "admin")&#13;
      Rack::MiniProfiler.authorize_request&#13;
    end&#13;
  end&#13;
&#13;
end</pre>&#13;
<p><a href="http://railscasts.com/episodes/368-miniprofiler?view=asciicast">http://railscasts.com/episodes/368-miniprofiler?view=asciicast</a></p>&#13;
<p><br /><strong>bullet</strong></p>&#13;
<p>N+1問題が発生しているSQLをlog/bullet.logに吐いてくれる</p>&#13;
<pre>Gemfile&#13;
&#13;
group :development&#13;
+ gem "bullet"&#13;
end&#13;
<span> </span></pre>&#13;
<p><a href="https://github.com/flyerhzm/bullet">https://github.com/flyerhzm/bullet</a></p>&#13;
<p><a href="http://railscasts.com/episodes/372-bullet">http://railscasts.com/episodes/372-bullet</a></p>&#13;
<p><br /><br /><br />参考</p>&#13;
<p><a href="http://qiita.com/items/f6ab4cf3c8541fc4da83?utm_source=Qiita+Newsletter+Users&amp;utm_campaign=67f0866014-Qiita_newsletter_27_11_21_2012&amp;utm_medium=email">http://qiita.com/items/f6ab4cf3c8541fc4da83?utm_source=Qiita+Newsletter+Users&amp;utm_campaign=67f0866014-Qiita_newsletter_27_11_21_2012&amp;utm_medium=email</a></p> 