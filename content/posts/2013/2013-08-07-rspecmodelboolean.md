+++
date = "2013-08-07T05:42:00+00:00"
draft = false
tags = ["rspec", "activerecord", "boolean", "model", "test"]
title = "[rspec]modelにおけるboolean値のテスト"
+++
あるモデルのboolean値カラムのテストで詰まった。

原因はActiveRecordにおけるboolean値の扱い。

## sample model
***

イメージとしては、checkboxにおけるboolean値のvalidation

	$ vim app/models/user
	…
	validates foobar, :inclusion => { :in => [true, false] }

## spec
***

nilの場合エラーになるテストを書く

	describe User
	  ...
	  it "fails validation with no foobar" do
        expect(FactoryGirl.build(:user, { foobar: nil})).to have(1).errors_on(:foobar)
      end
    end


参考: [Project: RSpec Rails 2.14 - with one validation error](https://www.relishapp.com/rspec/rspec-rails/docs/model-specs/errors-on)

## 実行すると・・・
***

通るから幸せ。

## でも、boolean値のmodelの動きって
***

予想外の動き。

	$ rails c
	> @user = FactoryGirl.create(:user)
	> @user.update_attributes!(foobar: true)
	> @user.foobar
	true
	
	> @user.update_attributes!(foobar: "true")
	> @user.foobar
	true

	> @user.update_attributes!(foobar: nil)
	> @user.foobar
	nil

	> @user.update_attributes!(foobar: "hoge")
	> @user.foobar
	false
	

つまりnil値を通す場合は、状況に応じてinclusionも不要という訳か。だってstringとかもActiveRecordがよしなにやってくれるから。

ぐぐると。

[Validating boolean value in Rspec and Rails](http://stackoverflow.com/questions/3648619/validating-boolean-value-in-rspec-and-rails)

> ## Validating boolean value in Rspec and Rails
> ***
> One important thing is that ActiveRecord does typecasting behind the scenes, so you do not have to worry about how your database stores boolean values. You even need not validate that a field is boolean, as long as you set that field as boolean when preparing your migration. You may want to make sure the field is not nil though, with a `validates_presence_of :superuser` declaration in your model class.

つまりboolean値のmodelに対するvalidationは必要なく、nil値を通したくない場合は、`validates present: true`しろってことらしい。

が`validates present: true`すると通らないよね？

presentがObject#blank?を利用していて、false.blank? => trueになるから。

[api - method-i-validates_presence_of](http://api.rubyonrails.org/classes/ActiveModel/Validations/HelperMethods.html#method-i-validates_presence_of)

そういうときは普通に

  validates :hoge, :inclusion => { :in => [true, false] }

とすれば問題ない。


## P.S.
***

一部、誤った理解が有ったので、修正しました。
