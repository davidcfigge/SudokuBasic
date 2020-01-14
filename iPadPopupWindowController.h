//
//  iPadPopupWindowController.h
//  Sudoku Basic
//
//  Created by David Figge on 12/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopupController.h"
#import "DCFPopupView.h"

// The Popup Window displays a box in the middle of the screen alerting the user to something or asking something

@interface iPadPopupWindowController : UIViewController <UIActionSheetDelegate, UIPopoverControllerDelegate, DCFPopupViewDelegate>{
	id <PopupController> popupDelegate;
	UIPopoverController *popover;
	DCFPopupView* theView;
	UIView* inView;
	CGRect popoverBounds;
}

// The normal way to create this window. The Frame refers to the part of the screen that should be grayed out. Does not display the window
-(id)initWithTitle:(NSString*)title withFrame:(CGRect)frm withPCDelegate:(id<PopupController>)del withID:(int)Id;
-(void)display:(UIView*)view fromController:(UIViewController*)controller;				// Display the window
-(void)	DCFPopupDidSelect:(DCFPopupView*)popup item:(int)itemnum withID:(int)msgID;		// Called by the DCFView when users clicked. Passed on to delegate
-(void) DCFPopupCancelled:(DCFPopupView*)popup withID:(int)msgID;						// Called by the DCFView when users cancelled. Passed on to delegate
-(UILabel*)addLabelwithFrame:(CGRect)bounds withText:(NSString*)text;					// Adds a label onto the window. Returns the label object for customization
-(void)reCenterWindow:(CGRect)frame;													// Used to redisplay popup if orientation changes while displayed
@end
