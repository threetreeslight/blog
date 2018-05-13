+++
date = "2013-03-11T15:58:31+00:00"
draft = false
tags = ["carrierwave", "rails", "ruby", "upload"]
title = "[carrerwave]Uploader毎に保存ディレクトリを変更する"
+++
carrerwaveにおけるアップロード先を複数も受ける場合は以下のように、各uploader毎にconfigをoverrideする事で出来る。

[How to: Define different storage configuration for each Uploader.](https://github.com/jnicklas/carrierwave/wiki/How-to%3A-Define-different-storage-configuration-for-each-Uploader.)


	def initialize(*)
	  super

      self.fog_credentials = {
        :provider               => 'AWS',              # required
        :aws_access_key_id      => 'YOURAWSKEYID',     # required
        :aws_secret_access_key  => 'YOURAWSSECRET',    # required
      }
      self.fog_bucket = "YOURBUCKET"
    end
