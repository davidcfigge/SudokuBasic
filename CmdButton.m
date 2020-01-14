//
//  TouchPoint.m
//  Sudoku Basic
//
//  Created by David Figge on 12/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
// This class defines a rectangle on the screen that can be touched

#import "CmdButton.h"
#import <UIKit/UIStringDrawing.h>


@implementation CmdButton

@synthesize ID, touchable, fontType, alignment;

@synthesize text, selected, boundaries, textVertical;

// Normal initializtion, including
// rect: frame for button (origin upper left corner of containing window)
// Id: int id of this button, should be unique
// Text: text for button
// align: alignment desired (TEXTALIGNLEFT, TEXTALIGNCTR, TEXTALIGNRIGHT)
// vert: set to true if text to be displayed vertically (default horizontal)
// touch: flag indicating if the button is selectable
// FontType: the (settings based) font type used
-(id)initWithRect:(CGRect)rect withID:(int)Id withText:(char*)Text aligned:(int)align isVertical:(bool)vert isTouchable:(bool)touch fontType:(int)FontType {
	self = [self initWithRect:rect withID:Id withText:Text];
	if (self != nil) {
		textVertical = vert;
		imagesel = imageunsel = nil;
		touchable = touch;
		fontType = FontType;
		config = [Config config];
	}
	return self;
}

-(id)initWithRect:(CGRect)rect withID:(int)Id withImageSel:(NSString*)imgNameSel withImageUnsel:(NSString*)imgNameUnsel {
	self = [self initWithRect:rect withID:Id];
	if (self != nil) {
		imagesel = [UIImage imageNamed:imgNameSel];
		[imagesel retain];
		imageunsel = [UIImage imageNamed:imgNameUnsel];
		[imageunsel retain];
	}
	return self;
}

// Initialize using frame, ID, and text only
-(id)initWithRect:(CGRect)rect withID:(int)Id withText:(char*)Text {
	self = [self initWithRect:rect withID:Id];
	if (self != nil) {
		text = Text;
		imagesel = imageunsel = nil;
	}
	return self;
}

// Initialize using rect and ID only (text defaulted to "", align defaulted to center, fontType defaulted to FONTCMDSTRING
-(id)initWithRect:(CGRect)rect withID:(int)Id {
	self = [super init];
	if (self != nil) {
		imagesel = imageunsel = nil;
		boundaries = rect;
		ID = Id;
		text = "";
		textVertical = NO;
		touchable = YES;
		alignment = TEXTALIGNCTR;
		fontType = FONTCMDSTRING;
		settings = [Settings settings];
		[settings retain];
	}
	return self;
}

// Perform hit test for point specified. If within bounds, return button's ID, otherwise NOHIT
-(int)wasHit:(CGPoint)pt {
	if (CGRectContainsPoint(boundaries, pt))
		return ID;
	return NOHIT;
}

// Measure the size of the object's text string and font type
-(CGSize)measureText {
	return [self measureText:text];
}

// Measure the size of a specific character in the object's text string and font type (used for vertical drawing)
-(CGSize)measureCharAt:(int)pos {
	return [self measureChar:text charAt:pos];
}

// Measure the size of the specified text string, using the object's font type
-(CGSize)measureText:(char*)Text {
	return [CmdButton measureTextWithFont:[settings getFontName:fontType] size:[settings getFontSize:fontType] text:Text];
}

// Measure the specified character in the specified text string using the object's font type
-(CGSize)measureChar:(char*)Text charAt:(int)index {
	char str[2];						// Create a string that is just that character
	str[1] = '\0';						// Terminator
	str[0] = Text[index];				// Character
	return [self measureText:str];		// Measure the character
}

// Measure specified text with the specified font and size
+(CGSize)measureTextWithFont:(char*)fontName size:(int)fontSize text:(char*)string {
	NSString* fntName = [[[NSString alloc] initWithCString:fontName] autorelease];		// Create the font name as NSString
	UIFont* font = [UIFont fontWithName:fntName size:fontSize];				// Create the font
	NSString* text = [[[NSString alloc] initWithCString:string] autorelease];				// Copy the text to an NSString
	CGSize size = [text sizeWithFont:font];									// Measure the font
	size.height /= 2;														// height seems off. size.height/2 seems to work.
	return size;
}

// Draw up the button's text
-(void)draw:(CGContextRef)context {
	if (imagesel != nil) {
		if (selected) [imagesel drawInRect:boundaries];
		else [imageunsel drawInRect:boundaries];
		return;
	}
	if (text == nil || text[0] == '\0') return;			// If text isn't set, nothing to draw
	int TEXTMARGIN = 5;									// Default margin
	[settings setContext:context forFontItem:fontType+selected];	// Set up context based on font type
	CGPoint pt = CGPointMake(boundaries.origin.x+TEXTMARGIN, boundaries.origin.y+TEXTMARGIN);	// Establish the default left-aligned text starting point
	[self drawBorder:context];							// Draw up the 'in/out' border
	if (textVertical) {									// If vertical text, draw it
		// First calculate total height if centered or right(bottom) justified
		if (alignment != TEXTALIGNLEFT) {				// If not left aligned (which is actually upper aligned with isVertical set)
			int totalHeight = 0;						// Calculate total height of text
			for (int x = 0; x < strlen(text); x++) {
				CGSize sz = [self measureCharAt:x];
				totalHeight += sz.height;
			}
			pt.y = boundaries.origin.y + (boundaries.size.height - totalHeight)/2;	// Locate center point of text
		}
		if (selected) pt.y+=1;
		for (int x = 0; x < strlen(text); x++) {		// Draw up each character centered width-wise
			CGSize sz = [self measureCharAt:x];
			pt.x = boundaries.origin.x + (boundaries.size.width - sz.width)/2;
			if (selected) pt.x+=1;
			CGContextShowTextAtPoint(context, pt.x, pt.y, text+x, 1);
			if (config.device == IPADDEVICE)
				pt.y += sz.height + 5;						// Moving down 5 extra pixels each char seems to work
			else 
				pt.y += sz.height+2;
		}
	}
	else {										// Not vertical
		CGSize txtSize = [self measureText];
		pt.y = boundaries.origin.y + (boundaries.size.height + txtSize.height)/2;	// Left-justified starting point
		if (alignment != TEXTALIGNLEFT) {
			if (alignment == TEXTALIGNCTR)
				pt.x = boundaries.origin.x + (boundaries.size.width - txtSize.width)/2;	// Center justified staring point
			else
				pt.x = boundaries.origin.x + boundaries.size.width - txtSize.width - TEXTMARGIN;	// Right justified starting point
		}
		if (selected) {
			pt.x += 1;
			pt.y += 1;
		}
		CGContextShowTextAtPoint(context, pt.x, pt.y, text, strlen(text));	// Draw up the text
	}
	
}

-(void)drawBorder:(CGContextRef)context {
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


@end
