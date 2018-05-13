+++
date = "2013-04-21T13:16:15+00:00"
draft = false
tags = ["google", "web master tool", "WMT", "heroku", "sitemap"]
title = "herokuのsitemap.xmlをgoogle web master toolで認識させる"
+++
sitemap generator通り、S3にfogを使ってアップロードし、robots.txtにsitemapの参照先を記述すれば良い。

	sitemap: url
	

### bing web master tool
***

assets.hoge.com等のサブドメインをS3に割当れば認識させる事が出来る。

### google web master tool
***

google web master toolではsitemapが同じドメイン（サブドメインも含む）で見えないのが気持ち悪い。そのため、/sitemap.xmlのアクセス時にリダイレクトさせる。

	 def sitemap
	   respond_to do |format|
	     format.html # sitemap.html.erb
	     format.xml { redirect_to 'url' }
	   end
	 end


最終的にgoogle web master toolに合わせれば良かったと思ってる。
ので直しました。