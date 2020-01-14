//
//  TouchPoint.h
//  Sudoku Basic
//
//  Created by David Figge on 12/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
// This class defines a rectangle on the screen that can be touched

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Settings.h"
#import "Touchable.h"
#import "Config.h"


enum { TEXTALIGNLEFT, TEXTALIGNCTR, TEXTALIGNRIGHT };

@interface CmdButton : NSObject <Touchable> {
	CGRect boundaries;			// Boundaries of touchable area
	int ID;						// ID for button
	char* text;					// Text to display for button
	bool textVertical;			// Set if text is displayed vertically
	bool touchable;				// Set if this 'button' is selectable (if not, just for display)
	Settings* settings;			// Reference to the settings object
	int alignment;				// Type of alignment for text
	int fontType;				// fontType used in setting fonts and colors (via settings)
	int selected;				// Set if selected (uses the font settings ONE AFTER the one specified above)
	UIImage* imagesel;			// Image to use when selected (overrides text)
	UIImage* imageunsel;		// Image to use when unselected
	Config* config;				// Configuration info
}

@property ( nonatomic, assign) CGRect boundaries;
@property ( nonatomic, assign) int ID;
@property ( nonatomic, assign) char *text;
@property ( nonatomic, assign) bool textVertical;
@property ( nonatomic, assign) int fontType;
@property ( nonatomic, assign) bool touchable;
@property ( nonatomic, assign) int alignment;
@property ( nonatomic, assign) int selected;

-(id)initWithRect:(CGRect)rect withID:(int)Id withImageSel:(NSString*)imgNameSel withImageUnsel:(NSString*)imgNameUnsel;
-(id)initWithRect:(CGRect)rect withID:(int)Id;							// Init with just a rectangular space
-(id)initWithRect:(CGRect)rect withID:(int)Id withText:(char*)Text;		// Init with a rectangle and text
-(id)initWithRect:(CGRect)rect withID:(int)Id withText:(char*)Text aligned:(int)align isVertical:(bool)vert isTouchable:(bool)touch fontType:(int)FontType; // Init with all aspects
-(int)wasHit:(CGPoint)pt;												// If point is in boundaries, return ID else 0
-(void)draw:(CGContextRef)context;										// Draw up the button in the passed context
-(CGSize)measureText;													// Internal function used to measure the text length of the button's text
-(CGSize)measureCharAt:(int)pos;										// Get measurements of a specific character in the button's text
-(CGSize)measureText:(char*)Text;										// Measure text of specified string
-(CGSize)measureChar:(char*)Text charAt:(int)index;						// Get measurements for a specific character in the specified text
+(CGSize)measureTextWithFont:(char*)fontName size:(int)fontSize text:(char*)string;	// Measure specified text using specified font name and size
-(void)drawBorder:(CGContextRef)context;								// Draw up the in/out border
	
@end