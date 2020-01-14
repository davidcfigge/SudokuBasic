//
//  AppDelegate_iPad.m
//  Sudoku Basic
//
//  Created by David Figge on 11/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate_iPad.h"
#import "iPadViewController.h"

@implementation AppDelegate_iPad


#pragma mark -
#pragma mark Application lifecycle

// Control comes here as application is ready to run on the iPad.
// It's already been deterimined that we're on an ipad
// So here we do major global settings and initialize the iPad view controller, adding it to the main window
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
    
	// Turn off status bar
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];

	viewController = [[iPadViewController alloc] initWithMainWindow:self.window];
	
	[self.window addSubview:viewController.view];
	
    [self.window makeKeyAndVisible];
    
    return YES;
}


// This function is called when the app is about to go into the background. You may not return.
// So here we want to save settings, etc (if not done already), maybe go into pause mode
- (void)applicationWillResignActive:(UIApplication *)application {
	[viewController sleep];
}

// App comes here when it's being reactivated (or activated for the first time)
// Good place to reset everything you paused when you went inactive
- (void)applicationDidBecomeActive:(UIApplication *)application {
	[viewController wake];
}


// Program is terminating. Superclass saves the apps managed object by default.
- (void)applicationWillTerminate:(UIApplication *)application {
	[super applicationWillTerminate:application];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
    [super applicationDidReceiveMemoryWarning:application];
}


- (void)dealloc {
	[viewController release];
	[super dealloc];
}


@end

