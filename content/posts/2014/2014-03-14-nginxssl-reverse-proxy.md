+++
date = "2014-03-14T08:20:38+00:00"
draft = false
tags = ["nginx", "ssl", "rails", "force_ssl"]
title = "nginxでssl reverse proxy設定"
+++
rails上でforce_ssl設定した後、redirect loopが発生したので、その際のnginx上の設定留意点も含め、書き残したいと思います。

システムスタックとしては以下の通りです。

* rails 4
* foreman
* unicorn
* nginx
* centos

設定ファイル

	$ vim /etc/nginx/sites-available/example.com

	server {
	  listen 80;
	  listen 443 ssl;
	
	  server_name example.com;
	
	  access_log  /var/log/nginx/example.com.access.log;
	
	  ssl                  on;
	  ssl_certificate      /etc/nginx/example.com.crt;
	  ssl_certificate_key  /etc/nginx/example.com.key;
	  ssl_protocols  SSLv2 SSLv3 TLSv1;
	  ssl_ciphers  HIGH:!aNULL:!MD5;
	  keepalive_timeout 70;
	
	
	  location ~ ^/assets/ {
	    root /var/www/example.com/current/public;
	    break;
	  }
	
	  location / {
	    if (-f $request_filename) { break; }
	    proxy_set_header X-Real-IP  $remote_addr;
	    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	    proxy_set_header X-Forwarded-Proto $scheme;
	    proxy_set_header Host $http_host;
	    proxy_pass http://localhost:5000;
	
	    error_page 404              /404.html;
	    error_page 422              /422.html;
	    error_page 500 502 503 504  /500.html;
	    error_page 403              /403.html;
	  }
	}

# 設定の詳細

## iptablesでsslポート解放

	-A INPUT -m state --state NEW -m tcp -p tcp --dport https -j ACCEPT


## 鍵の配置と設定を含めたssl設定

	server {
	  ...
	  
	  listen 443 ssl;
	
	  server_name example.com;
	
	  ...
	  	
	  ssl                  on;
	  ssl_certificate      /etc/nginx/example.com.crt;
	  ssl_certificate_key  /etc/nginx/example.com.key;
	  ssl_protocols  SSLv2 SSLv3 TLSv1;
	  ssl_ciphers  HIGH:!aNULL:!MD5;
	  keepalive_timeout 70;
	
## httpからのforwardを許可する

	proxy_set_header X-Forwarded-Proto $scheme;

