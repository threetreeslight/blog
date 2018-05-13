+++
date = "2014-05-31T02:47:40+00:00"
draft = false
tags = ["xcode", "objective-c", "objc", "ios"]
title = "[Objective-c][Xcode] Xcode project内のgroupと実際のディレクトリをsyncさせる"
+++
XcodeProject内のgroupと実際のディレクトリをsyncさせる

これが結構面倒かったりする。

そういうときはsynx

## [synx](https://github.com/venmo/synx)

gemいれて叩く！これだけ！

    $ gem install synx
    $ synx path/to/my/project.xcodeproj
