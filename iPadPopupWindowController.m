    //
//  iPadPopupWindowController.m
//  Sudoku Basic
//
//  Created by David Figge on 12/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
// The popup window is used to display alerts or ask input from the user

#import "iPadPopupWindowController.h"

@implementation iPadPopupWindowController

// Used to initialize the window.
// The title appears at the top of the (alert) window
// The Frame is the area of the screen that should be grayed out, typically the entire screen (pay attention to orientation)
// The Popup Controller Delegate is used to send either selected or cancelled messages to. Must implement the PopupController protocol.
// The ID is a user-definable value that can be used to uniquely identify each type of window displayed (menus, alerts, etc)
-(id)initWithTitle:(NSString*)title withFrame:(CGRect)frm withPCDelegate:(id<PopupController>)del withID:(int)Id {
	self = [super initWithNibName:nil bundle:nil];
	if (!self) return self;
	theView = [[DCFPopupView alloc] initWithTitle:title withBaseImage:@"BoardBase.png" withFrame:frm withDelegate:self withID:Id];	// Create the window
	popupDelegate = del;							// Remember the delegate
	self.view = theView;							// Initialize the View member variable
	return self;
}

-(void)reCenterWindow:(CGRect)frame {				// Used to redisplay popup if orientation changes while displayed
	[theView reCenter:frame];
}

// Used to add a label to the view
// Returns the UILabel object for further customization (text style and size, background colors, etc.)
-(UILabel*)addLabelwithFrame:(CGRect)bounds withText:(NSString*)text {
	return [theView addLabelWithFrame:bounds withText:text];		// Pass this request on to the DCFPopupView object
}

// Displays the popup window
-(void)display:(UIView*)view fromController:(UIViewController*)controller {
	inView = view;
	
	self.view.alpha = 0;							// We're going to animate. Start with no visibility
	[view addSubview:self.view];
	[UIView beginAnimations:@"fadeIn" context:nil];	// Start fade in animation
	[UIView setAnimationDuration:.5];
	self.view.alpha = 1;							// Go to full visibility
	[UIView commitAnimations];
}

// Called when user selects a label from the window
-(void)DCFPopupDidSelect:(DCFPopupView*)popup item:(int)itemnum withID:(int)msgID {
	[self.view removeFromSuperview];				// Make the window disappear
	[popupDelegate PopupController:self didSelectItem:itemnum withID:msgID];	// Return selected item number to delegate
}

// Called when user cancels the selection (typically by clicking outside the box
-(void)DCFPopupCancelled:(DCFPopupView*)popup withID:(int)msgID {
	[self.view removeFromSuperview];				// Make the window disappear
	[popupDelegate PopupControllerSelectionCanceled:self withID:msgID];			// Pass cancelled message on to delegate
}

// Returns YES because this window does rotate as orientation changes
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[theView release];
    [super dealloc];
}


@end
