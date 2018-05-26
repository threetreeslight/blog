+++
date = "2014-07-24T08:40:24+00:00"
draft = false
tags = ["pry", "ruby"]
title = "pry 0.10.0にてundefined method `pager`が起きたときの暫定対処"
+++
## 事象

0.9.12.6 -> 0.10.0にあげたらエーって言うぐらい怒られた。

```ruby
pry> User.all
undefined method `pager'
```

で、実際にissueもまだopen

[pry/pry 0.10.0 - undefined method `pager' for nil:NilClass #1265](https://github.com/pry/pry/issues/1265)

## 環境

ruby 2.0.0p353
rails 4.1.1
pry-byebug 1.3.3
pry-rails 0.3.2
pry-remote 0.1.8


## 原因

詳しく調べてないおち

## 対応策

とりあえず、pagerが原因なら殺しておく。

```bash
$ vi .pryrc

Pry.config.pager = false

```

<https://github.com/pry/pry/wiki/Customization-and-configuration#pager>



これで動作しました。
