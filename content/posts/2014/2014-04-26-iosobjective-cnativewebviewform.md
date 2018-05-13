+++
date = "2014-04-26T06:21:09+00:00"
draft = false
tags = ["form", "webView", "objc", "ios", "objective-c"]
title = "[iOS][objective-c]nativeから直接webViewのformなどを操作する"
+++
掲題の通りの事がやりたかったら調べたら超簡単だった。

## やり方

webViewのdelegate methodでwebViewDidFinishLoadのタイミングをhookする事が出来る。

そこでjs流し込むだけ。

	- (void)webViewDidFinishLoad:(UIWebView *)webView {
	    NSString *js = [NSString stringWithFormat:@"document.forms[0].elements['foo'].value='%@'", @"bar"];
	    [webView stringByEvaluatingJavaScriptFromString:js];
	}
