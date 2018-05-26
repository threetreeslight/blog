+++
date = "2013-04-01T02:57:00+00:00"
draft = false
tags = ["heroku", "rails", "assets sync", "assets", "precompile"]
title = "assets syncの実装"
+++
#### 目的
***

[assets sync](https://github.com/rumblelabs/asset_sync)を利用して、herokuを高速化。

* assetsをtokyoリージョンから読み込む事で、レイテンシーを下げる。
* アセットの読み込みを別サーバーにする事で、herokuとのHTTPセッション数を節約する。

#### Implement
***

generate initializer

    $ rails g asset_sync:install --provider=AWS

warp initializer

    $ vim config/initializers/assets_sync.rb
    if defined?(AssetSync)
    ...
    end

config

    $ vim config/environments/production.rb
    config.action_controller.asset_host = ENV['AWS_HOST']


なお、S3上にassetsディレクトリが生成されるため、fog_directoryはbucket名で問題無い。



### PS
***

IE8,9において、web fontの読み込みでcross domain errorが出ていた。

でもS3上のCORSは問題ない。

そのため、mime-typeに以下の内容を追加。

    ".woff" => "application/x-font-woff",
    ".eot"  => "application/vnd.ms-fontobject",
    ".ttf"  => "application/x-font-ttf",
    ".svg"  => "image/svg+xml"


そもそも、IE8ではwoffに対応していないため、eotを利用する必要がある。


参考：
http://stackoverflow.com/questions/5065362/ie9-blocks-download-of-cross-origin-web-font