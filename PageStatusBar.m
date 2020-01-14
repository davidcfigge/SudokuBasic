//
//  PageStatusBar.m
//  Sudoku Basic
//
//  Created by David Figge on 1/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PageStatusBar.h"


@implementation PageStatusBar


- (id)initWithFrame:(CGRect)frame withTotalPages:(int)pages withDelegate:(id<PagingProtocol>)del {
    
    self = [super initWithFrame:frame];
    if (self) {
		ppdelegate = del;
        backgroundImg = [UIImage imageNamed:@"pgstatusbar.png"];
		nextImg = [UIImage imageNamed:@"nextpg.png"];
		nextImgDisabled = [UIImage imageNamed:@"nextpgd.png"];
		prevImg = [UIImage imageNamed:@"prevpg.png"];
		prevImgDisabled = [UIImage imageNamed:@"prevpgd.png"];
		scale = frame.size.height / 60;								// 60 was the original scale for the images
		prevRect = CGRectMake(10, 0, 41 * scale, frame.size.height);
		nextRect = CGRectMake(frame.size.width-10-41*scale,0,41*scale,frame.size.height);
		font = [UIFont fontWithName:@"Arial" size:17];
		NSString *txt = @"Page x of xx";
		CGSize sz = [txt sizeWithFont:font];
		textLoc = CGPointMake((frame.size.width - sz.width)/2, 40 * scale);
		[self resetWithTotalPages:pages];
		UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
		[self addGestureRecognizer:tap];
		[tap release];
    }
    return self;
}

-(void)tapped:(UIGestureRecognizer*)sender {
	CGPoint tapPoint = [sender locationInView:sender.view];								// Locate the point within the view where the tap occurred
	if (CGRectContainsPoint(nextRect, tapPoint))
		[self nextPage];
	if (CGRectContainsPoint(prevRect, tapPoint))
		[self prevPage];
}

-(void)nextPage {
	if (pageNum < totalPages) {
		pageNum++;
		[self setNeedsDisplay];
		[ppdelegate NextPage];
	}
}

-(void)prevPage {
	if (pageNum > 0) {
		pageNum--;
		[self setNeedsDisplay];
		[ppdelegate PreviousPage];
	}
}

-(void)resetWithTotalPages:(int)pages {
	totalPages = pages;
	if (totalPages == 0)
		totalPages = [ppdelegate GetTotalPages];
	pageNum = 1;
	[self setNeedsDisplay];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
	[backgroundImg drawInRect:self.bounds];
	if (pageNum == totalPages)
		[nextImgDisabled drawInRect:nextRect];
	else 
		[nextImg drawInRect:nextRect];
	if (pageNum == 1)
		[prevImgDisabled drawInRect:prevRect];
	else
		[prevImg drawInRect:prevRect];
	NSString* text = [NSString stringWithFormat:@"Page %d of %d",pageNum, totalPages];
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0));
	CGContextSetRGBFillColor(context, 0, 0, 0, 1);
	CGContextSetTextDrawingMode(context, kCGTextFill);
	char txt[20];
	[text getCString:txt maxLength:20 encoding:[NSString defaultCStringEncoding]];
	CGContextSelectFont(context, "Arial", 17, kCGEncodingMacRoman);
	CGContextShowTextAtPoint(context, textLoc.x, textLoc.y, txt, strlen(txt));
}


- (void)dealloc {
    [super dealloc];
}


@end
