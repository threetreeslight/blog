+++
date = "2014-03-18T13:17:35+00:00"
draft = false
tags = ["objective-c", "objc", "ios", "json", "response"]
title = "[Objective-c][iOS]Jsonレスポンスからbool値を取り出す方法"
+++
Json responseをNSDictionaryにperseすると、bool値がNSNumberクラスのNSCFBooleanに変換されています。

## requestはだいたいこんな感じ

    // generate request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:kRequestURL]];
    [request setHTTPMethod:@"GET"];
    [request setHTTPBody:[query dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (connection) {
        [NSMutableData data];
    }
    
    // send request
    NSURLResponse *response;
    NSError *responseError = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request

    // Offiline Error or request with Incorrect token
    if (responseError) {
        if (error) {
            NSDictionary *errorDic = @{ NSLocalizedDescriptionKey:@"The Internet connection appears to be offline.", };

            *error = [NSError errorWithDomain:RPRErrorDomain
                                         code:RPRErrorOfflineInternet
                                     userInfo:errorDic];
        }
        return;
    }
    

    // decode to json
    NSString *responseJson = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSData *responseJsonData = [responseJson dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseJsonData
                                                              options:NSJSONReadingAllowFragments error:nil];
    
    
## そのときのJsonResponse

	{
		status: true
	}
	
とかだったりする。


## NSDictionaryの値は

	(lldb) po responseDict[@"status"]
	1
	(lldb) po responseDict[@"status"] == 1
	<nil>
	
ほう、、、Numberリテラルではないというのか、、、

	(lldb) po [responseDict[@"status"] class]
	__NSCFBoolean
	
NSCFBoolean???


> All this time, we've been led to believe that NSNumber boxes primitives into an object representation. Any other integer- or float-derived NSNumber object shows its class to be __NSCFNumber. What gives?
> 
> NSCFBoolean is a private class in the NSNumber class cluster. It is a bridge to the CFBooleanRef type, which is used to wrap boolean values for Core Foundation property lists and collections.
> 
> \- [BOOL / bool / Boolean / NSCFBoolean](http://nshipster.com/bool/)


Boolなどのプリミティブはオブジェクトではないので、NSDictionaryとの相性が悪い。というわけでNSNumberにparseされて格納されているという訳。

つまり、Bool値を取り出すためには

	(lldb) po [(NSNumber *)responseDict[@"status"] boolValue]

とすれば良い

## 参考

* [How to test NSCFBoolean value?](http://stackoverflow.com/questions/11756795/how-to-test-nscfboolean-value)
* [BOOL / bool / Boolean / NSCFBoolean](http://nshipster.com/bool/)