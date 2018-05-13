+++
date = "2014-05-16T14:32:27+00:00"
draft = false
tags = ["rails", "test", "rspec"]
title = "Test of Controller"
+++
controllerのテストで、大体こんな内容を書いてルーチン化している事に気付いた。

## Methods

GET

- assing valiables
	- exist
	- not exist (if necessary or have possible)
- render_template
	- assign valiable exist
	- not exist (if necessary or have possible)

POST

- assing valiables (if necessary)
- record commit
- redirect_to
- validation
- re-render template (invalid access)
	
PATCH

- assing valiables
- all params update
- validation
- record update
- redirect_to
- re-render template (invalid access)
	
DELETE

- assing valiables
- record delete
- redirect_to

## Point

- default factory is association only 'blongs_to'
- Keep minimum let on clean. ( factory design is too important )
- Become dirty association models on nested description