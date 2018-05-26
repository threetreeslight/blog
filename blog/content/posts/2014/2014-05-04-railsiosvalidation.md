+++
date = "2014-05-04T01:19:28+00:00"
draft = false
tags = ["rails", "validation", "model"]
title = "[rails][ios]独自validationを追加"
+++
独自のvalidationが欲しい、しかも複数のモデル（STIとか）で利用したいときは、EachValidatorを拡張するのがおすすめ。

officialにある感じで、ためしにEmailのvalidationを追加します。

## 作成

まずディレクトリを作って

	$ mkdir app/validators

validationクラスを実装
	
	$ vim app/validators/email_validator.rb

	class EmailValidator < ActiveModel::EachValidator
	  def validate_each(record, attribute, value)
	    unless value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
	      record.errors[attribute] << (options[:message] || "is not an email")
	    end
	  end
	end

で、実際に追加
	 
	class User < ActiveRecord::Base
	  validates :email, presence: true, email: true
	end

おーすてき

## 参考

[RailsGuides - Active Record Validations](http://guides.rubyonrails.org/active_record_validations.html)


## P.S.

RailsGUideは隅から隅まで読んだ方が良い。