+++
date = "2018-05-02T20:10:00+09:00"
title = "Refine intercom UI"
tags = ["intercom", "ui", "chrome", "extension"]
categories = ["programming"]
+++

Reproではテクニカルなサポートに[intercom](https://www.intercom.com/)を利用している。

最近UIもrenewalされたが、まだ痒いところに手が届いていない状況であることは否めない。

そういうところを直すために、 [refine-intercom](https://github.com/threetreeslight/refined-intercom) というextentionを作った。

## Automatically ellipsis email history

![](/images/blog/2018/05/automatically_ellipsis_email_history.png)

チケット管理の観点からも、なるべく社内外からの問い合わせ回答する場所をintercomに一本化しており、その問い合わせ経路の一つにemailがある。
このとき、emailでやり取りしていたお客様から、テクニカルな質問があるときは途中からtechnical supportにバトンタッチされる。

これはとても良いことなのだが、大きな問題はemailの履歴である。

この履歴がintercomの会話パネルを全て埋め尽くす。いくらスクロールしても終わらない状態。とはいえ、読みたいときもゼロではない。
こういう状態が続いていたわけです。

このような問題を解決するために、emailの履歴とみられる情報をconversation上に見つけたらdetail tagで括って、必要となるまで非表示にしてしまうようにしました。

ここらへんはintercomさんでうまくやってくれるとユーザービリティ高いのになぁ

## Expand conversation window

![](/images/blog/2018/05/expand_conversation_window_button.png)

チャットツールをディスプレイ縦置きした状態で見る人は少なからずいるはずで、例に漏れず私もその一員である。

このとき問題なのが、full HDサイズのディスプレイを縦置きすると横幅が1080になる。

コードを書くときはこれで問題ないのだが、チャットする上では、こう会話ペインがぎゅっと小さくなるわけだ。
そうしたときに、常に見たいわけではない情報を隠したい。

このために右ペインのペルソナ情報を隠すボタンを作った。

今思うとキーボードショートカットを割り当てたほうが良かった気もしている。


## Essential tag validator

![](/images/blog/2018/05/essential_conversation_tags-missing.png)

単純に問い合わせを受けて処理するだけなら問題ないのだが、問い合わせの機能や種別、処理時間を分析したいニーズは往々にあると思う。

そういうニーズに対してintercomは正直まだまだ行けてなくて辛い。
なので、会話にタグ (e.g. `feature-push` など ) を付けてzendeskやgoogle spreadsheetに記録して分析している。

そういうときに問題と成るのが、分析軸となる担当者のtagのつけ忘れである。

この問題に対応するために、必要なtagのprefixをchromeのstorageに記録しておき、最初のconversationのタグ情報をチェックするようにした。

こうすることで、タグつけ忘れが見える化され、問題が解決されることを祈る。

あっタグ情報はstorageに記録以外にも、gistなりs3なりにおいたファイルをパースして取得するようにしておけば、各位の設定漏れもなくなるから良いのかなぁ

