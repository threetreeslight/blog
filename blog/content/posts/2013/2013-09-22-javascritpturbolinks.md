+++
date = "2013-09-22T06:29:19+00:00"
draft = false
tags = ["rails", "javascript", "turbolinks", "rails4"]
title = "とりあえずjavascritpのturbolinksをきりたいとき。"
+++
ゆっくり開発しているじかんがなーい！し、あとでちゃんとやるつもりだから、とりあえずjavascritpのturbolinksをオフにしておきたい！

そういうときはjavascriptのturbolinksを切るのと、layoutファイルのturbolinksをカットする。

application.js.coffee

	# require turbolinks
	
layout/application.html.slim

    = stylesheet_link_tag    "admin/application", media: "all"
    -# = stylesheet_link_tag    "admin/application", media: "all", "data-turbolinks-track" => true


    = javascript_include_tag "admin/application"
    -# = javascript_include_tag "admin/application", "data-turbolinks-track" => true
