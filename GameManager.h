//
//  GameManager.h
//  Sudoku Basic
//
//  Created by David Figge on 11/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
// The game manager is in charge of making the Sudoku board play the game

#import <Foundation/Foundation.h>
#import "UIMgrProtocol.h"
#import "ViewProtocol.h"
#import "Config.h"
#import "Cell.h"
#import "Settings.h"
#import "Game.h"
#import "SoundEffect.h"
#import "Datastore.h"


@interface GameManager : NSObject {
	id<UIMgrProtocol> uiManager;			// Requests to UI elements go here (which get sent to either iPad or iPhone controller from UIManager)
	Config* config;						// Configuration settings for the current environment
	bool isPaused;						// Set if game is paused
	Settings* settings;					// Various settings used within the program
	NSMutableArray* cells;				// The collection of squares (cells) on the board
	bool timerActive;					// Set if timer is running
	int hours, minutes, seconds;		// Elapsed time values
	char timerString[25];				// The elapsed time converted to string (at last screen update)
	Game* currentGame;					// The current board and solution that is being played
	int currentSelection;				// The current cell that's been selected
	int lastSelection;					// The cell that was selected before the current, or a default cell if tapped
	bool userTappedGiven;				// Set if user tapped on a GIVEN square
	int filterVal;						// The value that is being used to draw in the filter ('solo') mode
	int currentLevel;					// The current level of the game that is being played (0-4)
	BOOL gameOver;						// Set if the game is complete.
	bool isGenerating;					// Set if currently preparing to or are generating a new game
	SoundEffect* BtnPress;				// Button press sound
	SoundEffect* OtherBtn;				// Non number button presses sound
	SoundEffect* SoloChg;				// Sound effect for solo number changing
	SoundEffect* BoardMove;				// Board moving sound effect
	bool timerState;
	bool displayNewMenu;				// Set if display New when popup dismissed
	Datastore* datastore;				// Datastore object represents data stored on disk
}

@property (nonatomic, retain) id<UIMgrProtocol> uiManager;
@property (nonatomic, assign) bool isPaused;
@property (nonatomic, assign) bool timerActive;
@property (nonatomic, retain) Game* currentGame;
@property (nonatomic, assign) bool isGenerating;

-(id)initWithUIManager:(id<UIMgrProtocol>)uiMgr;
-(void)initialGameSetup;
-(void)configureForGame:(int)numCells;
-(void)createCells;
-(void)drawCellsContents:(CGContextRef)context;

-(void)tappedNew;							// User tapped on the NEW button
-(void)tappedSettings;						// User tapped on the SETTINGS button
-(void)tappedPause;							// User tapped on the PAUSE button
-(void)tappedPause:(BOOL)autosleep;			// Called if going to sleep and should not sound or move
-(void)tappedAuto;							// User tapped on the AUTO button
-(void)tappedFilter;						// User tapped on the FILTER button
-(void)tappedSound;							// User tapped sound icon
-(void)startTimer;							// Begin timer
-(void)incrementTimer:(NSTimer*)timer;		// Timer function (updates timer on CtlPad)
-(void)tappedCellAtPoint:(CGPoint)pt;		// Process single-taps on board
-(void)dblTappedCellAtPoint:(CGPoint)pt;	// Process double-taps on board
-(void)tappedCtlPadCell:(int)ID;			// Process single-taps on the control pad cells
-(void)dblTappedCtlPadCell:(int)ID;			// Process double-taps on the control pad cells
-(void)autoPencil;							// Update pencil marks in Auto mode
-(void)newGameOnScreenUp:(NSTimer*)timer;
-(void)setFilter:(int)val;					// Turn filter on and configure according to passed value
-(void)newGameSelected:(int)sel;			// Called when user confirms new game menu choice
-(void)msgBoxSelected:(int)item;			// Called when confirming end of game: New game?
-(void)newGameCanceled;						// Sent if new game menu was canceled
-(bool)checkWin;							// Check for win condition, if so display message. Returns true if game over
-(void)displayMessageBox:(NSString*)title withMessage:(NSString*)message withYesNo:(BOOL)YesNo; // Display a message box
-(void)popupDismissed;						// Send when popup (new menu, messagebox) dismissed
-(void)refreshCtlPad;						// Refresh control pad to display current cell status
-(void)wake;								// Wake up from background
-(void)sleep;								// About to go to sleep (save game...)
-(bool)loadPreviousGame;					// Load previous game from storage
-(void)SaveTimerState;
-(void)RestoreTimerState;
-(void)displayTimer;
@end
