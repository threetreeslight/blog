+++
date = "2014-06-11T10:42:57+00:00"
draft = false
tags = ["objective-c", "ios", "UIWindow", "subviews"]
title = "[objective-c][ios]表示されている画面のsubview取得"
+++
今回はsubviewにどんな子が入っているか調べたいと思います


## 表示されている画面の取得

表示されている画面のsubviewの取得には、大まかに２つの方法が考えられます。

1. `UIViewController`のviewDidLoadから取り上げる。
2. `[[UIApplication] sharedApplication]`から取得する。

そのタイミングのものを取得するとした場合は２が最適だと思ってます。

## sharedApplicationから取得する方法

2way

- UIWindow -> subviews -> view
- UIWindow -> rootViewController -> view


### singleView

こんな感じで実装
	
	- (void)viewDidAppear:(BOOL)animated
	{
	    UIWindow *window  = [UIApplication sharedApplication].keyWindow;
	    NSLog(@"keyWindow : %@", window);
	    
	    NSLog(@"UIWindow -> view ----------------------------------------");
	    NSLog(@"<UIWindow> subviews : %@", window.subviews);
	    UIView *view = window.subviews[0];
	    NSLog(@"<UIWindow> top view: %@", view);
	    NSLog(@"<UIWindow> topView->subviews: %@", view.subviews);
	    
	    NSLog(@"UIWindow -> rootViewController -> view ----------------------");
	    UIViewController *rootViewController = window.rootViewController;
	    NSLog(@"<rootViewController> : %@", rootViewController);
	    UIView *rootView = rootViewController.view;
	    NSLog(@"<rootViewController> rootView : %@", rootView);
	    NSLog(@"<rootViewController> rootView->subviews : %@", rootView.subviews);
	 
	}


こんな感じで取れます。

	
	keyWindow : <UIWindow: 0x8d5e1f0; frame = (0 0; 320 568); autoresize = W+H; gestureRecognizers = <NSArray: 0x8d5e110>; layer = <UIWindowLayer: 0x8d5f420>>
	UIWindow -> view ----------------------------------------
	<UIWindow> subviews : (
	    "<UIView: 0x8c8ac80; frame = (0 0; 320 568); autoresize = RM+BM; layer = <CALayer: 0x8c8a280>>"
	)
	<UIWindow> top view: <UIView: 0x8c8ac80; frame = (0 0; 320 568); autoresize = RM+BM; layer = <CALayer: 0x8c8a280>>
	<UIWindow> topView->subviews: (
	    "<UITextField: 0x8c8ace0; frame = (84 82; 152 30); text = ''; clipsToBounds = YES; opaque = NO; autoresize = RM+BM; gestureRecognizers = <NSArray: 0x8d44cf0>; layer = <CALayer: 0x8c8a750>>",
	    "<UITextView: 0x9884600; frame = (0 264; 320 310); text = 'Lorem ipsum dolor sit er ...'; clipsToBounds = YES; autoresize = RM+BM; gestureRecognizers = <NSArray: 0x8e40760>; layer = <CALayer: 0x8d51df0>; contentOffset: {0, 0}>",
	    "<_UILayoutGuide: 0x8d69710; frame = (0 0; 0 20); hidden = YES; layer = <CALayer: 0x8d69820>>",
	    "<_UILayoutGuide: 0x8d69cb0; frame = (0 568; 0 0); hidden = YES; layer = <CALayer: 0x8d69da0>>"
	)
	UIWindow -> rootViewController -> view ----------------------
	<rootViewController> : <ViewController: 0x8d5f000>
	<rootViewController> rootView : <UIView: 0x8c8ac80; frame = (0 0; 320 568); autoresize = RM+BM; layer = <CALayer: 0x8c8a280>>
	<rootViewController> rootView->subviews : (
	    "<UITextField: 0x8c8ace0; frame = (84 82; 152 30); text = ''; clipsToBounds = YES; opaque = NO; autoresize = RM+BM; gestureRecognizers = <NSArray: 0x8d44cf0>; layer = <CALayer: 0x8c8a750>>",
	    "<UITextView: 0x9884600; frame = (0 264; 320 310); text = 'Lorem ipsum dolor sit er ...'; clipsToBounds = YES; autoresize = RM+BM; gestureRecognizers = <NSArray: 0x8e40760>; layer = <CALayer: 0x8d51df0>; contentOffset: {0, 0}>",
	    "<_UILayoutGuide: 0x8d69710; frame = (0 0; 0 20); hidden = YES; layer = <CALayer: 0x8d69820>>",
	    "<_UILayoutGuide: 0x8d69cb0; frame = (0 568; 0 0); hidden = YES; layer = <CALayer: 0x8d69da0>>"
	)
	

single viewだと、これはどちらとも言えない。どっちも変わらない感じに成る。

### tableView

こんな感じの実装を、MasterViewControllerとDetailViewControllerに書いておく。


	- (void)viewDidAppear:(BOOL)animated
	{
	    UIWindow *window  = [UIApplication sharedApplication].keyWindow;
	    NSLog(@"keyWindow : %@", window);
	    
	    NSLog(@"UIWindow -> view ----------------------------------------");
	    NSLog(@"<UIWindow> subviews : %@", window.subviews);
	    UIView *view = window.subviews[0];
	    NSLog(@"<UIWindow> top view: %@", view);
	    NSLog(@"<UIWindow> topView->subviews: %@", view.subviews);
	    
	    NSLog(@"UIWindow -> rootViewController -> view ----------------------");
	    UIViewController *rootViewController = window.rootViewController;
	    NSLog(@"<rootViewController> : %@", rootViewController);
	    UIView *rootView = rootViewController.view;
	    NSLog(@"<rootViewController> rootView : %@", rootView);
	    NSLog(@"<rootViewController> rootView->subviews : %@", rootView.subviews);
	    
	    NSLog(@"UIWindow -> rootViewController -> currentViewController -> view ----------------------");
	    if ( [rootViewController isKindOfClass:[UINavigationController class]] ) {
	        UIViewController *currentViewController = [(UINavigationController *)rootViewController topViewController];
	        NSLog(@"<currentViewController> : %@", currentViewController);
	        UIView *currentView = currentViewController.view;
	        NSLog(@"<currentViewController> view: %@", currentView);
	        NSLog(@"<currentViewController> view->subviews: %@", currentView.subviews);
	    }
	 
	}
 

で確認してみる。

MasterViewController上

	keyWindow : <UIWindow: 0x8d2abd0; frame = (0 0; 320 480); gestureRecognizers = <NSArray: 0x8f142f0>; layer = <UIWindowLayer: 0x8d27970>>
	UIWindow -> view ----------------------------------------
	<UIWindow> subviews : (
	    "<UILayoutContainerView: 0x8d248b0; frame = (0 0; 320 480); autoresize = W+H; gestureRecognizers = <NSArray: 0x8c5d360>; layer = <CALayer: 0x8d24c10>>"
	)
	<UIWindow> top view: <UILayoutContainerView: 0x8d248b0; frame = (0 0; 320 480); autoresize = W+H; gestureRecognizers = <NSArray: 0x8c5d360>; layer = <CALayer: 0x8d24c10>>
	<UIWindow> topView->subviews: (
	    "<UINavigationTransitionView: 0x8c31260; frame = (0 0; 320 480); clipsToBounds = YES; autoresize = W+H; layer = <CALayer: 0x8c334c0>>",
	    "<UINavigationBar: 0x8d24940; frame = (0 20; 320 44); opaque = NO; autoresize = W; gestureRecognizers = <NSArray: 0x8d294b0>; layer = <CALayer: 0x8d24a50>>"
	)
	UIWindow -> rootViewController -> view ----------------------
	<rootViewController> : <UINavigationController: 0x8e5a910>
	<rootViewController> rootView : <UILayoutContainerView: 0x8d248b0; frame = (0 0; 320 480); autoresize = W+H; gestureRecognizers = <NSArray: 0x8c5d360>; layer = <CALayer: 0x8d24c10>>
	<rootViewController> rootView->subviews : (
	    "<UINavigationTransitionView: 0x8c31260; frame = (0 0; 320 480); clipsToBounds = YES; autoresize = W+H; layer = <CALayer: 0x8c334c0>>",
	    "<UINavigationBar: 0x8d24940; frame = (0 20; 320 44); opaque = NO; autoresize = W; gestureRecognizers = <NSArray: 0x8d294b0>; layer = <CALayer: 0x8d24a50>>"
	)
	UIWindow -> rootViewController -> currentViewController -> view ----------------------
	<currentViewController> : <MasterViewController: 0x8e5ac00>
	<currentViewController> view: <UITableView: 0xa12c200; frame = (0 0; 320 480); clipsToBounds = YES; opaque = NO; autoresize = W+H; gestureRecognizers = <NSArray: 0x8e5ca30>; layer = <CALayer: 0x8d2e3d0>; contentOffset: {0, -64}>
	<currentViewController> view->subviews: (
	    "<UITableViewWrapperView: 0x8e581a0; frame = (0 0; 320 480); autoresize = W+H; layer = <CALayer: 0x8e19ac0>>",
	    "<UIImageView: 0x8f1bfe0; frame = (0 412.5; 320 3.5); alpha = 0; opaque = NO; autoresize = TM; userInteractionEnabled = NO; layer = <CALayer: 0x8f33c30>> - (null)",
	    "<_UITableViewCellSeparatorView: 0x8e62d60; frame = (15 43.5; 305 0.5); autoresize = W; layer = <CALayer: 0x8e62e70>>",
	    "<_UITableViewCellSeparatorView: 0x8e63090; frame = (15 87.5; 305 0.5); autoresize = W; layer = <CALayer: 0x8e63180>>",
	    "<_UITableViewCellSeparatorView: 0x8e631c0; frame = (15 131.5; 305 0.5); autoresize = W; layer = <CALayer: 0x8e63230>>",
	    "<_UITableViewCellSeparatorView: 0x8e63270; frame = (15 175.5; 305 0.5); autoresize = W; layer = <CALayer: 0x8e632e0>>",
	    "<_UITableViewCellSeparatorView: 0x8e63320; frame = (15 219.5; 305 0.5); autoresize = W; layer = <CALayer: 0x8e63390>>",
	    "<_UITableViewCellSeparatorView: 0x8e633f0; frame = (15 263.5; 305 0.5); autoresize = W; layer = <CALayer: 0x8e63460>>",
	    "<_UITableViewCellSeparatorView: 0x8e63490; frame = (15 307.5; 305 0.5); autoresize = W; layer = <CALayer: 0x8e63500>>",
	    "<_UITableViewCellSeparatorView: 0x8e63540; frame = (15 351.5; 305 0.5); autoresize = W; layer = <CALayer: 0x8e635b0>>",
	    "<_UITableViewCellSeparatorView: 0x8e635f0; frame = (15 395.5; 305 0.5); autoresize = W; layer = <CALayer: 0x8e63660>>",
	    "<_UITableViewCellSeparatorView: 0x8e636e0; frame = (15 439.5; 305 0.5); autoresize = W; layer = <CALayer: 0x8e63750>>",
	    "<_UITableViewCellSeparatorView: 0x8e63790; frame = (15 483.5; 305 0.5); autoresize = W; layer = <CALayer: 0x8e63800>>",
	    "<_UITableViewCellSeparatorView: 0x8e63840; frame = (15 527.5; 305 0.5); autoresize = W; layer = <CALayer: 0x8e638b0>>",
	    "<_UITableViewCellSeparatorView: 0x8e638f0; frame = (15 571.5; 305 0.5); autoresize = W; layer = <CALayer: 0x8e63960>>",
	    "<_UITableViewCellSeparatorView: 0x8e639a0; frame = (15 615.5; 305 0.5); autoresize = W; layer = <CALayer: 0x8e63a10>>",
	    "<_UITableViewCellSeparatorView: 0x8e63a50; frame = (15 659.5; 305 0.5); autoresize = W; layer = <CALayer: 0x8e63ac0>>",
	    "<_UITableViewCellSeparatorView: 0x8e63b00; frame = (15 703.5; 305 0.5); autoresize = W; layer = <CALayer: 0x8e63b70>>",
	    "<_UITableViewCellSeparatorView: 0x8e63bb0; frame = (15 747.5; 305 0.5); autoresize = W; layer = <CALayer: 0x8e63c20>>",
	    "<UIImageView: 0x8f34850; frame = (316.5 352; 3.5 64); alpha = 0; opaque = NO; autoresize = LM; userInteractionEnabled = NO; layer = <CALayer: 0x8f34740>> - (null)"
	)


DetailView上

	keyWindow : <UIWindow: 0x8d2abd0; frame = (0 0; 320 480); autoresize = W+H; gestureRecognizers = <NSArray: 0x8f142f0>; layer = <UIWindowLayer: 0x8d27970>>
	UIWindow -> view ----------------------------------------
	<UIWindow> subviews : (
	    "<UILayoutContainerView: 0x8d248b0; frame = (0 0; 320 480); autoresize = W+H; gestureRecognizers = <NSArray: 0x8c5d360>; layer = <CALayer: 0x8d24c10>>"
	)
	<UIWindow> top view: <UILayoutContainerView: 0x8d248b0; frame = (0 0; 320 480); autoresize = W+H; gestureRecognizers = <NSArray: 0x8c5d360>; layer = <CALayer: 0x8d24c10>>
	<UIWindow> topView->subviews: (
	    "<UINavigationTransitionView: 0x8c31260; frame = (0 0; 320 480); clipsToBounds = YES; autoresize = W+H; layer = <CALayer: 0x8c334c0>>",
	    "<UINavigationBar: 0x8d24940; frame = (0 20; 320 44); opaque = NO; autoresize = W; userInteractionEnabled = NO; gestureRecognizers = <NSArray: 0x8d294b0>; layer = <CALayer: 0x8d24a50>>"
	)
	UIWindow -> rootViewController -> view ----------------------
	<rootViewController> : <UINavigationController: 0x8e5a910>
	<rootViewController> rootView : <UILayoutContainerView: 0x8d248b0; frame = (0 0; 320 480); autoresize = W+H; gestureRecognizers = <NSArray: 0x8c5d360>; layer = <CALayer: 0x8d24c10>>
	<rootViewController> rootView->subviews : (
	    "<UINavigationTransitionView: 0x8c31260; frame = (0 0; 320 480); clipsToBounds = YES; autoresize = W+H; layer = <CALayer: 0x8c334c0>>",
	    "<UINavigationBar: 0x8d24940; frame = (0 20; 320 44); opaque = NO; autoresize = W; userInteractionEnabled = NO; gestureRecognizers = <NSArray: 0x8d294b0>; layer = <CALayer: 0x8d24a50>>"
	)
	UIWindow -> rootViewController -> currentViewController -> view ----------------------
	<currentViewController> : <DetailViewController: 0x8d39160>
	<currentViewController> view: <UIView: 0x8f236f0; frame = (0 0; 320 480); autoresize = RM+BM; layer = <CALayer: 0x8f20830>>
	<currentViewController> view->subviews: (
	    "<UILabel: 0x8f235e0; frame = (20 231.5; 280 17); text = '2014-06-11 10:29:07 +0000'; clipsToBounds = YES; autoresize = TM+BM; userInteractionEnabled = NO; layer = <CALayer: 0x8f46f20>>",
	    "<_UILayoutGuide: 0x8f20860; frame = (0 0; 0 64); hidden = YES; layer = <CALayer: 0x8f20950>>",
	    "<_UILayoutGuide: 0x8f47080; frame = (0 480; 0 0); hidden = YES; layer = <CALayer: 0x8f47170>>"
	)

このようにUINavigationControllerに出くわしたときなどはUIWindowからだと細かい値が取れない。

## 結論

上記より、UIViewController毎に細かくsubviewの取得を分けたい場合は、rootViewController経由で取得した方が良い