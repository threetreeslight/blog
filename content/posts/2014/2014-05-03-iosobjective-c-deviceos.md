+++
date = "2014-05-03T08:34:27+00:00"
draft = false
tags = ["ios", "objective-c"]
title = "[ios][objective-c] deviceとosのバージョンを取得する"
+++
os

	[[[UIDevice currentDevice] systemVersion] floatValue];

device

    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];


こんな感じで取得できる。簡単やね。

分析するんならdeviceの情報は、"iPhone5s"とかに変換せず、そのままサーバーに食わせるのが吉