+++
date = "2013-05-31T14:22:45+00:00"
draft = false
tags = ["google", "adwords", "conversion", "conversion tracking", "document.write", "ajax"]
title = "google adwordsのconversion.jsをajaxで頑張った。"
+++
ajaxでscriptを実行しても、google adwordsのコンバージョン用のリクエストが飛ばない。こんなのってないよ。


という訳で、頑張ってgoogle adwordsのconversion.jsを（ある程度）読みました。

以下処理順に書きます。

（間違いも多く有るかと思いますが、ご愛嬌で。）

### デバッグモードとの切替
***


最初にデバッガーモードか確かめてる。

    var F = window;
    if (F) if (/[\?&;]google_debug/.exec(document.URL) != f) {
            var K = F,
                L = document.getElementsByTagName("head")[0];
            L || (L = document.createElement("head"), document.getElementsByTagName("html")[0].insertBefore(L, document.getElementsByTagName("body")[0]));
            var M = document.createElement("script");
            M.src = B(window) + "//" + C(K) + "/pagead/conversion_debug_overlay.js";
            L.appendChild(M)


### コンバージョンのリクエスト送信是非を判別
***

windowオブジェクトにおけるメンバ変数の状態にてコンバージョンリクエストの実行是非を判別。


    } else {
        try {
            var N;
            var O = F;
            "landing" == O.google_conversion_type || !O.google_conversion_id || O.google_remarketing_only && O.google_disable_viewthrough ? 

以下の状態のいずれか及びviewthroughがオフになっている状態を満たす場合、コンバージョンリクエスト送信状態のフラグ（なのかな？）Nがfalseとなりconversionリクエストを送信しない。

	N = !1 :

* conversion typeがlandingである。
* windowオブジェクトにconversion idが格納されていない。
* 設定がリマーケティングのみ設定になっている。

	
コンバージョン状態のフラグNがtrueの場合、conversionリクエストを送信するため、必要な情報を以下の通りwindowオブジェクトに格納する。

	 (O.google_conversion_date = new Date, O.google_conversion_time = O.google_conversion_date.getTime(), O.google_conversion_snippets = "number" == typeof O.google_conversion_snippets && 0 < O.google_conversion_snippets ? O.google_conversion_snippets + 1 : 1, "number" != typeof O.google_conversion_first_time && (O.google_conversion_first_time = O.google_conversion_time), O.google_conversion_js_version = "7", 0 != O.google_conversion_format && (1 != O.google_conversion_format && 2 != O.google_conversion_format && 3 != O.google_conversion_format) &&
                (O.google_conversion_format = 1), n = new m(1), N = !0);


リクエスト送信フラグNの状態によって、document.writeの実行是非を制御する。
このとき、H()関数で必要なimgタグを組み立てている。

	if (N 
		&& ( document.write(H()), ...


### リクエストURLとタグの生成
***

H()関数では、関数D()を実行するための変数を作成。

        function H() {
            var a = F, <- window object
                b = navigator,
                d = document,
                c = F; <- window object

p()の実行をチェック

            3 == c.google_conversion_format && n && p();
            
b = D(a,b,d,c)を実行。

尚、関数D()では、getリクエストのURLを作成する。

            b = D(a, b, d, c);

変数Dを再利用し、埋め込み用imageタグ生成関数dを作成。

            d = function (a, b, c) {
                return '<img height="' + c + '" width="' + b + '" border="0" src="' + a + '" />'
            };

その後、生成したリクエストURLを、ユーザーが任意で押すハイパーリンクとして埋め込むか、getリクエストを発行するタグとしてiframeもしくはimgタグで埋め込むか確定する。

c.google_conversion_formatは、上記の判定に関わっているフラグと想定。

            return 
            	0 == c.google_conversion_format 
            	&& c.google_conversion_domain == f ? 

ハイパーリンクで埋め込む場合

            	'<a href="' 
            	 + (B(a) 
            	 + "//services.google.com/sitestats/" 
            	 + ({
                        ar: 1,
                        bg: 1,
                        cs: 1,
                        da: 1,
                        de: 1,
                        el: 1,
                        en_AU: 1,
                        en_US: 1,
                        en_GB: 1,
                        es: 1,
                        et: 1,
                        fi: 1,
                        fr: 1,
                        hi: 1,
                        hr: 1,
                        hu: 1,
                        id: 1,
                        is: 1,
                        it: 1,
                        iw: 1,
                        ja: 1,
                        ko: 1,
                        lt: 1,
                        nl: 1,
                        no: 1,
                        pl: 1,
                        pt_BR: 1,
                        pt_PT: 1,
                        ro: 1,
                        ru: 1,
                        sk: 1,
                        sl: 1,
                        sr: 1,
                        sv: 1,
                        th: 1,
                        tl: 1,
                        tr: 1,
                        vi: 1,
                        zh_CN: 1,
                        zh_TW: 1
                    }[c.google_conversion_language] ? c.google_conversion_language + ".html" : "en_US.html") 
               + "?cid=" 
               + s(c.google_conversion_id)) 
               + '" target="_blank">' 
               + d(b, 135, 27) 
               + "</a>" 

iframeもしくはimageでの埋め込み判定

               : 1 < c.google_conversion_snippets 
                 || 3 == c.google_conversion_format 
                 ? 

image埋め込み。ここで関数dを使う。（大体の設定ではこちらが実行されると思います）

                 d(b, 1, 1) : 
                 
iframeでの埋め込み

                 '<iframe name="google_conversion_frame" width="' 
                 + (2 == c.google_conversion_format ? 200 : 300) 
                 + '" height="' 
                 + (2 == c.google_conversion_format ? 26 : 13) 
                 + '" src="' 
                 + b 
                 + '" frameborder="0" marginwidth="0" marginheight="0" vspace="0" hspace="0" allowtransparency="true" scrolling="no">' 
                 +
                d(b.replace(/\?random=/, "?frame=0&random="), 1, 1) 
                + "</iframe>"
        }


### タグの埋め込み
***

実際に埋め込む処理についてだが、以下のようにdocument.writeしてしまっては既存のdomが全部消えてしまう


	if (N 
		&& ( document.write(H()), 
			 F.google_remarketing_for_search 
			 && !F.google_conversion_domain)
			) 
	{
                        var G = F;
                        J()
                    }
                  
                  
  
尚、以下の処理によって、windowオブジェクトのgoogle メンバがcleanupされ、２回目以降はNがfalseとなる。

	var f = null;
	…

	var n, r = "google_conversion_id google_conversion_format google_conversion_type google_conversion_order_id google_conversion_language google_conversion_value google_conversion_domain google_conversion_label google_conversion_color google_disable_viewthrough google_remarketing_only google_remarketing_for_search google_conversion_items google_custom_params google_conversion_date google_conversion_time google_conversion_js_version onload_callback opt_image_generator google_is_call google_conversion_page_url".split(" ");
	…
	
	var F = window;
	…	
	
    for (var Q = F, R = 0; R < r.length; R++) Q[r[R]] = f


で、問題なのがajaxで追加された場合、document.write()の挙動でした。

### ajaxロードされたスクリプトによるdocument.write()の実行
***

なぜこんな事をしたいかというと、google adwordsのコンバージョン計測のトリガーをajaxで処理したかった事がきっかけです。


で、document.write()は動的に追加されたスクリプトで実行しようとすると、こける。
というか追加されない。

ブラウザによって挙動が違うよう。


かなり汚いやり方ですが、以下のようにdocument.writeを配列にpushする処理へオーバーライドして処理をしたいと思います。

googleadwordsから提供されているconversion.jsには、もちろんcallback処理なんてありません。
そのため、setTimeoutの再起処理で配列への追加をチェックします。

	  document._write = document.write
	  document.write = (s) -> html.push(s)
	  html = []
	  $.ajax({
	    type: "GET",
	    url: '//www.googleadservices.com/pagead/conversion.js',
	    dataType: "script",
	    success: ->
	      append_check = (e) ->
	        setTimeout(
	          (e) ->
	            console.log('apend_check', html)
	            if html.length > 0
	              console.log(html.join(''))
	              $('body').append(html.join(''))
	              document.write = document._write
	            else
	              append_check()
	          , 1000)
	      append_check()
	  })




### P.S. 読んで学んだjavascriptの最小化の手法
***

booleanフラグ

	> N = !1 
	false
	> N = !0
	true

if文を利用しない関数実行判定
	
	> 3 == hoge && pug()

関数実行をif分の中に埋め込む

	if (N && ( document.write(H()), 
			 F.google_remarketing_for_search 
			 && !F.google_conversion_domain) {
	  . . .
	}


変数は必ず再利用

基本三項演算子

nullを変数かして、それを再利用する。

	null -> 4文字
	f = null;
	f -> 1文字

パラメーター名は事前に配列化しておく

        var n, r = "google_conversion_id google_conversion_format google_conversion_type google_conversion_order_id google_conversion_language google_conversion_value google_conversion_domain google_conversion_label google_conversion_color google_disable_viewthrough google_remarketing_only google_remarketing_for_search google_conversion_items google_custom_params google_conversion_date google_conversion_time google_conversion_js_version onload_callback opt_image_generator google_is_call google_conversion_page_url".split(" ");

