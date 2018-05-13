+++
date = "2013-07-31T09:27:00+00:00"
draft = false
tags = ["rspec", "spork", "factory_girl", "rails", "ruby"]
title = "rspec利用時にmodel変更が適用されない。"
+++
rspec利用時にmodel変更が適用されないくてこまった。

ぐぐってみるとあるあるな模様。

**環境**

	$ gem list | ack rspec
	guard-rspec (3.0.2)
	rspec (2.13.0)
	rspec-core (2.13.1)
	rspec-expectations (2.13.0)
	rspec-mocks (2.13.1)
	rspec-rails (2.13.0)
	
	$ gem list | ack spork
	guard-spork (1.5.1)
	spork (1.0.0rc3)
	

## 調査方法
***

sporkではあるあるの模様。

[spork - Troubleshooting](https://github.com/sporkrb/spork/wiki/Troubleshooting)

> # Some changes to files don’t take effect until I restart Spork.
> ***
> Your file is getting preloaded in your prefork block. Anything in the prefork block is cached during the life of the > spork server (this is what makes it run faster than otherwise). Run `spork -d` to help you find out which files are being preloaded, and why.
> 
> Some eager plugins (including latest version of Thinking Sphinx) load the contents of your app folder. You can see which by inspecting the output of `spork -d > spork.log`. See Kickstart Rspec with Spork for more details.

See Spork.trap_method Jujitsu for various solutions.


## 修正ポイント
***

[Tiny Tip: Spork not reloading classes](http://www.avenue80.com/tiny-tip-spork-not-reloading-classes/)

factory girlのreload等を設定

	$ vim spec/spec_helper.rb
	...
	Spork.each_run do
	  # This code will be run each time you run your specs.
	  FactoryGirl.reload
	  ActiveSupport::Dependencies.clear
	end

chaceしないよう設定

	$ vim config/environments/test.rb
	myapp::Application.configure do
	  config.cache_classes = false
	end
