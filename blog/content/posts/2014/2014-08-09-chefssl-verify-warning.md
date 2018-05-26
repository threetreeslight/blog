+++
date = "2014-08-09T10:15:39+00:00"
draft = false
tags = ["chef"]
title = "chefのssl verify warning"
+++
man in the middle atack対策として、chef 11.12系からssl verifyが出来るようになった様です。

> SSL validation of HTTPS requests is disabled. HTTPS connections are still
> encrypted, but chef is not able to detect forged replies or man in the middle
attacks.
> 
> To fix this issue add an entry like this to your configuration file:
> 
> ```
>   # Verify all HTTPS connections (recommended)
>   ssl_verify_mode :verify_peer
> 
>   # OR, Verify only connections to chef-server
>   verify_api_cert true
> ```
> 
> To check your SSL configuration, or troubleshoot errors, you can use the
> `knife ssl check` command like so:
> 
> ```
>   knife ssl check -c /home/webadmin/chef-solo/solo.rb
> ```

ワーニングを放置するのもうざいので、言われた通り設定します。

## 対応

	$ vim .chef/knife.rb
	
	ssl_verify_mode :verify_peer

これでok
