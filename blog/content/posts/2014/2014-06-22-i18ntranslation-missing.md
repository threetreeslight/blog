+++
date = "2014-06-22T03:32:00+00:00"
draft = false
tags = ["rails", "i18n"]
title = "i18nのtranslation missingをテストする"
+++
i18nのtranslation missingをテストする

i18n対応したサービスを提供していると、i18nのdictが一部抜けていたり、デザイン崩れているじゃんって事が多々有りますよね？

で、そういうのをデプロイ前に未然に防ぎたいと思ってcontroller specにて、translation_missingが含まれているかとかチェックしていたけど、複数人で書いていると中々網羅性に掛けたりして困ってました。

そういうときに便利なのが[i18n-task gem](https://github.com/glebm/i18n-tasks)


## install

gemいれて

	$ vim Gemfile
	gem 'i18n-tasks', '~> 0.4.5' 

	$ bundle


## configuration

デフォルトの言語はja、テスト対象はja, enにしたいと思います。


	$ i18n-tasks config > config/i18n-tasks.yml
	$ vim config/i18n-tasks.yml

	base_locale: ja
	locales: [ja, en]

	# dictを分割している場合は、それぞれ読み込んじゃいます。
	data:
	  read: 
    	-  'config/locales/defaults/%{locale}.yml'
    	-  'config/locales/views/defaults/%{locale}.yml'
    	-  'config/locales/views/foo/%{locale}.yml'

## 実行

	# translation missing
	$ i18n-tasks missing

	# unused
	$ i18n-tasks unused


さらに使っていない物をremoveしたり、検索対象やremoveに際しignoreする事もconfigurationできます。

## rspec

spec/view/translation/i18n_spec.rbを追加することで、CIでちゃんと試験してくれるようになります。

	
	require 'spec_helper'
	require 'i18n/tasks'
	
	describe 'I18n' do
	  let(:i18n) { I18n::Tasks::BaseTask.new }
	
	  it 'does not have missing keys' do
	    count = i18n.missing_keys.count
	    fail "There are #{count} missing i18n keys! Run 'i18n-tasks missing' for more details." unless count.zero?
	  end
	
	  it 'does not have unused keys' do
	    count = i18n.unused_keys.count
	    fail "There are #{count} unused i18n keys! Run 'i18n-tasks unused' for more details." unless count.zero?
	  end
	end

遣り過ぎるとメンテナンス性が落ちたり、設定が複雑化することもあるので、現行プロジェクトではtranslation missingだけの抽出を対象にしています。

やっと心が安らぐ。。。
