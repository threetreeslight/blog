+++
date = "2018-05-13T14:59:00+09:00"
title = "Generate SSL/TLS certificate with let's encrypt"
tags = ["ssl", "tls", "letsencrypt"]
categories = ["programming"]
+++

gcpにはaws acmに該当するサービスがないので、証明書を作成しなければいけない。

そのため、Let's encryptを利用した証明書発行を行う。

## Let's encryptとは

https://letsencrypt.org/about/

> Let’s Encrypt is a free, automated, and open certificate authority (CA), run for the public’s benefit. It is a service provided by the Internet Security Research Group (ISRG).

通信の安全を担保するためにも全ての通信がssl/tls ptorocolでの通信する必要がある。
そのためにも、free and automatedなCAっていうのが大事。それを提供しているのがlet's encryptedという認識です。

let's encryptによる証明書の発行にはshell accessとそうでない方法ががあり、shell accessを前提としたcertbot ACME clinetを使うと良いよということのようだ。

https://letsencrypt.org/getting-started/

> We recommend that most people with shell access use the Certbot ACME client. It can automate certificate issuance and installation with no downtime. It also has expert modes for people who don’t want autoconfiguration. It’s easy to use, works on many operating systems, and has great documentation. Visit the Certbot site to get customized instructions for your operating system and web server.

ダウンタイムなし、なおかつ自動化可能というのが最高。

## ACMEとは

https://ietf-wg-acme.github.io/acme/draft-ietf-acme-acme.html

ACMEとは `Automatic Certificate Management Environment (ACME)` の略で、次の[機能](https://ietf-wg-acme.github.io/acme/draft-ietf-acme-acme.html#certificate-management) を提供している。

- Account Creation
- Ordering a Certificate
- Identifier Authorization
- Certificate Issuance
- Certificate Revocation

つまり、domain認証をするために利用されるcertificateの管理に関わる上記操作のprotocolである。

このprotocolに乗っ取ることで、自動化が実現されるイメージ。

## certbotとは

ACME protocolをsupportしているclientが[certbot](https://certbot.eff.org/) で、もともとはlet's encryptの公式clientとして存在していたものが汎化された感じ。

> Certbot is an easy-to-use automatic client that fetches and deploys SSL/TLS certificates for your webserver. 

なるほど。ACMEだけではなく、さらにそのdeployまでも管理できるclientであるそうだ。

## certbot's authenticator

certbotはauthenticatorを指定する。このauthenticatorはドメイン使用権者の認証とそのドメインの証明書発行のため利用される。
authenticatorはpluingとして提供されており、apache, webroot, nginx, standalone, DNS plugins, manualの6種類がある。

certificateを利用して稼働させるmachine上で生成および自動更新することを前提としているからだろうと推察。

widlcard certificateとするためには以下の通りDNS pluginを利用してtext recordの認証をする必要がありそうだ。

> This category of plugins automates obtaining a certificate by modifying DNS records to prove you have control over a domain. Doing domain validation in this way is the only way to obtain wildcard certificates from Let’s Encrypt.

また、[dns plugin](https://certbot.eff.org/docs/using.html#dns-plugins) を読んでいたらcertbotにおいてdockerが使えることが判明。
standalone目的なのだろうけど、localの環境を汚染せずできるのは大きいのかもしれない。

とはいえdnsでの認証をおこなうので、あまり意識しないでよさそう。

## The currently selected ACME CA endpoint does not support issuing wildcard certificates

さて、実行してみると以下のようなエラーが発生する。

```sh
sudo certbot certonly --manual --preferred-challenges dns-01 \
-d threetreeslight.com,*.threetreeslight.com

Obtaining a new certificate
The currently selected ACME CA endpoint does not support issuing wildcard certificates.
```

なるほど。widlcard certificate対応している気がするのだがと思って調べると、今年の3/14に対応した模様。

[ACME v2 and Wildcard Certificate Support is Live](https://community.letsencrypt.org/t/acme-v2-and-wildcard-certificate-support-is-live/55579)

> We’re pleased to announce that ACMEv2 and wildcard certificate support is live! With today’s new features we’re continuing to break down barriers for HTTPS adoption across the Web by making it even easier for every website to get and manage certificates.
> -- Mar 14, 2:08 AM

なのに何でと思ってもう少しforum調べると

[How to issue ACMEv2 Wildcard with Certbot 0.22.0?](https://community.letsencrypt.org/t/how-to-issue-acmev2-wildcard-with-certbot-0-22-0/55657/3)

- ACMEv2をdefaultとするよう certbot側では 対応中 
    - [Change the default ACME server to the v2 endpoint #5369](https://github.com/certbot/certbot/issues/5369)
- ACMEv2に対応した認証サーバーを利用するよう指定する必要がある
    - `--server https://acme-v02.api.letsencrypt.org/directory`


## certbotにてcertificateを作成する

```sh
certbot certonly --standalone --agree-tos --server https://acme-v02.api.letsencrypt.org/directory \
-d threeetreeslight.com,*.threetreeslight.com \
--config-dir ~/Downloads/letsencrypt --logs-dir ~/Downloads/letsencrypt --work-dir ~/Downloads/letsencrypt

Saving debug log to ***
Plugins selected: Authenticator manual, Installer None

-------------------------------------------------------------------------------
NOTE: The IP of this machine will be publicly logged as having requested this
certificate. If you're running certbot in manual mode on a machine that is not
your server, please ensure you're okay with that.

Are you OK with your IP being logged?
-------------------------------------------------------------------------------
(Y)es/(N)o: Y

-------------------------------------------------------------------------------
Please deploy a DNS TXT record under the name
_acme-challenge.threetreeslight.com with the following value:

***

Before continuing, verify the record is deployed.
-------------------------------------------------------------------------------
Press Enter to Continue

-------------------------------------------------------------------------------
Please deploy a DNS TXT record under the name
_acme-challenge.threetreeslight.com with the following value:

***

Before continuing, verify the record is deployed.
-------------------------------------------------------------------------------
Press Enter to Continue
Waiting for verification...
Cleaning up challenges

IMPORTANT NOTES:
 - Congratulations! Your certificate and chain have been saved at:
   ...
   Your cert will expire on 2018-08-11. To obtain a new or tweaked
   version of this certificate in the future, simply run certbot
   again. To non-interactively renew *all* of your certificates, run
   "certbot renew"
 - If you like Certbot, please consider supporting our work by:

   Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
   Donating to EFF:                    https://eff.org/donate-le
```

certificateができた。有効期間が3ヶ月なのね。
更新するときはrenewでいいので大分楽そう。

## なぜ有効期限が3ヶ月なのか？

[Why ninety-day lifetimes for certificates?](https://letsencrypt.org/2015/11/09/why-90-days.html)

> 1. They limit damage from key compromise and mis-issuance. Stolen keys and mis-issued certificates are valid for a shorter period of time.
> 1. They encourage automation, which is absolutely essential for ease-of-use. If we’re going to move the entire Web to HTTPS, we can’t continue to expect system administrators to manually handle renewals. Once issuance and renewal are automated, shorter lifetimes won’t be any less convenient than longer ones.

鍵が盗まれる・誤って発行対策。自動化することが必須とされるので、更新し忘れることがないからとのこと。

