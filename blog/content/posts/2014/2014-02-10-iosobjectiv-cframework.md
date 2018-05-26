+++
date = "2014-02-10T11:53:47+00:00"
draft = false
tags = ["ios", "objective-c", "framework", "iOS Universal Framework"]
title = "[ios][objectiv-c]frameworkの作成"
+++
必要になったので色々調べていたらios用のframeworkってお勧めしないって書いてあった。

けどフツーにframework型のSDK提供されてるじゃん！って調べてみた。

だってdeveloper friendlyだもんね！！

# Foundation

## install [iOS Universal Framework](https://github.com/kstenerud/iOS-Universal-Framework)

	$ git clone https://github.com/kstenerud/iOS-Universal-Framework.git
	
	$ cd iOS-Universal-Framework/
	$ cd Real\ Framework/
	$ ./install.sh
	
	iOS Real Static Framework Installer
	===================================
	
	This will install the iOS static framework templates and support files on your computer.
	Note: Real static frameworks require two xcspec files to be added to Xcode.
	
	*** THIS SCRIPT WILL ADD THE FOLLOWING FILES TO XCODE ***
	
	 * Platforms/iPhoneOS.platform/Developer/Library/Xcode/Specifications/UFW-iOSStaticFramework.xcspec
	 * Platforms/iPhoneSimulator.platform/Developer/Library/Xcode/Specifications/UFW-iOSStaticFramework.xcspec
	
	Where is Xcode installed? (CTRL-C to abort) [ /Applications/Xcode.app/Contents/Developer ]:
	
	I am about add the following files to support real static iOS frameworks:	
	
	 * /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/Library/Xcode/Specifications/UFW-iOSStaticFramework.xcspec
	 * /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/Library/Xcode/Specifications/UFW-iOSStaticFramework.xcspec
	
	The templates will be installed in /Users/mikiakira/Library/Developer/Xcode/Templates/Framework & Library
	
	continue [y/N]: y
	
	
	[ Installing xcspec file ]
	
	sudo cp /Users/mikiakira/dev/temp/iOS-Universal-Framework/Real Framework/UFW-iOSStaticFramework.xcspec /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/Library/Xcode/Specifications/
	Password:
	sudo cp /Users/mikiakira/dev/temp/iOS-Universal-Framework/Real Framework/UFW-iOSStaticFramewo
	
こんな感じでinstall完了。

	
# Create Framework

とりあえずフレームワーク作ってみます。

公式の流れは以下の通り。

[Creating an iOS Framework Project](https://github.com/kstenerud/iOS-Universal-Framework#creating-an-ios-framework-project)

> 1. Start a new project.
> 1. For the project type, choose Static iOS Framework (or Fake Static iOS Framework), which is under Framework & Library.
> 1. Optionally choose to include unit tests.
> 1. Add the auto-generated header file to the Public section of the Copy Headers build phase (workaround for Xcode bug).
> 1. Turn off Show environment variables in build log for both Run Script build phases (workaround for Xcode bug).
> 1. Add your classes, resources, etc with your framework as the target.
> 1. Any header files that need to be available to other projects must be declared public. To do so, go to Build Phases in your framework target, expand Copy Headers, then drag any header files you want to make public from the Project or Private section to the Public section.
> 1. Any static libraries or static frameworks that you'd like to have linked into your framework must be included in the Link Binary With Libraries build phase. Be careful doing this, however, as it can cause linker issues if the users of your framework also try to include the same library in their project for other purposes.

## create new project

Static iOS FrameworkにてFooプロジェクトを作成します。

* select `Framework & Library > Static iOS Framework`
* project name : Foo

## project settings

公開するheaderファイルを追加します。

Fooプロジェクト > Build Phases > Copy Headers

Foo.hを追加します。

## add sample methods


Foo.h

	
	#import <Foundation/Foundation.h>
	
	@interface Foo : NSObject
	
	- (NSString *)whoami;
	
	@end

Foo.m
	
	#import "Foo.h"
	
	@implementation Foo
	
	- (NSString *)whoami
	{
	    return @"i am Foo.";
	}
	
	@end


## compile

`Products > Archive`

実行するとbuild先のディレクトリが自動的に開かれます。

そこには２つのframeworkファイルが作成されます。

* (your framework).framework
* (your framework).embeddedframework


今回は、画像とかのassetを含まず、１ソースのため`Foo.framework`のみです。

これでFrameworkは完了！

# add compiled framework to Already Project

作ったframeworkをサンプルプログラムに組み込みます。

## create new project 

Single View ApplicationでBarというプロジェクトを作成します。

## assign framework

vendorディレクトリを作成し、そこに作成したframeworkを配置します。

	$ mkdir ${project_home}/vendor
	$ open .
	Foo.frameworkをコピペします。
	
BarプロジェクトのLinked Frameworks and Librariesにて、vendor配下のFoo.frameworkを追加します


## Add sample code

今回はapp load時にwhoamiの結果をlogに表示します。

viewController.m

	#import "ViewController.h"
	#import <Foo/Foo.h>
	
	@interface ViewController ()
	
	@end
	
	@implementation ViewController
	
	- (void)viewDidLoad
	{
	    [super viewDidLoad];
		// Do any additional setup after loading the view, typically from a nib.
				 
	    Foo *foo = [[Foo alloc] init];
	    NSLog(@"%@", [foo whoami]);
	}
	
	- (void)didReceiveMemoryWarning
	{
	    [super didReceiveMemoryWarning];
	    // Dispose of any resources that can be recreated.
	}
	
	@end


# その他

## ARCにソースが対応していない場合

select `Build Phases` > `compile sources`

* add  `-fno-objc-arc` to `Foo.m`


## Error : target specifies product type 'com.apple.product-type.framework.static',

こんなエラーに苦しめられたりする場合は公式のTroubleshootingを参照

[No Such Product Type](https://github.com/kstenerud/iOS-Universal-Framework#no-such-product-type)


	target specifies product type 'com.apple.product-type.framework.static',
	but there's no such product type for the 'iphonesimulator' platform

> Xcode requires some modification in order to be able to build true iOS static frameworks (see the two diff files in the "Real Framework" folder of this repository for the gory details), so please install it on all development machines that will build your real static framework projects (this isn't needed for users of your framework, only for builders of the framework).

ようは
