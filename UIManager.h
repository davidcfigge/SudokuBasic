//
//  UIManager.h
//  Sudoku Basic
//
//  Created by David Figge on 11/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Config.h"
#import "UIMgrProtocol.h"
#import "ViewProtocol.h"


@interface UIManager : NSObject <UIMgrProtocol> {
	id<ViewProtocol> viewController;
	bool isWaiting;
	NSTimer* waitingTimer;
}

@property (nonatomic, assign) id<ViewProtocol> viewController;
@property (nonatomic, assign) bool isWaiting;

-(id)initWithViewController:(id<ViewProtocol>) delegate;
-(void)setBoardPos:(int)HIDDENorSHOWN;		// Set board to shown/hidden location (no animation)
-(void)setPadPos:(int)HIDDENorSHOWN;	// Set pad to shown/hidden position (no animation)
-(void)hidePad;								// move pad to hidden position
-(void)showPad;								// Move pad to shown position
-(void)showBoard;							// Move board to shown position
-(void)hideBoard;							// Move board to hidden position
-(void)wait:(double)secs;					// Wait (sleep) for specified time interval
-(void)setPausedCaption:(char*)caption;		// Set the caption on the paused button
-(void)selectPaused:(int)style;				// Indicate if the Paused button is on or off (ISSELECTED, NOTSELECTED)
-(void)updateTimer:(char*)string;			// Redraw timer with new value
-(void)redrawCell:(Cell*)cell;				// Redraw cell on board
-(void)syncCtlPadWithCell:(Cell*)cell;		// Sync the settings on the control pad to reflect the passed cell
-(void)setAutoCaption:(char*)caption;		// Set the caption of the AUTO button
-(void)redrawAutoButton;					// Redraw the entire board
-(void)redrawFilterButton;					// Redraw the filter button
-(void)redrawPad;							// Redraw the control pad
-(void)resetBoard;							// Do what's needed to make the board redraw even if off the screen
-(void)showNewMenu;					// Display the NEW menu and return selection (0-5)
-(void)displayMessageBox:(NSString*)title withMessage:(NSString*)message withYesNo:(BOOL)YesNo; // Display message box to user
-(void)setNewSelected:(int)state;			// Turn on/off the NEW highlight
-(void)showBusy;							// Show busy indicator
-(void)cancelBusy;							// Turn off busy indicator
-(void)setFilterLight:(int)val;				// Turn on the filter light for a specific number
-(void)cancelWait;							// Turn off the waiting flag
-(void)showHelp;							// Show the help screen
-(void)setSoundSelected:(BOOL)state;
-(void)setSettingsSelected:(int)state;		// Set the settings (help) button to ON or OFF
@end
