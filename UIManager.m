//
//  UIManager.m
//  Sudoku Basic
//
//  Created by David Figge on 11/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UIManager.h"

const float BoardMoveTime = 3.0;
const float PadMoveTime = 2.0;

@implementation UIManager
@synthesize viewController, isWaiting;

// Initialize the UI Manager object with a ViewProtocol-based delegate that handles the actual screen
// This is called by the View Controller
-(id)initWithViewController:(id<ViewProtocol>)del {
	self = [super init];
	if (self != nil) {
		viewController = del;
		isWaiting = NO;
	}
	return self;
}

// Turn off the waiting flag (if on)
-(void)cancelWait {
	isWaiting = NO;
}

// Show the help screen
-(void)showHelp {
	[viewController showHelp];
}

-(void)setSoundSelected:(BOOL)state {
	[viewController setSoundSelected:state];
}

// Put the board to either the HIDDEN or SHOWN position
-(void)setBoardPos:(int)HIDDENorSHOWN {		// Set board to shown/hidden location (no animation)
	[viewController setBoard:GAMEBOARD toLocation:HIDDENorSHOWN];
}


// Put the pad to either the HIDDEN or SHOWN position
-(void)setPadPos:(int)HIDDENorSHOWN {	// Set pad to shown/hidden position (no animation)
	[viewController setBoard:CTRLPAD toLocation:HIDDENorSHOWN];
}

// Hide control pad, moving it from its current location to HIDDEN
-(void)hidePad {								// move pad to hidden position
	[viewController moveBoard:CTRLPAD toLocation:HIDDEN withTime:PadMoveTime];
}

// Move the control from its current location to the SHOWN position on the screen
-(void)showPad {								// Move pad to shown position
	[viewController moveBoard:CTRLPAD toLocation:SHOWN withTime:PadMoveTime];
}

// Move the board from its current position to the SHOWN position on the screen
-(void)showBoard {							// Move board to shown position
	[viewController moveBoard:GAMEBOARD toLocation:SHOWN withTime:BoardMoveTime];
	[self wait:BoardMoveTime];
}

// Move the board from its current position to the SHOWN position on the screen
-(void)hideBoard {							// Move board to hidden position
	[viewController moveBoard:GAMEBOARD toLocation:HIDDEN withTime:BoardMoveTime];
	[self wait:BoardMoveTime];
}

// Set the isWaiting flag for a specific number of seconds
-(void)wait:(double)secs {
	isWaiting = YES;
	[NSTimer scheduledTimerWithTimeInterval:secs target:self selector:@selector(waitDone:) userInfo:nil repeats:NO];
}

// When the 'wait' timer is done, it comes here.
// Reset the isWaiting flag to off
-(void)waitDone:(NSTimer*)theTimer {
	isWaiting = NO;
}

// Set the caption on the pause button
-(void)setPausedCaption:(char*)caption {
	[viewController setPausedCaption:caption];
}

// Set the caption on the AUTO button
-(void)setAutoCaption:(char*)caption {		// Set the caption of the AUTO button
	[viewController setAutoCaption:caption];
}

// Set the 'selected' state of the pause button (SELECTED, NOTSELECTED)
-(void)selectPaused:(int)style {
	[viewController selectPaused:style];
}

// Set the 'selected' state of the new button (SELECTED, NOTSELECTED)
-(void)setNewSelected:(int)state {
	[viewController setNewSelected:state];
}

// Set the caption for the TIMER control
-(void)updateTimer:(char*)string {
	[viewController updateTimer:string];
}

// Force a specific cell to redraw
-(void)redrawCell:(Cell*)cell {
	[viewController invalidateBoardRect:cell.frame];
}

// Redraw the entire board
-(void)redrawBoard {					// Redraw the entire board
	[viewController redrawBoard];
}

// Redraw the entire control pad
-(void)redrawPad {
	[viewController redrawPad];
}

-(void)showBusy	{					// Show busy indicator if (sec) seconds goes by before cancel
	[viewController showBusy];
}

-(void)cancelBusy {							// Turn off busy indicator
	[viewController cancelBusy];
}
// Sync up the control pad to reflect the settings in the specified cell
-(void)syncCtlPadWithCell:(Cell*)cell {		// Sync the settings on the control pad to reflect the passed cell
	for (int x = 1; x < 10; x++) {
		if (cell == nil) {
			[viewController setCtlPadCmdSelected:x-1 toVal:NOTSELECTED];
			[viewController setCtlPadCmdSelected:x+8 toVal:NOTSELECTED];
		}
		else {
			[viewController setCtlPadCmdSelected:x-1 toVal:(cell.value == x ? SELECTED : NOTSELECTED)];
			[viewController setCtlPadCmdSelected:x+8 toVal:([cell pencilMark:x] == MARK_OFF ? NOTSELECTED : ISSELECTED)];
			if ([cell userPencilMark:x] == PENCIL_OFF) [viewController setCtlPadCmdSelected:x+8 toVal:DESELECTED];
		}
	}
}

// Display a message box in the middle of the screen with a message
-(void)displayMessageBox:(NSString*)title withMessage:(NSString*)message withYesNo:(BOOL)YesNo { // Display message box to user
	[viewController displayMessageBox:title withMessage:message withYesNo:YesNo];
}

// Display the NEW menu
-(void)showNewMenu {
	[viewController showNewMenu];
}

// Force the Auto button to redraw
-(void)redrawAutoButton {
	[viewController redrawAutoButton];
}

// Force the Filter ('SOLO') button to redraw
-(void)redrawFilterButton {
	[viewController redrawFilterButton];
}

// Do what's needed to make the board redraw even if it's off the screen
-(void)resetBoard {							// Do what's needed to make the board redraw even if off the screen
	[viewController resetBoard];
}

-(void)setFilterLight:(int)val {				// Turn on the filter light for a specific number
	[viewController setFilterLight:val];		// Now turn on the current value
}
	
-(void)setSettingsSelected:(int)state {			// Set the settings (help) button to ON or OFF
	[viewController setSettingsSelected:state];
}

- (void)dealloc {
    [super dealloc];
}

@end
