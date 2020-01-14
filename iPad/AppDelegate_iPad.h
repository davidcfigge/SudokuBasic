//
//  AppDelegate_iPad.h
//  Sudoku Basic
//
//  Created by David Figge on 11/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate_Shared.h"
#import "iPadViewController.h"

@interface AppDelegate_iPad : AppDelegate_Shared {
	iPadViewController* viewController;
	//UIViewController* viewController;				// Main view controller (might be iPad or iPhone)
}


@end

