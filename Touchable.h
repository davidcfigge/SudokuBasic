//
//  Touchable.h
//  Sudoku Basic
//
//  Created by David Figge on 12/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#define NOHIT -1
#define NOTSELECTED 0
#define ISSELECTED 1
#define ISSELECTED2 2

@protocol Touchable

-(int)wasHit:(CGPoint)pt;				// If point is in touchable area, return ID, otherwise return NOHIT
-(void)setSelected:(int)state;			// Call to alter selected state
-(int)selected;							// Call to retrieve selected state

@end