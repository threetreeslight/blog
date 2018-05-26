+++
date = "2013-06-19T12:45:00+00:00"
draft = false
tags = ["rails", "activerecord", "sqlite"]
title = "active recordとsqlite3だけ使う"
+++
入れる

	$ gem install sqlite3 activerecord
	
dbつくる。

	$ vim create_ducks.rb
	require 'rubygems'
	require 'active_record'
	
	ActiveRecord::Base.establish_connection :adapter => 'sqlite3',
	                                        :database => 'dbfile'
	
	class CreateDucks < ActiveRecord::Migration
	  def change
	    create_table :ducks do |t|
	      t.string :name
	
	      t.timestamps
	    end
	  end
	end

	$ irb
	> load './create_ducks.rb'
	> create_ducks.migrate(:change)
	-- create_table(:ducks)
	-> 0.0121s
	=> nil
 
テーブルでけた。
テーブル内を操作。

	$ vim ./duck.rb

	require 'rubygems'
	require 'active_record'
	
	ActiveRecord::Base.establish_connection :adapter => 'sqlite3',
	                                        :database => 'dbfile'
	
	
	class Duck < ActiveRecord::Base
	  validates :name, :length => { :maximum => 250 }
	end

	$ irb
	> load './duck.rb'
	duck.new
	=> #<Duck id: nil, name: nil, created_at: nil, updated_at: nil>
	
activerecordこんにちは。
