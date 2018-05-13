+++
date = "2013-06-15T14:44:00+00:00"
draft = false
tags = ["pdf", "rails", "csv", "roo", "prawn", "ruport"]
title = "[memo]reporting on rails "
+++
### csv周りだけであれば
***

[csv class](http://ruby-doc.org/stdlib-1.9.3/libdoc/csv/rdoc/CSV.html)使えばよろし

やり方はこちらの[rails cast](http://railscasts.com/episodes?utf8=%E2%9C%93&search=CSV)で。

### spred sheetとかの操作は
***

[roo gem](https://github.com/Empact/roo)辺りが良さそう。

### pdfとか諸々やりたいなら
***

有名どころの[ruport gem](https://github.com/ruport/ruport)か、[Prawn](https://github.com/prawnpdf/prawn)辺りで取捨選択。

ActiveRecordと連携させられるとか幸せPDFで帳票作成


PDFはこっちの方が簡単くさい。

[thin reports](http://www.thinreports.org/)

テンプレート構築用guiのjsもあるので、素敵。

### xmlとかは
***

[builder](https://github.com/jimweirich/builder)

sitemap_generator gemでも使われている。

