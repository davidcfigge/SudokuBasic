//
//  Settings.m
//  Sudoku Basic
//
//  Created by David Figge on 11/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
// Settings handles anything that might ultimately be saved into a 'theme'

#import "Settings.h"


@implementation Settings
@synthesize filterMode;
@dynamic pencilMode;

//Set up for (currently only) theme

// Dynamic propertise
-(int) pencilMode { return pencilMode; }									// Get the current pencil mode (PENCIL_DEFAULT, PENCIL_AUTO, PENCIL_HINTS
-(void) setPencilMode:(int)val {											// Set the pencil mode
	if (val < 0 || val >= PENCIL_MODES_COUNT) return;
	pencilMode = val;
}

-(void) setCellCounts {														// Set the number of defaulted cell values for various game difficulty levels
	// Settings: Tough=21, Hard=25, Medium=29, Easier=33 easy=37
	cellCounts[0] = 34;		// Easiest
	cellCounts[1] = 32;		// Easier
	cellCounts[2] = 30;		// Normal
	cellCounts[3] = 28;		// Harder
	cellCounts[4] = 26;		// Hardest
}

-(int)getCellCount:(int)level {												// Get the number of defaulted cell values for a specific difficulty level
	return cellCounts[level];
}

+(Settings*)settings														// Return the settings object
{
	static Settings* stngs;
	if (stngs == nil) {														// If settings hasn't been set up yet
		stngs = [[Settings alloc] init];									// Create it and set up the default values
		stngs.pencilMode = PENCIL_DEFAULT;
		stngs.filterMode = false;
		[stngs setCellCounts];
		[stngs autorelease];
	}
	return stngs;
}

// Establish the font settings and color settings for a particular text/color element (e.g. Pause Button or Cell Value)
-(void)setThemeInfo:(int)fontType fontName:(char*)name fontSize:(float)size fontRed:(float)red fontGreen:(float)green fontBlue:(float)blue fontAlpha:(float)alpha {
	themeInfo.fontData[fontType].fontName = name;
	themeInfo.fontData[fontType].fontSize = size;
	themeInfo.fontData[fontType].fontColorRed = red;
	themeInfo.fontData[fontType].fontColorGreen = green;
	themeInfo.fontData[fontType].fontColorBlue = blue;
	themeInfo.fontData[fontType].fontColorAlpha = alpha;
}

// Get the font name of the specified font type
-(char*)getFontName:(int)fontType {
	return themeInfo.fontData[fontType].fontName;
}

// Get the font size of the specified font type
-(int)getFontSize:(int)fontType {
	return themeInfo.fontData[fontType].fontSize;
}

// Set up the text context in order to draw a particular element based on the font item (e.g. FONTMENUITEM)
-(void)setContext:(CGContextRef)context forFontItem:(int)FontItem {
	// Set up the fill color
	CGContextSetRGBFillColor(context, themeInfo.fontData[FontItem].fontColorRed, themeInfo.fontData[FontItem].fontColorGreen, themeInfo.fontData[FontItem].fontColorBlue, themeInfo.fontData[FontItem].fontColorAlpha);
	// Set up the stroke color (same as the fill color)
	CGContextSetRGBStrokeColor(context, themeInfo.fontData[FontItem].fontColorRed, themeInfo.fontData[FontItem].fontColorGreen, themeInfo.fontData[FontItem].fontColorBlue, themeInfo.fontData[FontItem].fontColorAlpha);
	// If there is a font name (some are just colors), establish the font
	if (themeInfo.fontData[FontItem].fontName[0]) // if font name specified
		CGContextSelectFont(context, themeInfo.fontData[FontItem].fontName, themeInfo.fontData[FontItem].fontSize, kCGEncodingMacRoman);
	// Set the drawing mode to fill characters
	CGContextSetTextDrawingMode(context, kCGTextFill);
}

// Set up the context for a pencil mark
-(void)setContextForPencil:(CGContextRef)context withHighlight:(BOOL)hl {
	int index = FONTPENCIL;							// We're using the FONTPENCIL font item
	if (hl == YES)									// If highlighting is on, also use FONTPENCIL
		index = FONTPENCIL;
	if (pencilMode == PENCIL_HINTS && hl == YES)	// If pencil hints are on and highlight is on, use 'FONTHIGHLTPENCIL]'
		index = FONTHIGHLTPENCIL;
	[self setContext:context forFontItem:index];	// Now set up the context
}

// Set up the context for the cell's value (one for default, the other for user set)
-(void)setContextForValue:(CGContextRef)context isDefValue:(BOOL)dv {
	[self setContext:context forFontItem:(dv == YES ? FONTDEFVALUE : FONTVALUE)];
}

@end
