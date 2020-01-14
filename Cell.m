//
//  Cell.m
//  Sudoku Basic
//
//  Created by David Figge on 11/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
// This 'virtual screen object' defines the contents of a cell

#import "Cell.h"


@implementation Cell

@synthesize cellMode, value, selected, correctValue, frame, squareNum, shadingOn, filterLight;

// Static methods

static bool drawBorders = false;		// If you want to see the boarders of all the cells, call borders to turn it on

// Display borders of the cells. A debugging tool, not for users
+(void)borders:(bool)val {
	drawBorders = val;
}

// An array of number strings used to display the numbers
static char* nbr[] = { "", "1","2","3","4","5","6","7","8","9" };

// The initialization function
// Pass in the frame (coords relative to start of view) and square number (for your own use)
-(id)initWithFrame:(CGRect)fr square:(int)sqnum {
	self = [super init];
	if (self != nil) {
		config = [Config config];			// Locate the config object
		[config retain];
		settings = [Settings settings];		// And the settings object
		[settings retain];
		frame = fr;							// save the boundaries
		squareNum = sqnum;					// And the square number
		shadingOn = false;					// Turn shading off
		[self resetVals];					// Initialize values
	}
	return self;
}

// Reset all values to default settings for cell
-(void)resetVals {
	cellMode = CELLREADONLY;		// Selectable
	value = correctValue = 0;		// No legitimate value yet
	for (int x = 0; x < 10; x++)
		pencilMarks[x] = userPencil[x] = MARK_OFF;
}

// Check and see if the passed in point is within the cell's boundaries.
// If so, return the cell's number
// If not, return NOHIT
-(int)wasHit:(CGPoint)pt {
	if (CGRectContainsPoint(frame, pt))
		return squareNum;
	return NOHIT;
}

// Return a pointer to the cell's pencil array
-(int*)getPencilArray {
	return pencilMarks;
}

// Return a pointer to the cell's user-pencils array (where users may force on/off values)
-(int*)getUserPencils {
	return userPencil;
}

// Return a suggested value based on the pencil markings
-(int)getSuggestion {
	int cnt = 0;					// Count of pencil marks
	int theOne = 0;					// If only one pencil mark, this holds it
	int marked = 0;					// A pencil mark suggested by hints
	for (int x = 1; x < 10; x++) {
		if (pencilMarks[x] != MARK_OFF) {
			cnt++;					// One more pencil mark found
			theOne = x;				// Remember this if there's only one
			if (pencilMarks[x] == MARK_HINT) marked = x;	// If hint says choose this, save the value
		}
	}
	if (cnt == 1) return theOne;	// If there was only one pencil mark on, use it. This is the only suggestion option if pencil marks are not hints
	if ([settings pencilMode] < PENCIL_HINTS) return 0;		// If hints aren't on, can't help you
	return marked;					// Suggest this one if hints are on
}

// Return a specific pencil mark value
-(int)pencilMark:(int)number {
	return pencilMarks[number];
}

// Set the pencil mark to a specific value
-(void)setPencilMark:(int)number toValue:(int)val {
	pencilMarks[number] = val;
}

// return a userPencilMark value
-(int)userPencilMark:(int)number {
	return userPencil[number];
}

// Set a userPencilMark to as specific value
-(void)setUserPencilMark:(int)number toValue:(int)val {
	userPencil[number] = val;
}

// Draw up a number at the specified coordinates
-(void)drawNumber:(CGContextRef)context number:(int)num atX:(int)xcoord atY:(int)ycoord {
	if (!num) return;			// If number is 0, ignore
	CGContextShowTextAtPoint(context, frame.origin.x+xcoord, frame.origin.y+ycoord, nbr[num], 1);	// Draw up text
}

// Draw up the contents of the cell
-(void)draw:(CGContextRef)context {
	if (drawBorders) {										// If we're drawing borders
		CGContextSetRGBStrokeColor(context, 1, 0, 0, 1);		// Set the color to red
		CGContextStrokeRect(context, frame);					// And draw a border around the cell
	}
	if (cellMode == CELLCMD) {								// if this is on the control pad
		[self drawBorder:context];						// Draw 'in/out' borders
		if (value > 0) {										// If we have a value to draw
			if (selected != SELECTED) [settings setContext:context forFontItem:FONTCTLPADVALUE];	// Get font settings for this button, either unselected
			else [settings setContext:context forFontItem:FONTCTLPADVALUESEL];						// or selected
			int xpos = config.valueOffset.x;
			int ypos = config.valueOffset.y;
			if (selected) {
				xpos += 1;
				ypos +=1;
			}
			if (filterLight == true && settings.filterMode == true) [settings setContext:context forFontItem:FONTCMDFILTERLIGHT];
			[self drawNumber:context number:value atX:xpos atY:ypos];	// Draw up the value
		}
		else {												// If pencil marks
			if (selected != SELECTED)
				[settings setContext:context forFontItem:FONTCTLPADPENCIL];		// If not selected, get font settings for 'normal'
			else
				[settings setContext:context forFontItem:FONTCTLPADPENCILSEL];	// Otherwise start with selected font settings
			if (selected == DESELECTED && [settings pencilMode] >= PENCIL_AUTO)		// If it's been deselected and the pencil mode indicates
				[settings setContext:context forFontItem:FONTCTLPADPENCILEXCL];			// Draw up using the 'excluded' font settings
			for(int x = 0; x < NUMBERSPERROW+1; x++) {							// Draw up the pencil marks (should only be one)
				if (pencilMarks[x] != MARK_OFF) {
					int xpos = [config PencilXPos:x];
					int ypos = [config PencilYPos:x];
					if (selected) {
						xpos +=1;
						ypos +=1;
					}
					[self drawNumber:context number:x atX:xpos atY:ypos];
				}
			}
		}
		return;
	}
	
	// If you make it here, we've got a cell on the board to draw
	// First see if we should draw up shading on this cell
	if (settings.filterMode && shadingOn) {				// Filter (SOLO) is on, and this cell should be shaded
		[settings setContext:context forFontItem:FONTCELLFILTERSHADING];	 // get shading settings
		CGContextFillRect(context, frame);									 // and draw up a shaded cell
	}
	// Next we draw a value if there is one
	if (value > 0) {
		[settings setContextForValue:context isDefValue:(cellMode == CELLREADONLY)];	// Get font settings
		if ([settings pencilMode] >= PENCIL_AUTO && value != correctValue)					// If pencil mode is on and this is an incorrect value
			[settings setContext:context forFontItem:FONTERRVALUE];								// Draw up differently
		[self drawNumber:context number:value atX:config.valueOffset.x atY:config.valueOffset.y];	// Draw up the number
	}
	else {	// If you're here, you have no value yet, so we draw pencil marks
		for (int x = 1; x <= NUMBERSPERROW; x++) {		// For each pencil mark
			if (pencilMarks[x] != MARK_OFF) {				// If there is a mark
				// Draw up the pencil mark
				[settings setContextForPencil:context withHighlight:(pencilMarks[x] == MARK_HINT || pencilMarks[x] == MARK_HINT_HARD)];	// Set the text style
				[self drawNumber:context number:x atX:[config PencilXPos:x] atY:[config PencilYPos:x]];		// Draw up the pencil mark
			}
		}
	}
	// Finally, if the cell is selected, draw a border around it
	switch(selected) {
		case SELECTED:
			[settings setContext:context forFontItem:FONTCELLSELECTED];		// Use selected color settings
		case LEFTSELECTED:
			if (selected == LEFTSELECTED) [settings setContext:context forFontItem:FONTCELLLEFTSELECTED];	// If last selected, use last selected color settings
			CGContextSetLineWidth(context, 2);								// 2 pixels wide
			CGRect frRect = CGRectMake(frame.origin.x+1,frame.origin.y+1, frame.size.width-2, frame.size.height-2);	// Draw just inside cell so erasing works easily
			CGContextStrokeRect(context, frRect);							// Draw up the border
	}
}

-(void)drawBorder:(CGContextRef)context {
	CGRect boundaries = frame;
	CGContextSaveGState(context);
	if (!selected)
		[settings setContext:context forFontItem:FONTCMDBTNBORDERDARK];		// Black for right and bottom
	else
		[settings setContext:context forFontItem:FONTCMDBTNBORDERLIGHT];		// White for right and bottom
	CGContextSetLineWidth(context, 2);
	CGPoint lineSegments[] =  {
		CGPointMake(boundaries.origin.x+boundaries.size.width-1,boundaries.origin.y+1),CGPointMake(boundaries.origin.x+boundaries.size.width-1,boundaries.origin.y+boundaries.size.height-1), // right
		CGPointMake(boundaries.origin.x+1,boundaries.origin.y+boundaries.size.height-1),CGPointMake(boundaries.origin.x+boundaries.size.width-1, boundaries.origin.y+boundaries.size.height-1), // Bottom
		CGPointMake(boundaries.origin.x+1,boundaries.origin.y+1),CGPointMake(boundaries.origin.x+boundaries.size.width-1, boundaries.origin.y+1),  // top
		CGPointMake(boundaries.origin.x+1,boundaries.origin.y+1),CGPointMake(boundaries.origin.x+1, boundaries.origin.y+boundaries.size.height-1),	// left side
	};
	CGContextStrokeLineSegments(context, lineSegments, 4);
	if (!selected)
		[settings setContext:context forFontItem:FONTCMDBTNBORDERLIGHT];		// White for left and top
	else 
		[settings setContext:context forFontItem:FONTCMDBTNBORDERDARK];		// black for left and top
	CGContextStrokeLineSegments(context, lineSegments+4, 4);
	CGContextRestoreGState(context);
}
-(void) dealloc {
	[config release];
	[settings release];
	[super dealloc];
}

@end
