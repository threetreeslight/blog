+++
date = "2013-03-15T01:37:33+00:00"
draft = false
tags = ["sitemap", "rails"]
title = "sitemap_generatorでS3にsitemapをアップロードできない"
+++
やりたい事。

* サイトマップを自動生成したい
* herokuではローカルにファイル生成できないので、S3上に展開する

### sitemapの自動生成ツール
***

サイトマップの生成には以下のgemを利用しました。

[sitemap_generator](https://github.com/kjvarga/sitemap_generator)


### S3に吹っ飛ばす設定
***

config/sitemap.rbに追加

    # Set the host name for URL creation
    SitemapGenerator::Sitemap.default_host = "http://hoge.com"
    SitemapGenerator::Sitemap.sitemaps_host = 'http://foo.s3-ap-xxxxxxx-1.amazonaws.com'
    SitemapGenerator::Sitemap.public_path = 'tmp/'
    SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps/'
    SitemapGenerator::Sitemap.adapter = SitemapGenerator::S3Adapter.new({
        :awds_access_key_id    => 'aws key',
        :aws_secret_access_key => 'aws secret key',
        :aws_region            => 'ap-xxxxxxx-1',
        :fog_provider          => 'AWS',
        :fog_directory         => 'foo'
    })


`rake sitemap:refresh'を実行すると・・・

    [WARNING] fog: followed redirect to foo.s3-ap-xxxxxx-1.amazonaws.com, connecting to the matching region will be more performant
    rake aborted!
    hostname does not match the server certificate



めっちゃ怒られる。

### S3Adapter周りを直す
***

ソースを潜ると、S3Adapterのリージョン周りが怪しい。

    require 'fog'

    module SitemapGenerator
      class S3Adapter

        def initialize(opts = {})
          @aws_access_key_id = opts[:aws_access_key_id] || ENV['AWS_ACCESS_KEY_ID']
          @aws_secret_access_key = opts[:aws_secret_access_key] || ENV['AWS_SECRET_ACCESS_KEY']
          @fog_provider = opts[:fog_provider] || ENV['FOG_PROVIDER']
          @fog_directory = opts[:fog_directory] || ENV['FOG_DIRECTORY']
        end

        # Call with a SitemapLocation and string data
        def write(location, raw_data)
          SitemapGenerator::FileAdapter.new.write(location, raw_data)

          credentials = { 
            :aws_access_key_id     => @aws_access_key_id,
            :aws_secret_access_key => @aws_secret_access_key,
            :provider              => @fog_provider
          }

          storage   = Fog::Storage.new(credentials)
          directory = storage.directories.get(@fog_directory)
          directory.files.create(
            :key    => location.path_in_public,
            :body   => File.open(location.path),
            :public => true
          )
        end

      end
    end



あ、initializeのところにregion情報が無い。
おかげでFog::Storageの生成結果がおかしな事になっていた。



###修正内容
***

rubygemsのが古いっぽく、githubでは最新で、ちゃんとregion情報が追加されていました。

というわけで、Gemfileを以下の通り更新することで問題解決。


    gem 'sitemap_generator', :git => 'git://github.com/New-Bamboo/sitemap_generator.git'
