+++
date = "2013-02-10T01:44:00+00:00"
draft = false
tags = ["ruby", "rails", "boolean", "validation", "validate"]
title = "[rails]booleanのvalidation"
+++
booleanのvalidationをpresentsにて実行しようとしたらfalseで引っ掛かる。

```
validates :hoge, :presents =&gt; true # damepo 
```

そりゃそうだよね。ということでinclusionで処理するしか無いみたい。


```
validates :hoge, :inclusion =&gt; {:in =&gt; [true, false]}
```

### 参考

[rails-validating-inclusion-of-a-boolean-fails-tests](http://stackoverflow.com/questions/5170008/rails-validating-inclusion-of-a-boolean-fails-tests)

[ActiveModel::Validations::ClassMethods](http://api.rubyonrails.org/classes/ActiveModel/Validations/ClassMethods.html)
