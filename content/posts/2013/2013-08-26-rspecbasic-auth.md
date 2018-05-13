+++
date = "2013-08-26T02:10:32+00:00"
draft = false
tags = ["rspec", "basic auth", "auth", "401"]
title = "rspecにおけるbasic auth対応"
+++
## サンプル用のテストファイルを作る
***

	$ rails g integration_test hoge

## basic auth login用のメソッド作る
***

> Requires supporting ruby files with custom matchers and macros, etc, in spec/support/ and its subdirectories.

ちなみに、メソッド準備する場合はspec/support使えよって。


**controller用**

	$ vim /spec/support/auth_helper.rb
	module AuthHelper
	  def http_login
	    user = 'username'
	    pw = 'password'
	    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(user,pw)
	  end
	end

**request spec用**

	$ vim /spec/support/auth_request_helper.rb
	module AuthRequestHelper
	  #
	  # pass the @env along with your request, eg:
	  #
	  # GET '/labels', {}, @env
	  #
	  def http_login
	    @env ||= {}
	    user = 'username'
	    pw = 'password'
	    @env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(user,pw)
	  end
	end
	
#### spec_helperに食べさせる

	$ vim spec/spec_helper.rb
	
	RSpec.configure do |config|
	  config.include AuthRequestHelper, :type => :request
	  config.include AuthHelper, :type => :controller
	end


#### テストに組み込むと


	  before(:all) do
	    http_login
	  end
	
	  describe "GET /" do
	    it "works! (now write some real specs)" do
	      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
	      get root_path
	      expect(response.status).to eq(200)
	    end
	  end


参考

* [Rails/Rspec Make tests pass with http basic authentication](http://stackoverflow.com/questions/3768718/rails-rspec-make-tests-pass-with-http-basic-authentication)
* [gist - RSpec basic authentication helper module for request and controller specs](https://gist.github.com/mattconnolly/4158961)

## とはいえ
***

テストはproduction modeを意識して作成すべきなので、本番で適用されないbasic auth部分は外すべきだよね。
