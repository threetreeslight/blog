+++
date = "2014-03-01T06:28:18+00:00"
draft = false
tags = ["curl", "SSL", "certificate", "problem"]
title = "error: SSL certificate problem: Invalid certificate chain while accessing発生時の対応"
+++
いきなりgit pushが通らない！

	error: SSL certificate problem: Invalid certificate chain while accessing
	
こんなエラーで苦しめられました。

## 考えられる原因その１

大体悪いヤツはMavericksの友達。

curlのバージョンが上がるせいか、--certと--cacertがぶっ壊れる。

[Important note for curl users on OS X Mavericks 10.9](http://curl.haxx.se/mail/archive-2013-10/0036.html)

> Mavericks:
> curl 7.30.0 (x86_64-apple-darwin13.0) libcurl/7.30.0 SecureTransport zlib/1.2.5
> 
> Mountain Lion:
> curl 7.24.0 (x86_64-apple-darwin12.0) libcurl/7.24.0 OpenSSL/0.9.8y zlib/1.2.5
> 
> TLDR: Mavericks moves from curl 7.24.0 to 7.30.0, and now --cacert and --cert are broken.
> 
> Wouldn't this break fetch.py in general for a lot of folks? I'm getting MacPorts up and running in Mavericks, in order to build newer curl and test further.
> 
> I'm also wondering if not having set any X509 Extended attributes is coming back to haunt me, based on this thread:
> 
> https://groups.google.com/d/msg/munki-dev/yPP_wvt-yaM/46FbcXhT1A4J
> 
> Any advice would be appreciated.


[Curl changes in Mavericks](https://groups.google.com/forum/#!topic/munki-dev/oX2xUnoQEi4)


## 考えられる原因その２

certファイルがexpireしている。

[](http://d.hatena.ne.jp/tmatsuu/20110614/1308010044)

## 解決策

どちらにしろcert入れ直し。

1. key chain accessから既存の`DigiCertHighAssuranceEVRootCA.crt`を削除
2. <https://www.digicert.com/digicert-root-certificates.htm>からDigiCert High Assurance EV Root CAをダウンロード
3. ダブルクリックしてkey chain accessに追加。

これで解決。

くれぐれも、以下のようにSSL no verifyにて解決しないように！

	$ export GIT_SSL_NO_VERIFY=true
