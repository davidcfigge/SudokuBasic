//
//  PageStatusBar.h
//  Sudoku Basic
//
//  Created by David Figge on 1/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PagingProtocol.h"


@interface PageStatusBar : UIView {
	<PagingProtocol> ppdelegate;
	UIImage* backgroundImg;
	UIImage* nextImg;
	UIImage* prevImg;
	UIImage* nextImgDisabled;
	UIImage* prevImgDisabled;
	CGRect nextRect;
	CGRect prevRect;
	float scale;
	int pageNum;
	int totalPages;
	UIFont* font;
	CGPoint textLoc;
}

-(id)initWithFrame:(CGRect)frame withTotalPages:(int)pages withDelegate:(<PagingProtocol>)del;
-(void)nextPage;
-(void)prevPage;
-(void)resetWithTotalPages:(int)pages;
-(void)tapped:(UIGestureRecognizer*)sender;

@end
