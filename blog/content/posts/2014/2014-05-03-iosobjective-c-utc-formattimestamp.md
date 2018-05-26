+++
date = "2014-05-03T01:54:04+00:00"
draft = false
tags = ["ios", "objective-c", "utc", "datetime"]
title = "[ios][objective-c] utc formatのtimestamp取得"
+++
UTC時間を取得したい

	NSDate *currentDate = [[NSDate alloc] init];

さて、こいつをNSDateFormatterにtimezoneをUTCをセットしてやれば大丈夫
	
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [formatter setTimeZone:timeZone];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
	NSString *localDateString = [formatter stringFromDate:currentDate];
	
	
明示的にUTC timeを指定せずとも、基本はUTCになっているので、
	


    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
	NSString *localDateString = [formatter stringFromDate:currentDate];
	
	
でもOK