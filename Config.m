//
//  Config.m
//  Sudoku Basic
//
//  Created by David Figge on 11/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
// The Config object is used to store settings based on the current configuration of the
// game and device. Settings is used for themes or values that would be saved or loaded between runs

#import "Config.h"


@implementation Config

@synthesize device;
@synthesize orientation;
@synthesize screenSize;
@synthesize cellSize, valueOffset, pencilOffsets, boardBorder, gridLineWidth;
@synthesize padBorder, padGridLineWidth, padGridBtnSize;

// (initialize if needed and) return the only config object in the system
+(Config*)config
{
	static Config* cfg;
	if (cfg == nil) {						// If object doesn't exist yet...
		cfg = [[Config alloc] init];		// create it
		CGPoint p = CGPointMake(0, 0);
		cfg.boardBorder = p;				// Initialize to default values
		cfg.valueOffset = p;
		cfg.gridLineWidth = 0;
		[cfg initPencilOffsets];
		for (int x = 0; x < 9; x++) { [cfg setPencilPos:x position:p]; }
		// Get size of current screen
		cfg.screenSize = [[UIScreen mainScreen]applicationFrame];
		[cfg setOrientation:UIInterfaceOrientationPortrait];	// Always starts in portrait mode
		cfg.device = IPADDEVICE;			// Default to iPad
		[cfg autorelease];
	}
	return cfg;
}

// Return the coordinates of the screen (adjusts to orientation)
-(CGRect)screenRect {
	if (orientation == PORTRAIT || orientation == UPSIDEDOWN)
		return CGRectMake(0, 0, screenSize.size.width, screenSize.size.height);
	else
		return CGRectMake(0, 0, screenSize.size.height, screenSize.size.width);

}

// Return coordinates of the board shown/hidden based on current orientation
-(CGRect)board:(int)SHOWNorHIDDEN {
	return board[SHOWNorHIDDEN][orientation];
}

// Return coordintates of the control pad shown/hidden based on current orientation
-(CGRect)pad:(int)SHOWNorHIDDEN {
	return pad[SHOWNorHIDDEN][orientation];
}

// Initialize the config object based on data within the configInfo structure passed in
-(void)setConfiguration:(struct configInfo *)data {
	device = data->device;
	board[SHOWN][PORTRAIT] = data->boardShownPort;
	board[HIDDEN][PORTRAIT] = data->boardHiddenPort;
	board[SHOWN][UPSIDEDOWN] = data->boardShownUD;
	board[HIDDEN][UPSIDEDOWN] = data->boardHiddenUD;
	board[SHOWN][LANDSCAPELEFT] = data->boardShownLeft;
	board[HIDDEN][LANDSCAPELEFT] = data->boardHiddenLeft;
	board[SHOWN][LANDSCAPERIGHT] = data->boardShownRight;
	board[HIDDEN][LANDSCAPERIGHT] = data->boardHiddenRight;
	pad[SHOWN][PORTRAIT] = data->padShownPort;
	pad[HIDDEN][PORTRAIT] = data->padHiddenPort;
	pad[SHOWN][UPSIDEDOWN] = data->padShownUD;
	pad[HIDDEN][UPSIDEDOWN] = data->padHiddenUD;
	pad[SHOWN][LANDSCAPELEFT] = data->padShownLeft;
	pad[HIDDEN][LANDSCAPELEFT] = data->padHiddenLeft;
	pad[SHOWN][LANDSCAPERIGHT] = data->padShownRight;
	pad[HIDDEN][LANDSCAPERIGHT] = data->padHiddenRight;
	cellSize = data->cellSize;
	for (int x = 0; x < 9; x++) {
		[self setPencilPos:x+1 position:data->pencilOffset[x]];
	}
	valueOffset = data->valueOffset;
	boardBorder = data->boardBorder;
	gridLineWidth = data->gridLineWidth;
	padBorder = data->padBorder;
	padGridLineWidth = data->padGridLineWidth;
	padGridBtnSize = data->padGridBtnSize;
}

// Convert Apple's orientation values to the ones used by this program
-(int)convertOrientation:(int)UIInterfaceOrientationVal {
	switch (UIInterfaceOrientationVal) {
		case UIInterfaceOrientationPortrait:
			return PORTRAIT;
		case UIInterfaceOrientationPortraitUpsideDown:
			return UPSIDEDOWN;
		case UIInterfaceOrientationLandscapeLeft:
			return LANDSCAPELEFT;
		case UIInterfaceOrientationLandscapeRight:
			return LANDSCAPERIGHT;
	}
	return -1;

}

// Set the program's current orientation based on Apple's orientation value
-(void)setOrientation:(int)UIInterfaceOrientationVal {
	orientation = [self convertOrientation:UIInterfaceOrientationVal];
}

// Set the coordinates of a pad button
-(void)setPadButtonRect:(int)btn frame:(CGRect)rect {
	padButtons[btn] = rect;
}

// Get the coordinates of a pad button
-(CGRect)getPadButtonRect:(int)btn {
	return padButtons[btn];
}

// Set the text of a pad button
-(void)setPadBtnText:(int)btn text:(char*)label {
	padBtnText[btn] = label;
}

// Get the text of a pad button
-(char*)getPadBtnText:(int)btn {
	return padBtnText[btn];
}

// Get a pointer to the pencil offset coordinates
+(CGPoint*) getPencilOffsets {
	static CGPoint marks[NUMBERSPERROW+1];
	return marks;
}

// Initialize the penciloffsets variable
-(void)initPencilOffsets {
	pencilOffsets = [Config getPencilOffsets];
}

// Get a specific CGRect for the pad or board, hidden or shown, based on the current orientation
-(CGRect)getLocation:(int)boardAndLocation {
	switch (boardAndLocation) {
		case BOARDSHOWN:
			return board[SHOWN][orientation];
		case BOARDHIDDEN:
			return board[HIDDEN][orientation];
		case PADSHOWN:
			return pad[SHOWN][orientation];
		case PADHIDDEN:
			return pad[HIDDEN][orientation];
	}
	return CGRectMake(0, 0, 0, 0);
}

// Return x offset to pencil mark within cell
-(float)PencilXPos:(int)number {
	return pencilOffsets[number].x;
}

// return y offset to pencil mark within a cell
-(float)PencilYPos:(int)number {
	return pencilOffsets[number].y;
}

// Set the x and y coordinates of a pencil mark within a cell
-(void)setPencilPos:(int)number position:(CGPoint)pos {
	pencilOffsets[number] = pos;
}
@end
