+++
date = "2014-06-16T05:31:21+00:00"
draft = false
tags = ["objc", "bool", "category"]
title = "[objctive-c][ios]primitiveな変数をカテゴリ拡張したい"
+++
さて、boolやintなどpremitiveな変数をカテゴリ拡張して扱えない。

KVCが行えないため、setterやgetterを定義できないため。

## intの場合

intの場合はNSNumberを使えば問題ないのだけど、BOOLはそうもいかない。

## Boolの場合

不可能なので、NSNumberからのboolvalueで代用

header file

	@property (nonatomic, strong, readonly) NSNumber 	*foo;

method file
	
	@dynamic foo;
	
	- (NSNumber *)foo
	{
	    return objc_getAssociatedObject(self, @selector(setFoo:));
	}
	
	- (void)setFoo:(NSNumber *)foo
	{
		objc_setAssociatedObject(self, _cmd, foo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}

からのboolValue setterは

	self.foo = [NSNumber numberWithBool:YES];

からのboolValue getterは

	- (BOOL)boolFoo
	{
	    if (self.foo) {
	        return [self.foo boolValue];
	    }
	    return NO;
	}


という感じ。



参照：[how-to-add-bool-property-to-a-category](http://stackoverflow.com/questions/9776811/how-to-add-bool-property-to-a-category)
