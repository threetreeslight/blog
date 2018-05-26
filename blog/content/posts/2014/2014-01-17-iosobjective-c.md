+++
date = "2014-01-17T09:00:03+00:00"
draft = false
tags = ["iOS", "objective-c", "directory", "file"]
title = "[iOS][Objective-C]ディレクトリ・ファイル検索／作成"
+++
全体的に[FileSystemProgrammingGuide.pdf](https://developer.apple.com/jp/devcenter/ios/library/documentation/FileSystemProgrammingGuide.pdf)とリファレンスで何とかなる。

## 各directoryの利用目的

[FileSystemProgrammingGuide.pdf](https://developer.apple.com/jp/devcenter/ios/library/documentation/FileSystemProgrammingGuide.pdf)を読むべし


dir | attr
--- | ---
<Application_Home>/document | applicationにて保存されるファイル。iCloudと同期
<Application_Home>/Library/Preferences | アプリ設定値。iCloudと同期
<Applicaiton_Home>/Library/Caches/ | キャッシュ、fore/back問わずiOS制御下にて、必要に応じて削除される。
<Application_Home>/tmp | テンポラリ、back時にiOS制御下に入り、必要に応じてファイルの削除が行われる。

参考：[
iOS /tmpと/Cachesディレクトリの違いと運用方法](http://qiita.com/yusuga_/items/8c057a67e0ac021c54bc)

## 各directoryへのpath取得

	// <Application_Home>/document
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *path = [paths objectAtIndex:0];

	// <Application_Home>/Library/Preferences
	// このディレクトリはNSUserDefaults or CFPreferencesAPI経由で読み書きする。
	
	// <Applicaiton_Home>/Library/Caches/
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *path = [paths objectAtIndex:0];

	// <Application_Home>/tmp
	NSTemporaryDirectory()
	

参考：[[iOS SDK] アプリケーションディレクトリの構造とアクセス方法](http://d.hatena.ne.jp/ntaku/20110104/1294146555)

## directory一覧の取得

forでまわすのではなく、一括で取得


	NSURL *url = <#A URL for a directory#>;
	NSError *error = nil;
	NSArray *properties = [NSArray arrayWithObjects: NSURLLocalizedNameKey,
	                       NSURLCreationDateKey, NSURLLocalizedTypeDescriptionKey,
	                       nil];
	NSArray *array = [[NSFileManager defaultManager]
	                  contentsOfDirectoryAtURL:url
	                  includingPropertiesForKeys:properties
	                  options:(NSDirectoryEnumerationSkipsPackageDescendants |
	                           NSDirectoryEnumerationSkipsHiddenFiles)	                  error:&error];
	if (array == nil) {
	    // エラーを処理する
	}


参考：[FileSystemProgrammingGuide.pdf](https://developer.apple.com/jp/devcenter/ios/library/documentation/FileSystemProgrammingGuide.pdf)


## directoryの存在確認

	// pathを生成
    NSString *path = [NSTemporaryDirectory() stringByAppendingString:@"foo"];
    
    BOOL isDirectory = NO; // NOで初期化
    [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];
    
    if (isDirectory) { // パス存在且つディレクトリ時のみ通過

    }
    
 
参考：[ファイルやディレクトリが存在するかを判定する](http://program.station.ez-net.jp/special/handbook/objective-c/nsfilemanager/is-file-exists-at-path.asp)
 
## directoryの生成

    NSFileManager*fm = [NSFileManager defaultManager];
    NSURL* dirPath = NSTemporaryDirectory();
    
    // ディレクトリが存在しない場合、このメソッドにより作成される
    // このメソッド呼び出しはOS X 10.7以降でのみ機能する
    NSError* theError = nil;
    if (![fm createDirectoryAtURL:dirPath withIntermediateDirectories:YES
                               attributes:nil error:&theError])
    {
        // エラーを処理する。
    }

    

参考：[FileSystemProgrammingGuide.pdf](https://developer.apple.com/jp/devcenter/ios/library/documentation/FileSystemProgrammingGuide.pdf) P73

  
