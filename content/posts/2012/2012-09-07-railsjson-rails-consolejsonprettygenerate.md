+++
date = "2012-09-07T03:34:01+00:00"
draft = false
tags = ["rails", "json"]
title = "[rails][json] rails console上でインスタンスをJSON.pretty_generate表示する方法"
+++
<p>rails console上でJSON見難くてしょうがない。</p>&#13;
<p>hirbみたいな物が有るかと思ったらない。もっと見やすくする方法は無い物かと思ったら、JSON.pretty_generateなるものがあるじゃないか！！</p>&#13;
&#13;
<p>こんなやつ <a href="http://stackoverflow.com/questions/86653/how-can-i-pretty-format-my-json-output-in-ruby-on-rails">how-can-i-pretty-format-my-json-output-in-ruby-on-rails</a></p>&#13;
<p>力技だけど以下の方法で出来ました。<br /> </p>&#13;
<pre><code class="ruby">&gt; Post<br />=&gt; Post(id: integer, garage_id: integer, user_id: integer, kind: string, created_at: datetime, updated_at: datetime) <br /><br /></code>&gt; (Post.new).to_json<br />=&gt; "{\"created_at\":null,\"garage_id\":null,\"id\":null,\"kind\":null,\"updated_at\":null,\"user_id\":null}" </pre>&#13;
<p>これは見難いよね。<br />でも素直にやると怒られる。</p>&#13;
<pre>&gt; JSON.pretty_generate(Post.new)<br />NoMethodError: undefined method `key?' for #&lt;JSON::Ext::Generator::State:0x007fd6bb6ff3a8&gt;</pre>&#13;
<p>ちょっと力技。</p>&#13;
&#13;
<pre>&gt; JSON.pretty_generate(JSON.parse((Post.new).to_json))&#13;
 =&gt; "{\n  \"created_at\": null,\n  \"garage_id\": null,\n  \"id\": null,\n  \"kind\": null,\n  \"updated_at\": null,\n  \"user_id\": null\n}"</pre>&#13;
<div><br />okっぽい。仕上げにputs</div>&#13;
<div>&#13;
<pre>&gt; puts JSON.pretty_generate(JSON.parse((Post.new).to_json))&#13;
{&#13;
  "created_at": null,&#13;
  "garage_id": null,&#13;
  "id": null,&#13;
  "kind": null,&#13;
  "updated_at": null,&#13;
  "user_id": null&#13;
}&#13;
 =&gt; nil</pre>&#13;
</div>&#13;
<div></div>&#13;
<div>どなたか良いgemなりスマートな方法が合ったら教えて下さい。</div> 