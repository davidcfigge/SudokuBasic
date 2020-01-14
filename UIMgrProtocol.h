/*
 *  UIMgrProtocol.h
 *  Sudoku Basic
 *
 *  Created by David Figge on 11/30/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */
#import "Cell.h"

@protocol UIMgrProtocol

-(void)setBoardPos:(int)HIDDENorSHOWN;		// Set board to shown/hidden location (no animation)
-(void)setPadPos:(int)HIDDENorSHOWN;	// Set pad to shown/hidden position (no animation)
-(void)hidePad;								// move pad to hidden position
-(void)showPad;								// Move pad to shown position
-(void)showBoard;							// Move board to shown position
-(void)hideBoard;							// Move board to hidden position
-(bool)isWaiting;							// Set if game is waiting for completion of event
-(void)setPausedCaption:(char*)caption;		// Set the paused button caption
-(void)selectPaused:(int)state;		// Set the paused button selected state
-(void)updateTimer:(char*)text;		// Update the timer string to a new value
-(void)redrawCell:(Cell*)cell;				// Redraw the (board) cell
-(void)syncCtlPadWithCell:(Cell*)cell;		// Sync control pad buttons to status of cell
-(void)redrawAutoButton;					// Force a redraw of the Auto button
-(void)setAutoCaption:(char*)caption;		// Set the caption of the AUTO button
-(void)redrawBoard;
-(void)redrawPad;
-(void)redrawFilterButton;					// Redraw the filter button
-(void)resetBoard;							// Do what's needed to make the board redraw even if off the screen
-(void)showNewMenu;							// Display the NEW menu and return selection (0-5)
-(void)displayMessageBox:(NSString*)title withMessage:(NSString*)message withYesNo:(BOOL)YesNo; // Display message box to user
-(void)setNewSelected:(int)state;			// Turn on/off the NEW highlight
-(void)showBusy;							// Show busy indicator
-(void)cancelBusy;							// Turn off busy indicator
-(void)setFilterLight:(int)val;				// Turn on the filter light for a specific number
-(void)cancelWait;							// Turn off the waiting flag (if on)
-(void)showHelp;							// Display the help screen
-(void)setSoundSelected:(BOOL)state;		// Set the Sound icon to ON or OFF
-(void)setSettingsSelected:(int)state;		// Set the settings (help) button to ON or OFF

@end