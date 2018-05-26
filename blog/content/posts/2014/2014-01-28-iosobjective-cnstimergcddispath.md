+++
date = "2014-01-28T14:01:44+00:00"
draft = false
tags = ["dispatch", "GCD", "NSTimer", "ios", "objective-c"]
title = "[ios][objective-c]NSTimerの中でGCD(dispath)出来るか？"
+++
こういうときはstackoverflow先生を探るのが一番

> NSTimers are scheduled on the current thread's run loop. However, GCD dispatch threads don't have run loops, so scheduling timers in a GCD block isn't going to do anything.


NSTimerはメインスレッドのrun loopにスケジュールされていて、GCDのディスパッチスレッドはrun loopを持っていないからタイマースケジューリングでの動作は出来ないよ。


以下は３つの代替手段についての説明なので割愛。。
 

> There's three reasonable alternatives:

> 1. Figure out what run loop you want to schedule the timer on, and explicitly do so. Use +[NSTimer timerWithTimeInterval:target:selector:userInfo:repeats:] to create the timer and then -[NSRunLoop addTimer:forMode:] to actually schedule it on the run loop you want to use. This requires having a handle on the run loop in question, but you may just use +[NSRunLoop mainRunLoop] if you want to do it on the main thread.
> 1. Switch over to using a timer-based dispatch source. This implements a timer in a GCD-aware mechanism, that will run a block at the interval you want on the queue of your choice.
> 1. Explicitly dispatch_async() back to the main queue before creating the timer. This is equivalent to option #1 using the main run loop (since it will also create the timer on the main thread).
> 
> Of course, the real question here is, why are you creating a timer from a GCD queue to begin with?





[Run repeating NSTimer with GCD?](http://stackoverflow.com/questions/10522928/run-repeating-nstimer-with-gcd)