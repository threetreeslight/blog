+++
date = "2014-05-18T09:29:59+00:00"
draft = false
tags = ["ios", "objective-c"]
title = "[iOS][objective-c] fixed timepstamp to AD"
+++
普通にNSDateから日付を取得してしまうと、端末に依存した時刻表示に成ってしまう。

	// 取得
	[NSDate date]
		
そのため、timestampはfomatterよりUTC且つ西暦で固定で取得するようにする。

	_formatter = [[NSDateFormatter alloc] init];
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[_formatter setCalendar:calendar];
	[_formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
	[_formatter setDateFormat:@"yyyyMMddHHmmss"];