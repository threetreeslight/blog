+++
date = "2018-05-21T00:00:00+09:00"
title = "Manage aws by terraform"
tags = ["aws", "terraform", "infrastructure"]
categories = ["programming"]
draft = "true"
+++

blogを公開するまでの道のりは長い。
やっとciまで回るようになって一段落したので、インフラのための下ごしらえをする。

terraformの下ごしらえを兼ねて既存aws accountの資産を管理。

改めて [Terraform Recommended Practices](https://www.terraform.io/docs/enterprise/guides/recommended-practices/index.html) を読んであるべき像を模索しつつ構築してみる。

## terraform workspace

以下に寄ると、 `Terraform configurations * environments = workspaces.` と切ったほうがよいとのこと。

https://www.terraform.io/docs/enterprise/guides/recommended-practices/part1.html

Reproでも似た感じだが、より細かい気がする。

とりあえず単純なblogなわけなので、こんな感じかなぁ

https://developer.chrome.com/extensions/getstarted
