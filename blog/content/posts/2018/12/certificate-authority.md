+++
date = "2018-12-29T12:00:00+09:00"
title = "Certificate Authority"
tags = ["ssl", "ca", "authority", "EV", "OV", "DV", "ACM"]
categories = ["programming"]
+++

GCPではACMのようなサービス提供を期待するIssueが2016年にあり、以下のように回答している。

> Given the above, can we consider this request to be asking convenient provisioning of Google-signed certificates for GCP customers?

なぜこのような話に至ったのか気になるので、自身の理解を深めるためにも調べてみた。

**理解が間違っている可能性もありますので、その点は了承ください。**

## Certificate Authority

SSLエコシステムではだれでもsigning keyを作成し、そのkeyを利用して新しい証明書を作成することが出来ます。

しかし、この証明書が信頼できる認証局( Certificate Authority、以下CA )によって直接的・間接的に署名されていない限り、有効な通信とはみなされません。

## CA Types

この直接的・間接的な署名を行う認証局が以下です。

1. Root CA
  - 直接的な証明を行う認証局
1. Intermediate CA
  - 間接的な証明を行う認証局

これら信頼できる認証局の情報は、大抵のケースではOSやweb browserにbundleされています。

OSやbrowserにbundleされていないCA(大抵の場合は Intermediate CA)があると、それをOSやbrowserはCAの証明書を元に探りに行きます。

## CA list = security level

信頼できるCA listはとても重要で、システムのセキュリティレベルを決定すると言っても過言ではありません。
そのため、OSやbrowserそれぞれにbundleされているCA listには差分があります。

このため、中間証明書を含まない証明書を通信に利用すると、Browserで見るとValidなHTTPS通信と見なされるにもかかわらず特定のOSやlibraryによってはUnknown Authorityとみなされてしまうケースがあるので、必ず中間証明書を含む証明書を利用することが求められます。

## How to provide a service like ACM

これらの前提を理解しながら、Googleの回答を理解していきます。

> we would need to sign certificates ourselves or otherwise act as proxies for major third-party CAs. 

上記にある通り、ACMのようなサービスを作る方法は大きく3つあります。

1. 自己証明された中間証明書を利用する
1. デファクトスタンダードのThird party CAのproxyとなる

この方法のうち、1の方法には問題が有ます。
前述したとおり幅広い端末・OS・ブラウザのCA listに含まれている必要があり、新しいRoot CAとしてGoogleが署名した場合、サービスとしてのセキュリティレベルが低下し、clientからはUnknown(insecure)なAuthorityとみなされる可能性も考えられます。

また、この問題を解決するための後者の方法を使った場合

> Customers would likely incur costs for the latter given the costs associated with getting a certificates signed by VeriSign for instance.

利用者がVeriSignの証明書獲得にかかるコストを負担することになる。

> Alternatively, Google could create self-signed certificates on behalf of the customer though they would not be trusted by most devices.  I assume this is not what most customers would want.

そのコストを削減するためにGoogleのself-signed certificateでいいのか？というとCA listに含まれないリスクが当然のように浮上する。

## Lookup root certificate about Google, Amazon, Lets Encrypt

これを理解した上でいくつかのsiteを見ていきます。

Google

![](/images/blog/2018/12/2018-12-29-ca-google.png)

Amazon

![](/images/blog/2018/12/2018-12-29-ca-amazon.png)

Lets Encrypt

![](/images/blog/2018/12/2018-12-29-ca-letsencrypt.png)

まとめると

 | Root CA | Intermediate CA
 --- | --- | ---
Google | GlobalSign | Google Internet Authority G3
Amazon | Amazon Root CA 1 | Amazon
Lets Encrypt | DST Root CA X3 | Let's Encrypt Authority X3

## ここから考えた推察

AWSは、ACMという証明書管理サービスがGCPに比べ早期に投入されている。

これは、すべてのあらゆる端末のCAリストに入ることよりもCertificateの更新に苦しむユーザーを開放することを優先している、いわゆる `Customer Obsession` に体現される行動に思えた。

コスト的にもAmazon自前のRoot CAを提供していることからもわかる。

一方、GoogleはIntegrityを意識し、何の不安も意識せず利用できるようになるまでLets Encryptの普及であったり、Global Signのような認証局の中間証明書として振る舞う方向にしたのだろうか。

なんとなくだけれどもスタンスの違いを垣間見ることができてこれはとてもおもしろい。

## Tips: Validation levels of Public Key Certificate

AMSおよびGoogle-managed SSL certificates ではどちらも ドメイン検証（DV）証明書であることの注意書きがなされている。

このDVというのは公開鍵証明書における検証レベルを表す。

検証レベルは以下の３段階があり、それぞれもっとも強力なものはEVとなる

1. DV: Domain Validation
1. OV: Organization Validation
1. EV: Extended validation

### DV

ドメイン名を管理的に管理する権利を証明できる場合に発行されるレベルの証明書。

その証明はDNSレコードや、Domain配下へ期待するアクセスができることで証明される。

### OV

DVを満たし、組織としての組織の実際の存在が証明できる場合に発行されるレベルの証明書。

サイト運営者のなりすましを防ぐ。
つまり、フィッシングサイトや似ているdomainにおいて、その所有者が期待する企業であることを証明する。

けれどもペーパーカンパニーは防げない。似たような会社名をつけることも容易である。

GeoTrastやVerisignなどのCertificate Auhorityによって発行可能。

### EV

OVに加え、法的および物理レベルで存在することを証明できる場合に発行されるレベルの証明書。

これによって犯罪利用時は100%追跡可能ともなり、フィッシングサイトなどのなりすまし対策をより強固に防止する。

見た目でも緑色になることで視覚的に安全なことが分かるようになる。

やっとこれで安全なweb決済の仕組みができたと言えるとともに、いかにフィッシング詐欺が大きな問題であるかも伺える

GeoTrastやVerisignなどの大手Certificate Auhorityによって発行可能。

## References

- [Google Issue tracker - Support automatic certificate request](https://issuetracker.google.com/issues/35900617)
- [Google Internet Authority G2 - Repository of Documentation and Issuing CA Certificates](https://pki.google.com/)
- [Google Trust Service](https://pki.goog/)
- [AWS - ACM Certificate Characteristics](https://docs.aws.amazon.com/acm/latest/userguide/acm-certificate.html)
- [AWS - AWS Certificate Manager FAQs](https://aws.amazon.com/certificate-manager/faqs/?nc1=h_ls)
- [Google - Types of SSL certificates](https://cloud.google.com/load-balancing/docs/ssl-certificates#certificate-types)
- [wiki - Public key certificate : Validation levels ](https://en.wikipedia.org/wiki/Public_key_certificate#Validation_levels)
