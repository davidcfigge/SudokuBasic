//
//  iPadViewController.h
//  Sudoku Basic
//
//  Created by David Figge on 11/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewProtocol.h"
#import "Config.h"
#import "GameManager.h"
#import "CmdButton.h"
#import "iPadPopupWindowController.h"
#import "PopupController.h"
#import "iPadHelpViewController.h"

#import "DCFImageView.h"


enum { MSGBOXID, NEWMENUID };				// IDs for Message Box / New Menu display (iPadPopupWindowController)
@interface iPadViewController : UIViewController <ViewProtocol,DCFImgViewProtocol,PopupController,iPadHelpProtocol> {
	UIImageView* backgroundView;	// Background image view
	DCFImageView* leftRailView;		// Left rail view
	DCFImageView* rightRailView;	// Right rail view
	DCFImageView* board;			// Board view
	DCFImageView* controlPad;		// Control pad view
	iPadPopupWindowController* ippwc;	// iPadPopupControllerWindow (nil if not active)
	UIWindow* mainWindow;			// Main window (passed in from app delegate
	UIActivityIndicatorView* busyView;	// Activity Indicator when building a puzzle takes longer than .5 seconds
	bool busyActive;				// Set if busy indicator is active (may or may not be shown yet)
	Config* config;					// (global) config object
	Settings* settings;				// (global) settings object
	GameManager* gameManager;		// Game Manager
	NSMutableArray* ctlPadCells;	// Cells that are on the control pad (one for each number, one for each pencil mark)
	NSMutableArray* ctlPadTouchPoints;	// Areas you can tap on the control pad
	CmdButton* pauseButton;			// Pause button info
	CmdButton* settingsButton;		// Settings button info
	CmdButton* newButton;			// New button info
	CmdButton* timeButton;			// Timer label info
	CmdButton* autoButton;			// Auto button info
	CmdButton* filterButton;		// Filter button info ('SOLO')
	CmdButton* soundButton;			// Sound button (icon)
	bool isAnimatingBoard;			// Board being moved
	bool isAnimatingPad;			// Pad being moved
}

@property (nonatomic, retain) UIImageView* backgroundView;
@property (nonatomic, retain) DCFImageView* leftRailView;
@property (nonatomic, retain) DCFImageView* rightRailView;
@property (nonatomic, retain) DCFImageView* board;
@property (nonatomic, retain) DCFImageView* controlPad;
@property (nonatomic, retain) UIActivityIndicatorView* busyView;
@property (nonatomic, retain) Settings* settings;
@property (nonatomic, retain) Config* config;
@property (nonatomic, retain) GameManager* gameManager;
//@property (nonatomic, retain) DCFImageView* newMenu;

-(id)initWithMainWindow:(UIWindow*)window;
-(void)setConfig;
-(void)setSettings;
-(CGRect)getLocation:(int)boardtType withShown:(int)HiddenOrShown;
-(void)sleep;								// Called by app delegate when going into background
-(void)wake;								// Called by app delegate when waking

// ViewProtocol functions
-(void)setBoard:(int)boardType toLocation:(int)HIDDENorSHOWN;
-(void)moveBoard:(int)boardType toLocation:(int)HIDDENorSHOWN withTime:(float)sec;
-(void)draw:(int)ID withContext:(CGContextRef)context;
-(void)themeSetUp;
-(void)setUpCtlPad;
-(void)setPausedCaption:(char*)caption;		// Set the caption on the paused button
-(void)selectPaused:(int)style;				// Indicate if the Paused button is on or off (ISSELECTED, NOTSELECTED)
-(void)updateTimer:(char*)string;
-(void)invalidateBoardRect:(CGRect)rect;
-(void)setCtlPadCmdSelected:(int)cellNbr toVal:(int)selected;
-(void)redrawAutoButton;
-(void)setAutoCaption:(char*)caption;		// Set the caption of the AUTO button
-(void)redrawAutoButton;					// Redraw the entire board
-(void)redrawBoard;
-(void)redrawPad;
-(void)redrawFilterButton;					// Redraw the filter button
-(void)resetBoard;							// Do what's needed to make the board redraw even if off the screen
-(void)showNewMenu;							// Display the NEW menu and return selection (0-5)
-(void)displayMessageBox:(NSString*)title withMessage:(NSString*)message; // Display message box to user
-(void)displayMessageBox:(NSString *)title withMessage:(NSString *)message withYesNo:(BOOL)YesNo;
-(void)setNewSelected:(int)state;			// Turn on/off the NEW highlight
-(void)setPadForOrientation;				// Set up control pad values for current orientation
-(void)doneAnimatingBoard:(NSTimer*)timer;	// Called by timer to reset board animating flag
-(void)doneAnimatingPad:(NSTimer*)timer;	// Called by timer to reset pad animating flag
-(void)showBusy;							// Show busy inidicator
-(void)cancelBusy;							// Cancel the busy indicator
-(void)centerBusyView;						// Center the busy indicator in the board's SHOWN rectangle
-(void)setFilterLight:(int)val;				// Turn on the filter light for a specific number
-(void)showHelp;							// Show the help screen
-(void)helpClosed;							// Called when help closes
-(void)setSoundSelected:(BOOL)state;		// Set the selected status of the Sound icon
-(void)setSettingsSelected:(int)state;		// Set the settings (help) button to ON or OFF
	
@end
