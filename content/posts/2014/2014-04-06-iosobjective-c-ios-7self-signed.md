+++
date = "2014-04-06T06:22:00+00:00"
draft = false
tags = ["objc", "objective-c", "ssl", "certificate", "self-signed"]
title = "[ios][objective-c] ios > 7でオレオレ(self-signed)証明書を通す"
+++
VMへiosからhttpsリクエスト飛ばしたい。

で、validateでない証明書へのアクセスでは`kCFStreamErrorDomainSSL error`が起こる

なんだかんだ困った。


## 解決案は３つ

1. NSURLRequestをoverrideしてsslをverifyしないようにする
1. デバイス（ハード）にSSL食べさせちゃう
1. オレオレSSL certificateをresouceについかして、こいつのときは許可するようにする

require

* xcode > 5
* ios > 7
* サービス名はhoge.com、vm上はhoge.localでhostsを切っている
 
オレオレ証明書作って

    $ openssl genrsa -out hoge-local.key 2048
    $ openssl req -new -key hoge-local.key -out hoge-local.csr
    ---
    Common Name (eg, YOUR name) []:*.hoge.local
    $ openssl rsa -in hoge-local.key -out hoge-local.key
    $ openssl x509 -req -days 3650 -in hoge-local.csr -signkey hoge-local.key -out hoge-local.crt

作って、nginxやapacheはよしなに。


## 1. NSURLRequestのoverride

やっちゃ行けない技だと分かっていながら、やってみる。

    $ vim NSURLRequest+IgnoreSSL

    #ifdef DEBUG
    @interface NSURLRequest (IgnoreSSL)
    +(BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host;
    @end

    @implementation NSURLRequest (IgnoreSSL)
    +(BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host {return YES;}
    @end
    #endif

これで通る。


## 2. デバイス（ハード）にSSL食べさせちゃう

[iPhoneに自己証明書（オレオレ証明書）をインストールする方法](http://nanapi.jp/108213/) を参照


## 3. オレオレSSL certificateをresouceについかして、こいつのときは許可するようにする

まず、DER 形式の証明書を作成

    $ openssl x509 -in hoge-local.crt -inform PEM -out hoge-local.der -outform DER

hoge-local.derをresourceに配置

    HogeTarget > Build Phases > Copy bundle Resources
    + hoge-local.der


NSURLConnectionのdelegateへ追加

    static SecCertificateRef sslCertificate = NULL;
    + (SecCertificateRef)sslCertificate
    {
      if (!sslCertificate) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"cert" ofType:@"der"];
        NSData *data = [[NSData alloc] initWithContentsOfFile:path];
        sslCertificate = SecCertificateCreateWithData(NULL, (CFDataRef)data);
      }
      return sslCertificate;
    }
    - (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
    {
      return [[protectionSpace authenticationMethod] isEqualToString:NSURLAuthenticationMethodServerTrust];
    }
    - (void)connection:(NSURLConnection *)conn didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
    {
      NSURLProtectionSpace *protectionSpace = [challenge protectionSpace];
      SecTrustRef trust = [protectionSpace serverTrust];
      NSURLCredential *credential = [NSURLCredential credentialForTrust:trust];
      NSArray *certs = [[NSArray alloc] initWithObjects:(id)[[self class] sslCertificate], nil];
      int err = SecTrustSetAnchorCertificates(trust, (CFArrayRef)certs);
      SecTrustResultType trustResult = 0;
      if (err == noErr) {
        err = SecTrustEvaluate(trust, &trustResult);
      }
      [certs release];
      BOOL trusted = (err == noErr) && ((trustResult == kSecTrustResultProceed) || (trustResult == kSecTrustResultUnspecified));
      if (trusted) {
        [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
      }
      else {
        [[challenge sender] cancelAuthenticationChallenge:challenge];
      }
    }

    

参考 

* [iPhoneアプリで自己証明書を使ったhttps通信](http://e-mac.caadr.org/memo/self-signed-certificate.html)
* [iOSのSSL通信でオレオレ証明書を使う](http://www.j7lg.com/archives/184)
* [Certificate, Key, and Trust Services Reference](https://developer.apple.com/library/mac/documentation/security/Reference/certifkeytrustservices/Reference/reference.html)