+++
date = "2012-09-15T09:49:08+00:00"
draft = false
tags = ["rails", "textarea"]
title = "[rails] Display multiple line breaks"
+++
<p>simple_formatはdocumentにもあるおり、複数行の改行をparagraph　"&lt;p&gt;"　に変換してしまう。</p>
<p>そのため、改行コードを読み取って&lt;br /&gt;に変換し、それをrawで表示させる必要が有る。<br>&nbsp;</p>
<pre>application helper : 

def hbr(target)
  target = html_escape(target)
  target.gsub(/\r\n|\r|\n/, "<br>")
end


view :
&lt;% =raw hbr("hoge\n\nfoo") %&gt;

</pre>
<p>参考</p>
<p><a href="http://www.katawara.com/2008/hbr/">http://www.katawara.com/2008/hbr/</a></p>