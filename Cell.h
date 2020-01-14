//
//  Cell.h
//  Sudoku Basic
//
//  Created by David Figge on 11/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
// This class embodies an individual cell on the Sudoku board. As such, the cell has several purposes
//		To hold a given value (cell value given at start of game
//		To hold a guessed value
//		To hold pencil marks
//		Or, simply blank -- a square you have yet to finish
//	There are 81 of these squares in a standard game. These 81 squares are created/owned by GameManager.
//
#import <Foundation/Foundation.h>
#import "Config.h"
#import "Settings.h"
#import <UIKit/UIKit.h>
#import <UIKit/UIStringDrawing.h>
#import "Touchable.h"

enum _cellmodes_ { 
	CELLREADONLY, // A given value, can't be edited
	CELLREADWRITE, // Available to be changed
	CELLCMD,		// Used for display in control pad
};

enum _pencil_marks_ {
	MARK_OFF = 0,		// Do not display this pencil mark
	MARK_ON = 1,		// Display this pencil mark normally
	MARK_HINT = -1,		// Display this pencil mark as a hint (if hints turned on)
	MARK_HINT_HARD = -2,// Display as 'hard' hint (naked values)
};

enum _select_state_ {
	DESELECTED = -1,	// Specifically turned off (e.g. pencil marks)
	UNSELECTED = 0,		// Cell is not selected
	SELECTED = 1,		// User selected this cell
	LEFTSELECTED = 2,	// User just left this cell and selected another (needed for double-taps)
};

enum { PENCIL_OFF = -1, PENCIL_NONE = 0 };		// values for user pencil mark preferences (auto mode only)

@interface Cell : NSObject <Touchable> {
	int cellMode;				// CELLREADONLY (number given) or CELLREADWRITE (user must choose number)
	int value;					// Value for cell (provided, or what the user chose)
	int pencilMarks[NUMBERSPERROW+1];			// Pencil marks on or off: must be value in _pencil_marks_ enum
	int userPencil[NUMBERSPERROW+1];	// User pencil mark preferences (non-zero implies apply to pencil marks)
	int selected;				// selected state. Must be one of _select_state_
	int correctValue;			// The value that is correct for this cell
	CGRect frame;			    // The location and size of this square
	int squareNum;				// The number of this square (0-80)
	bool shadingOn;				// Set if cell should be shaded (only if settings:filter is on
	Config* config;				// Pointer to config object
	Settings* settings;			// Pointer to settings object
	bool filterLight;			// set if turn filter light on
}

@property ( nonatomic, assign ) int cellMode;
@property ( nonatomic, assign ) int value;
@property ( nonatomic, assign ) int selected;
@property ( nonatomic, assign ) int correctValue;
@property ( nonatomic, assign ) CGRect frame;
@property ( nonatomic, assign ) int squareNum;
@property ( nonatomic, assign ) bool shadingOn;
@property ( nonatomic, assign ) bool filterLight;

-(int)pencilMark:(int)number;
-(void)setPencilMark:(int)number toValue:(int)val;
-(int)userPencilMark:(int)number;
-(void)setUserPencilMark:(int)number toValue:(int)val;
-(id)initWithFrame:(CGRect)fr square:(int)sqnum;
-(void)draw:(CGContextRef)context;
-(int)wasHit:(CGPoint)pt;
-(void)resetVals;									// Reset to 'start of game' ready
-(int*)getPencilArray;
-(int*)getUserPencils;
-(int)getSuggestion;
+(void)borders:(bool)TRUEorFALSE;
-(void)drawBorder:(CGContextRef)context;
@end
