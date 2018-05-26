+++
date = "2014-03-18T03:09:13+00:00"
draft = false
tags = ["Xcode", "LLDB", "debug"]
title = "LLDBデバッガを利用したXcode開発"
+++
Xcodeを使ってSDK開発ではprint debug（もといNSLog debug）では限界が速攻来る。読み切れないしつらい。

そのときはLLDB debuggerを利用する事で、効率的に開発やハックが実現できる。


## まず

対象箇所にブレークポイントを仕込みます。

コンソールが既存オブジェクトがbindingされた状態で触る事が出来ます。
	
	(lldb)

## コマンド群

ヘルプの表示

	(lldb) h
	The following is a list of built-in, permanent debugger commands:
	
	_regexp-attach    -- Attach to a process id if in decimal, otherwise treat the
	                     argument as a process name to attach to.
	_regexp-break     -- Set a breakpoint using a regular expression to specify the
	                     location, where <linenum> is in decimal and <address> is
	                     in hex.
	_regexp-bt        -- Show a backtrace.  An optional argument is accepted; if
	                     that argument is a number, it specifies the number of
	                     frames to display.  If that argument is 'all', full
	                     backtraces of all threads are displayed.
	_regexp-display   -- Add an expression evaluation stop-hook.
	_regexp-down      -- Go down "n" frames in the stack (1 frame by default).
	_regexp-env       -- Implements a shortcut to viewing and setting environment
	                     variables.
	_regexp-jump      -- Sets the program counter to a new address.
	_regexp-list      -- Implements the GDB 'list' command in all of its forms
	                     except FILE:FUNCTION and maps them to the appropriate
	                     'source list' commands.
	_regexp-tbreak    -- Set a one shot breakpoint using a regular expression to
	                     specify the location, where <linenum> is in decimal and
	                     <address> is in hex.
	_regexp-undisplay -- Remove an expression evaluation stop-hook.
	_regexp-up        -- Go up "n" frames in the stack (1 frame by default).
	apropos           -- Find a list of debugger commands related to a particular
	                     word/subject.
	breakpoint        -- A set of commands for operating on breakpoints. Also see
	                     _regexp-break.
	command           -- A set of commands for managing or customizing the debugger
	                     commands.
	disassemble       -- Disassemble bytes in the current function, or elsewhere in
	                     the executable program as specified by the user.
	expression        -- Evaluate a C/ObjC/C++ expression in the current program
	                     context, using user defined variables and variables
	                     currently in scope.
	frame             -- A set of commands for operating on the current thread's
	                     frames.
	gdb-remote        -- Connect to a remote GDB server.  If no hostname is
	                     provided, localhost is assumed.
	help              -- Show a list of all debugger commands, or give details
	                     about specific commands.
	kdp-remote        -- Connect to a remote KDP server.  udp port 41139 is the
	                     default port number.
	log               -- A set of commands for operating on logs.
	memory            -- A set of commands for operating on memory.
	platform          -- A set of commands to manage and create platforms.
	plugin            -- A set of commands for managing or customizing plugin
	                     commands.
	process           -- A set of commands for operating on a process.
	quit              -- Quit out of the LLDB debugger.
	register          -- A set of commands to access thread registers.
	script            -- Pass an expression to the script interpreter for
	                     evaluation and return the results. Drop into the
	                     interactive interpreter if no expression is given.
	settings          -- A set of commands for manipulating internal settable
	                     debugger variables.
	source            -- A set of commands for accessing source file information
	target            -- A set of commands for operating on debugger targets.
	thread            -- A set of commands for operating on one or more threads
	                     within a running process.
	type              -- A set of commands for operating on the type system
	version           -- Show version of LLDB debugger.
	watchpoint        -- A set of commands for operating on watchpoints.
	
	For more information on any particular command, try 'help <command-name>'.

オブジェクトの評価

	(lldb) po po self.view
	<UITableView: 0xbb12600; frame = (0 0; 320 568); clipsToBounds = YES; opaque = NO; autoresize = W+H; gestureRecognizers = <NSArray: 0x98527a0>; layer = <CALayer: 0x984b4b0>; contentOffset: {0, -64}>

型の評価

	(lldb) p self.view
	(UIView *) $17 = 0x0bb12600
	
step-in

	(lldb) s
	
continue

	(lldb) c

breakpoint list

	(lldb) br l	
	Current breakpoints:
	1: file = '/Users/hogehoge/dev/work/Foo.objc/MasterViewController.m', line = 119, locations = 1, resolved = 1, hit count = 1
	
	1.1: where = Foo`-[MasterViewController RecordSwitch:] + 138 at MasterViewController.m:120, address = 0x00002fea, resolved, hit count = 1 
  
  
back trace

	(lldb) bt
	  * thread #1: tid = 0x572549, 0x00002fea Foo`-[MasterViewController RecordSwitch:](self=0x0983e810, _cmd=0x000e9a03, sender=0x09a3f0d0) + 138 at MasterViewController.m:120, queue = 'com.apple.main-thread', stop reason = breakpoint 1.1
	  * frame #0: 0x00002fea Foo`-[MasterViewController RecordSwitch:](self=0x0983e810, _cmd=0x000e9a03, sender=0x09a3f0d0) + 138 at MasterViewController.m:120
	    frame #1: 0x01b7e82b libobjc.A.dylib`-[NSObject performSelector:withObject:] + 70
	    frame #2: 0x0071f3b9 UIKit`-[UIApplication sendAction:to:from:forEvent:] + 108
	    frame #3: 0x0071f345 UIKit`-[UIApplication sendAction:toTarget:fromSender:forEvent:] + 61
	    frame #4: 0x00820bd1 UIKit`-[UIControl sendAction:to:forEvent:] + 66
	    frame #5: 0x00820fc6 UIKit`-[UIControl _sendActionsForEvents:withEvent:] + 577
	    frame #6: 0x009b17a5 UIKit`__31-[UISwitch _handleLongPressNL:]_block_invoke + 85
	    frame #7: 0x009b0666 UIKit`-[_UISwitchInternalViewNeueStyle1 _setPressed:on:animated:shouldAnimateLabels:completion:] + 243
	    frame #8: 0x009b1681 UIKit`-[UISwitch _handleLongPressNL:] + 286
	    frame #9: 0x00ab94f4 UIKit`_UIGestureRecognizerSendActions + 230
	    frame #10: 0x00ab8168 UIKit`-[UIGestureRecognizer _updateGestureWithEvent:buttonEvent:] + 383
	    frame #11: 0x00ab9bdd UIKit`-[UIGestureRecognizer _delayedUpdateGesture] + 60
	    frame #12: 0x00abd13d UIKit`___UIGestureRecognizerUpdate_block_invoke + 57
	    frame #13: 0x00abd0be UIKit`_UIGestureRecognizerRemoveObjectsFromArrayAndApplyBlocks + 317
	    frame #14: 0x00ab37ac UIKit`_UIGestureRecognizerUpdate + 199
	    frame #15: 0x0075ea5a UIKit`-[UIWindow _sendGesturesForEvent:] + 1291
	    frame #16: 0x0075f971 UIKit`-[UIWindow sendEvent:] + 1021
	    frame #17: 0x0008c78f Foo`-[UIWindow(self=0x09a38750, _cmd=0x077e0d00, event=0x09a33400) rpr_sendEvent:] + 2863 at UIWindow+RPR.m:101
	    frame #18: 0x007315f2 UIKit`-[UIApplication sendEvent:] + 242
	    frame #19: 0x0071b353 UIKit`_UIApplicationHandleEventQueue + 11455
	    frame #20: 0x01d7677f CoreFoundation`__CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE0_PERFORM_FUNCTION__ + 15
	    frame #21: 0x01d7610b CoreFoundation`__CFRunLoopDoSources0 + 235
	    frame #22: 0x01d931ae CoreFoundation`__CFRunLoopRun + 910
	    frame #23: 0x01d929d3 CoreFoundation`CFRunLoopRunSpecific + 467
	    frame #24: 0x01d927eb CoreFoundation`CFRunLoopRunInMode + 123
	    frame #25: 0x03d255ee GraphicsServices`GSEventRunModal + 192
	    frame #26: 0x03d2542b GraphicsServices`GSEventRun + 104
	    frame #27: 0x0071df9b UIKit`UIApplicationMain + 1225






## 参考

[Xcode4.5でLLDBデバッガコマンドを使ってみる](http://d.hatena.ne.jp/tanaponchikidun/20120923/1348388081)

[アプリがクラッシュしちゃった。さて、どうしましょう- Part 1](http://www.raywenderlich.com/ja/50797/%E3%82%A2%E3%83%97%E3%83%AA%E3%81%8C%E3%82%AF%E3%83%A9%E3%83%83%E3%82%B7%E3%83%A5%E3%81%97%E3%81%A1%E3%82%83%E3%81%A3%E3%81%9F%E3%80%82%E3%81%95%E3%81%A6%E3%80%81%E3%81%A9%E3%81%86%E3%81%97%E3%81%BE)

