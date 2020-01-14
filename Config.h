//
//  Config.h
//  Sudoku Basic
//
//  Created by David Figge on 11/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {VERTICAL, HORIZONTAL };

enum {IPHONEDEVICE, IPADDEVICE };

enum {BOARDSHOWN, BOARDHIDDEN, PADSHOWN, PADHIDDEN };

enum { SHOWN, HIDDEN };

enum { PADBTNFILTER, PADBTNAUTO, PADBTNSETTINGS, PADBTNNEW, PADBTNPAUSE, PADRECTTIMER, PADSOUNDICON, PADBTNCOUNT };

enum { IDPADBTNFILTER = 19, IDPADBTNAUTO, IDPADBTNSETTINGS, IDPADBTNNEW, IDPADBTNPAUSE, IDPADRECTTIMER, IDPADSOUNDICON };

#define NUMBERSPERROW 9
#define CELLSPERROW 9
#define ROWSPERCOLUMN 9

enum { PORTRAIT, UPSIDEDOWN, LANDSCAPELEFT, LANDSCAPERIGHT };

struct configInfo {
	// Data used to set up various orientation and configuration settings
	int device;
	CGRect boardShownPort, boardHiddenPort;
	CGRect boardShownUD, boardHiddenUD;
	CGRect boardShownLeft, boardHiddenLeft;
	CGRect boardShownRight, boardHiddenRight;
	CGRect padShownPort, padHiddenPort;
	CGRect padShownUD, padHiddenUD;
	CGRect padShownLeft, padHiddenLeft;
	CGRect padShownRight, padHiddenRight;
	CGSize cellSize;
	CGPoint pencilOffset[9];
	CGPoint valueOffset;
	CGPoint boardBorder;
	int gridLineWidth;
	CGPoint padBorder;
	int padGridLineWidth;
	CGSize padGridBtnSize;
};

@interface Config : NSObject {
	
	int device;						// IPHONEDEVICE or IPADDEVICE
	int orientation;				// PORTRAIT, UPSIDEDOWN, LANDSCAPELEFT, LANDSCAPERIGHT
	CGRect screenSize;				// Size of screen
	CGRect board[2][4];				// coords of board, shown and hidden for each orientation
	CGRect pad[2][4];				// coords of pad, shown and hidden for each orientation
	CGSize cellSize;				// Size of cell (height and width)
	CGPoint* pencilOffsets;			// offset for pencil marks (x, y) from origin of cell, one per row
	CGPoint valueOffset;			// Offset to use to display value for cell
	CGPoint boardBorder;			// Margins between board and grid (x = left, y = top)
	int gridLineWidth;				// width of lines in board grid
	
	// Control pad elements
	CGPoint padBorder;				// Margins between board and buttons (x = left, y = top)
	int padGridLineWidth;			// width of lines in pad button grid
	CGSize padGridBtnSize;			// Size of buttons (numbers, pencils) on pad
	CGRect padButtons[PADBTNCOUNT];	// Coords and size of buttons on the pad
	char* padBtnText[PADBTNCOUNT];	// Text for buttons on pad
	
}

@property ( nonatomic, assign) int device;
@property ( readonly) int orientation;
@property ( nonatomic, assign) CGRect screenSize;
@property ( nonatomic, assign) CGSize cellSize;
@property ( nonatomic, assign) CGPoint valueOffset;
@property ( readonly)		   CGPoint* pencilOffsets;
@property ( nonatomic, assign) CGPoint boardBorder;
@property ( nonatomic, assign) int gridLineWidth;
@property ( nonatomic, assign) CGPoint padBorder;
@property ( nonatomic, assign) int padGridLineWidth;
@property ( nonatomic, assign) CGSize padGridBtnSize;

+(Config*)config;										// Return the 1 config instance
+(CGPoint*)getPencilOffsets;							// Return a pointer to the pencil offsets
-(void)initPencilOffsets;								// Initialize the pencil offsets
-(CGRect)getLocation:(int)boardAndLocation;				// Return the position of a board/pad hidden/shown based on current orientation
-(float)PencilXPos:(int)number;							// Get a pencil mark's x coord
-(float)PencilYPos:(int)number;							// Get a pencil mark's y coord
-(void)setPencilPos:(int)number position:(CGPoint)pos;	// Set a pencil mark's position
-(void)setPadButtonRect:(int)btn frame:(CGRect)rect;	// Set coordinates for a control pad button
-(CGRect)getPadButtonRect:(int)btn;						// Get the coordinates for a control pad button
-(void)setPadBtnText:(int)btn text:(char*)label;		// Set the text for a control pad button
-(char*)getPadBtnText:(int)btn;							// Get the text for a control pad button
-(int)convertOrientation:(int)UIInterfaceOrientationVal;	// Convert apple's UIInterfaceOrientation to one used by this system
-(void)setOrientation:(int)UIInterfaceOrientationVal;	// Set the current orientation based on apple's UIInterfaceOrientation value
-(void)setConfiguration:(struct configInfo *)data;		// Initialize configuration data based on structure contents
-(CGRect)screenRect;									// Return the screen coordinates
@end

