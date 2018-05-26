+++
date = "2014-04-27T05:29:28+00:00"
draft = false
tags = ["rails", "scope", "activeRecord"]
title = "[rails] activeReocrdのsocopeはchain前提"
+++
scope methodは基本、associationRelationをベースにchainして行く事を前提に生成されています。


そのため、scope block内に`find_by`句のような、modelそのもののclassオブジェクトを返すような形だと、正しく発行されません。

だめな例

	class user < ActiveRecord::Base
		scope :selected_by_name, <- (c) { find_by( name: c) }
	end

そのため、このような時はinstance methodを作成します。


	class user < ActiveRecord::Base
		def self.selected_by_name(name)
			self.find_by( name: c )
		end
	end

	
それをふまえてchainしたとしても、arelはよしなにqueryを組み立ててくれます。

	User.where(" created_at < Date.today ").selected_by_name("Victria")

        => select * from user where created_at < 2014-04-27 and name = "Victria" LIMIT 1

参考

[First or limit in Rails scope](http://stackoverflow.com/questions/13070658/first-or-limit-in-rails-scope)