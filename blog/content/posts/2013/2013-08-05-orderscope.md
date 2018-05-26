+++
date = "2013-08-05T12:05:00+00:00"
draft = false
tags = ["rspec", "scope"]
title = "orderを制御するscopeメソッドのテストについて"
+++
model周りは極力きっちりとテストを書いておきたいってときに、nil扱いで嵌ったり、あーメソッド設計ってそういえば本来こうすべきだったけ？とか思い出したのでメモ。


## サンプルscopeメソッド
***

Userのソート可能なattributeを指定し、orderするメソッドを作成

	$ vim app/models/user.rb
	SORT_ATTRIBUTES = ["email", "name"]

	scoep :order_by_sort_attribute, lambda { |t| order("#{t} DESC") }

## このとき取り得るパターンは
***

* 正常系
	1. User.order_by_sort_attribute("email")
	1. User.order_by_sort_attribute("name")
* 異常系(nilや不正な引数)
	2. User.order_by_sort_attribute(nil)
	3. User.order_by_sort_attribute
	1. User.order_by_sort_attribute("hoge")
	1. User.order_by_sort_attribute(true)
	1. User.order_by_sort_attribute(123)

いやーよゆーよゆー楽勝っしょ？と思うと、そうは問屋がおろしてくれなかった。

異常系の１と２の挙動の違いを正しく理解していなかったのが原因です。

#### **異常系1の場合**

ブロック変数がnilだと

	$ rails c
	> User.order_by_sort_attribute(nil)
	Hirb Error: PG::Error: ERROR:  syntax error at or near ...

このときは、変数を初期化して回避。

	scoep :order_by_sort_attribute, 
	      lambda { |t| 
		     order("#{t ||="email"} DESC")  # <- ココで初期化する必要が有る
		   }

#### **異常系2の場合**

そもそも変数が与えられない場合は

	$ rails c
	> User.order_by_sort_attribute
	ArgumentError: wrong number of arguments (0 for 1
	
このときは、ブロック変数に初期値を設定で回避。

	scoep :order_by_sort_attribute, 
	      lambda { |t="email"| # <- ココで初期化する必要が有る 
		     order("#{t ||="email"} DESC")
		   }

#### **でもさ**

本来nilのときとかって、scopeメソッドの内容をSQLに含めたくない訳です。

上記対応って素人的で、例外なパラメータは例外として処理すべきだよね。そうじゃないとコードが、リーダブルでもないし、シンプルにもならない。

## ちなみにorderメソッドの生成するsqlの挙動は
***

	> User.order(:email).to_sql
	=> "SELECT \"users\".* FROM \"users\"  ORDER BY email"
	
	> User.order(:email).order(:name).to_sql
	=> "SELECT \"users\".* FROM \"users\"  ORDER BY email, name"
	
	> User.order(nil).to_sql
	=> "SELECT \"users\".* FROM \"users\" "
	
scopeメソッドについても、nilが与えられた場合、その項に対応するsqlが生成されない。whereも同じ。

というわけで、scopeメソッドがnilを返してあげれば幸せになれそう。

## というわけで
***

* 異常系(nilや不正な引数)
	2. User.order_by_sort_attribute(nil) -> select * from userのオーダー
	3. User.order_by_sort_attribute -> Augment error、riseはしない。
	1. User.order_by_sort_attribute("hoge") -> select * from userのオーダー
	1. User.order_by_sort_attribute(true) -> select * from userのオーダー
	1. User.order_by_sort_attribute(123) -> select * from userのオーダー
	
user.rb

	SORT_ATTRIBUTES = ["email", "name"]

	scoep :order_by_sort_attribute, 
	      lambda { |t|
		     order("#{t} DESC") if SORT_ATTRIBUTES.index(t)
		   }

user_spec.rb

サンプルなんで全部はちゃんと書いてないですが、今の所以下みたいな感じで書いてます。

	  describe "#order_by_sort_attribute" do
	    let(:users) do
	      users = Array.new
	      5.times { users.push( FactoryGirl.create(:user) ) }
	      return users
	    end
	    
	    context 'when value exist in SORT_ATTRIBUTES,' do
	      User::SORT_ATTRIBUTES.each do |sort_attr|
	        it "order by #{sort_attr}" do
	        	ごにょごにょ書く
	        end
	      end
	    end
	
	    context 'when value does not exist in SORT_ATTRIBUTES,' do
	      it "order by natural" do
	        users
	        expect(User.order_by_sort_attribute("hoge")).to eq(users)
	      end
	    end
	
	    context 'when value is nil,' do
	      it "order by natural" do
	        users
	        expect(User.order_by_sort_attribute(nil)).to eq(users)
	      end
	    end	
	  end



## P.S.
***

**ぶっちゃけ、この感覚値を久しく忘れていた！！！テスト（設計）ちゃんとコードで書くって大事だわやっぱ**

column nameを引数としたorder scopeメソッドで困った内容なんだけれども、
そもそも、column nameを引数に利用するのは良いお作法ではないような気がする・・・。
