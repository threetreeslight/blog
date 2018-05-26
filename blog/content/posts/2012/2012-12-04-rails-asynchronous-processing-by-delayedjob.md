+++
date = "2012-12-04T23:11:13+00:00"
draft = false
tags = ["rails", "deleayed_job", "callback"]
title = "[rails] Asynchronous processing by delayed_job"
+++
<p>今回作っているプロダクトにてサーバーサイドの非同期処理を行う必要が有るので検討してみた。</p>
<p>ポーリングや非同期コールバックなどの方法が有るので色々と、</p>
<ul><li>Rabbit MQとか使う。</li>
<li>rubyのevent machine使って頑張る。</li>
<li>node.jsで書いてみる。</li>
<li>delayed_job gem使ってサクット。</li>
</ul><p>な感じなわけだけど、かっこいいのはRabbit MQによる実装だと思っているけれども（能力的にも）、時間がかかりそうなのでdelayed_jobでやることにしました。
入れ方は下記の通り。

</p><p><br></p><p><b>Gem入れる</b></p>
<pre>$ vim Gemfile

gem 'delayed_job_active_record'
gem "daemons"
</pre>
<p><br></p><p><b>キューを貯めるテーブルとバックグラウンドワーカー用スクリプトをインストール</b></p>
<pre># db
$ rails g delayed_job:active_record
$ rake db:migrate

# script
$ rails g delayed_job
</pre>

<p><b>delayed_jobの設定</b></p>

<pre># config/initializers/delayed_job_config.rb
Delayed::Worker.destroy_failed_jobs = false # false : if job false, DB record not remove and remain with faild_at time.
Delayed::Worker.sleep_delay = 60
Delayed::Worker.max_attempts = 3 # max challenge times
Delayed::Worker.max_run_time = 5.minutes
Delayed::Worker.read_ahead = 10
Delayed::Worker.delay_jobs = !Rails.env.test? # if test env, delayed job not working
</pre>


<p><b>起動・停止</b></p>
<p>* rails envはお好みで</p>
<pre>$ RAILS_ENV=production script/delayed_job start
$ RAILS_ENV=production script/delayed_job stop
 </pre>
<p><br>利用は簡単で".delay.<i>methodname</i>"で終わり。</p>
<pre>User.delay.hogehoge</pre>
<p><br><br>参考</p>
<ul><li><a href="https://github.com/collectiveidea/delayed_job">https://github.com/collectiveidea/delayed_job</a></li>
</ul>