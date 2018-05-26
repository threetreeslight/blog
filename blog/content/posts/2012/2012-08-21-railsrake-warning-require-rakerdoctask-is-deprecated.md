+++
date = "2012-08-21T04:33:53+00:00"
draft = false
tags = ["rails", "rake"]
title = "[rails][rake] WARNING: 'require 'rake/rdoctask'' is deprecated.への対応"
+++
<p>rake時のエラー：</p>&#13;
<pre class="ruby">$ rake db:migrate&#13;
WARNING: 'require 'rake/rdoctask'' is deprecated.  Please use 'require 'rdoc/task' (in RDoc 2.4.2+)' instead.&#13;
</pre>&#13;
<p><br />対応：edit rakefile</p>&#13;
<pre class="ruby"># require 'rake/rdoctask'&#13;
require 'rdoc/task'&#13;
</pre>&#13;
&#13;
<p>参考</p>&#13;
<p><a href="http://matthew.mceachen.us/blog/howto-fix-rake-rdoctask-is-deprecated-use-rdoc-task-instead-1169.htm">http://matthew.mceachen.us/blog/howto-fix-rake-rdoctask-is-deprecated-use-rdoc-task-instead-1169.htm</a>l</p> 