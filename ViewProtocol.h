/*
 *  ViewProtocol.h
 *  Sudoku Basic
 *
 *  Created by David Figge on 11/30/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */
enum { GAMEBOARD, CTRLPAD };

@protocol ViewProtocol
-(void)setBoard:(int)boardType toLocation:(int)HIDDENorSHOWN;		// Move board (no animation) to new position
-(void)moveBoard:(int)boardType toLocation:(int)HIDDENorSHOWN withTime:(float)sec;	// Animate board to new position
-(void)setPausedCaption:(char*)caption;								// Update the caption on the Paused button
-(void)selectPaused:(int)state;										// Specify the PAUSED state
-(void)updateTimer:(char*)string;									// Update the timer string
-(void)invalidateBoardRect:(CGRect)rect;							// Redraw section of the board
-(void)setCtlPadCmdSelected:(int)cellNbr toVal:(int)selected;		// Change SELECTED status on ctl pad cell
-(void)redrawAutoButton;											// Force a redraw of the auto button
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
-(void)showHelp;							// Show the help screen
-(void)setSoundSelected:(BOOL)state;
-(void)setSettingsSelected:(int)state;		// Set the settings (help) button to ON or OFF
@end