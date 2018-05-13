+++
date = "2013-05-21T08:19:00+00:00"
draft = false
tags = ["rails", "p3p", "privacy", "policy", "IE", "security"]
title = "[rails]P3P privacy policyの設定"
+++
3rd-party-cookiesの受け入れについて、IEでp3p privacy policyを設定する必要が有る。

## IEのセキュリティ
***

IEではデフォルトのprivacy security設定がmediumになっており、その内容は以下の通り

* Blocks third party cookies that do not have a compact privacy policy
* Blocks third-party cookies that save infromation that can be used to contact you without your explicit consent
* Restricts first-party cookies that save infromation that can be used to contact you without your implicit consent

最初のヤツが問題。

[p3p privacy policyについて](http://msdn.microsoft.com/ja-jp/library/ms537341)

## 設定方法
***

httpリクエストヘッダーにp3p privacy policyの設定方法は以下の通り。

1. P3Pポリシー参照ファイルを作成して、周知の存在場所(/w3c/p3p.xml)に置く
2. P3Pポリシーからコンパクトポリシーを作成してHTTPヘッダで出力するようにする

要は2のcompact policyをhttpヘッダに乗っければ良いので、それだけ対応すると以下の通りになる。


	class ApplicationController &lt; ActionController::Base
	  ...
	  def ie_p3p_fix
	   if request.env["HTTP_USER_AGENT"] =~ /MSIE/
	      response.headers["P3P"] = 'CP="CAO PSA OUR"'
	   end
	  end
	  before_filter :ie_p3p_fix
	  ...

参照: [Facebook Signed Request を Ruby on Rails で扱う](http://d.hatena.ne.jp/aquarla/20110517/1305608668)


しかし、上記だと全てのだけだと304レスポンス時には付与されない。
IEのとき、304レスポンスであってもP3P privacy policy headerがついていないとsessionを破棄されてしまう模様。

参照: [P3P header hell](http://robanderson123.wordpress.com/2011/02/25/p3p-header-hell/)


## 304 response
***

304 responseの判断は、ETagで行っている。
railsではdefaultでETagの付与されているため、IEのときだけETagを無効化する必要が有る。

[P3P header hell](http://robanderson123.wordpress.com/2011/02/25/p3p-header-hell/)よりコピペ。


	module ActionController
	  class Request
	    alias_method :etag_matches_original?, :etag_matches?
	     
	    def etag_matches?(etag)
	      !env['HTTP_USER_AGENT'].include?('MSIE') &amp;&amp; etag_matches_original?(etag)
	    end
	  end
	  
	  class Response
	    alias_method :etag_original?, :etag?
	     
	    def etag?
	      request.env['HTTP_USER_AGENT'].include?('MSIE') || etag_original?
	    end
	  end
	end
	
もしくは

[Cookies in iFrames: how bashing my head on the table made them work in Internet Explorer](http://tempe.st/tag/ruby-on-rails/)よりコピペ

	module ActionController
	  class Request
	    def etag_matches?(etag)
	      false
	    end
	  end
	 
	  class Response
	    def etag?
	      true
	    end
	  end
	end


## 当てはまるパターン
***

facebookのログイン状態を保持したい場合などは、3rd-party-cookiesでsession管理を行う事になる。

e.g.) iframeで動作するfacebook canvas app

3rd-partyに該当するドメインからのアクセスにてセッション管理する必要がない場合は、ETagの無効化は不要。

## P3P private poricyの忘れないように
***

rack appとしてgithubに公開されているモジュールがあるので、こちらを利用する事も可能（簡単なスクリプトですが）。

[hoopla / rack-p3p](https://github.com/hoopla/rack-p3p)

よくgem fileだけ新しいアプリケーションに継承するので。

## P.S.
***

本来はgoogle analyticsのようにfirst party cookiesとして埋め込むのが良いのだろうけどね。


## お勧めの参考文献
***
<p>
<iframe src="http://rcm-jp.amazon.co.jp/e/cm?lt1=_blank&amp;bc1=000000&amp;IS2=1&amp;bg1=FFFFFF&amp;fc1=000000&amp;lc1=0000FF&amp;t=ae06710-22&amp;o=9&amp;p=8&amp;l=as4&amp;m=amazon&amp;f=ifr&amp;ref=ss_til&amp;asins=4774142042" style="width:120px;height:240px;" scrolling="no" marginwidth="0" marginheight="0" frameborder="0"></iframe>
</p>