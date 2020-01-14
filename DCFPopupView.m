//
//  DCFPopupView.m
//  Sudoku Basic
//
//  Created by David Figge on 12/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
// Display a popup window in the middle of the screen as an alert or menu item

#import "DCFPopupView.h"
#import <QuartzCore/QuartzCore.h>


@implementation DCFPopupView

@synthesize labels;

// Main initialization routine, including
// title: Title of popup box
// frm: frame of hosting window (which is grayed out, typically the whole screen)
// del: Object that supports the DCFPopupViewDelegate protocol to handle messages (selected, cancelled)
// Id: Set by caller, typically a unique ID specifying which popup window this is (menu, alert, messagebox, etc)
- (id)initWithTitle:(NSString*)title withBaseImage:(NSString*)imgName withFrame:(CGRect)frm withDelegate:(id<DCFPopupViewDelegate>)del withID:(int)Id {
    self = [super initWithFrame:frm];
    if (self) {
		msgID = Id;																	// Save ID
		self.opaque = false;														// See through
		delegate = del;																// Save delegate
		backgroundView = [[UIView alloc] initWithFrame:self.frame];						// Create background view (that dims windows)
		backgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.4];		// Make it black and somewhat transparent
		[self addSubview:backgroundView];														// Add that layer
		UIImage* img = [UIImage imageNamed:imgName];						// Add the image
		imgView = [[UIImageView alloc] initWithImage:img];
		imgView.frame = CGRectMake((self.frame.size.width - imgView.frame.size.width) / 2,	// Center on window
								   (self.frame.size.height - imgView.frame.size.height) / 2, imgView.frame.size.width, imgView.frame.size.height);
		imgView.opaque = false;
		[self addSubview:imgView];													// Add to window stack
		isDrawingLayer = false;														// This isn't the drawing layer
		drawingLayer = [[DCFPopupView alloc] initAsDrawingLayer:imgView.frame withImgView:imgView];		// Add a drawing layer
		[self addSubview:drawingLayer];												// Add it to the window stack
		titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,10,imgView.frame.size.width,50)];
		titleLabel.text = title;															// Initialize it
		titleLabel.textAlignment = UITextAlignmentCenter;								// Center the title
		titleLabel.adjustsFontSizeToFitWidth = YES;										// Make sure it fits
		titleLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];	// No background color for title
		titleLabel.font = [UIFont fontWithName:@"Papyrus" size:36];						// Draw up the title
		[imgView addSubview:titleLabel];
		tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTaps:)];	// Set up to recognize gestures
		tapRecognizer.numberOfTapsRequired = 1;
		[self addGestureRecognizer:tapRecognizer];
	}
	return self;
}

-(void)reCenter:(CGRect)frame {
	self.hidden = YES;
	drawingLayer.hidden = YES;
	CGPoint ctr = CGPointMake(frame.size.width/2, frame.size.height/2);
	CGPoint octr = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
	CGPoint chg = CGPointMake(ctr.x - octr.x, ctr.y - octr.y);
	self.frame = frame;
	backgroundView.frame = frame;
	imgView.center = CGPointMake(frame.size.width/2, frame.size.height/2);
	[drawingLayer reCenter:frame withChange:chg];
	self.hidden = NO;
	drawingLayer.hidden = NO;
}

-(void)reCenter:(CGRect)frame withChange:(CGPoint)chg {
	if (!isDrawingLayer) return;
	[self setNeedsDisplay];
}

// Initialize the drawing layer
-(id)initAsDrawingLayer:(CGRect)frame withImgView:(UIImageView*)imgview {
	self = [super initWithFrame:frame];
	if (!self) return nil;
	self.opaque = NO;									// See through
	isDrawingLayer = true;								// Set drawing layer flag
	imgView = imgview;
	labels = [NSMutableArray arrayWithCapacity:10];		// Create array for labels
	[labels retain];
	return self;
}

// Add a label to the window, with frame and text
// Specify frame.origin.x = 0 to have width of frame automatically set
-(UILabel*)addLabelWithFrame:(CGRect)frame withText:(NSString*)text {
	if (frame.origin.x == 0) {
		frame.origin.x = imgView.frame.size.width/10;
		frame.size.width = 8 * (imgView.frame.size.width) / 10;
	}
	UILabel* label = [[UILabel alloc] initWithFrame:frame];
	label.text =text;
	label.textAlignment = UITextAlignmentCenter;
	label.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
	label.adjustsFontSizeToFitWidth = YES;
	label.font = [UIFont fontWithName:@"Papyrus" size:24];
	label.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
	[imgView addSubview:label];
	[drawingLayer.labels addObject:label];									// Add it to the labels array also
	[label autorelease];
	return label;												// Return the label object for tweaking by caller
}

// Process taps
-(void)handleTaps:(UIGestureRecognizer*)sender {
	CGPoint tapPoint = [sender locationInView:sender.view];		// Get the tap coord
	if (!CGRectContainsPoint(drawingLayer.frame, tapPoint))		// If not in window
		[delegate DCFPopupCancelled:self withID:msgID];				// Abort by calling the delegate's CANCEL method
	tapPoint.x -= drawingLayer.frame.origin.x;					// Make tap point be relative to the start of the popup window
	tapPoint.y -= drawingLayer.frame.origin.y;
	int sel = [drawingLayer getSelection:tapPoint];				// Get the label tapped on
	if (sel == -1) return;										// If none, return
	selectedItem = sel;											// Save selected item number
	[NSTimer scheduledTimerWithTimeInterval:.25 target:self selector:@selector(sendSelectedVal:) userInfo:nil repeats:NO];	// Let the label appear selected for .25 seconds, then call del
}

// Return item number (in order added) of option selected, -1 if none
-(int)getSelection:(CGPoint)pt {
	if (!isDrawingLayer) return [drawingLayer getSelection:pt];	// Make sure this message is process via the drawing layer
	int sel = -1;												// Default: no selection
	int cnt = 0;												// Item number selected
	for (int x = 0; x < labels.count; x++) {					// For each label
		UILabel* lbl = [labels objectAtIndex:x];				// Get the label object
		if (lbl.numberOfLines != 1) continue;					// if multiline, ignore (don't tap on or count message label if messagebox)
		if (CGRectContainsPoint(lbl.frame, pt)) {				// If label contains the tapped point
			lbl.backgroundColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:1];	// Set the background of the label to blue to indicate selection
			lbl.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];		// Make the text white
			sel = cnt;											// Remember selected item
			break;
		}
		cnt++;
	}
	return sel;													// Return selected item
}

// When timer goes off, call delegate with selectedItem message
-(void)sendSelectedVal:(NSTimer*)timer {
	[delegate DCFPopupDidSelect:self item:selectedItem withID:msgID];
}

// Draw up the drawing layer, which is each label outlined in etch
- (void)drawRect:(CGRect)rect {
	if (!isDrawingLayer) return;								// Ignore image layer
	self.frame = imgView.frame;
    CGContextRef context = UIGraphicsGetCurrentContext();		// Get the graphics context to draw on
	for (UILabel* lbl in labels) {								// For each label
		CGRect f = lbl.frame;										// Etch around the border
		CGPoint pts[] = { CGPointMake(f.origin.x-4, f.origin.y-4),CGPointMake(f.origin.x+f.size.width+4, f.origin.y-4),
			CGPointMake(f.origin.x+f.size.width+4,f.origin.y+f.size.height+4), CGPointMake(f.origin.x-4,f.origin.y+f.size.height+4) };
		CGContextSetRGBStrokeColor(context, 0, 0, 0, .4);
		CGContextSetLineWidth(context, 2);
		CGPoint ptsBLK[] = { pts[0],pts[1],							// top black (outside)
							pts[0],pts[3],							// left black (outside)
							CGPointMake(pts[3].x+2,pts[3].y-2),	CGPointMake(pts[2].x-2,pts[2].y-2),	// bottom black (inside)
							CGPointMake(pts[1].x-2,pts[1].y+2), CGPointMake(pts[2].x-2,pts[2].y-2),	// right black (inside)
		};
		CGContextStrokeLineSegments(context, ptsBLK, 8);
		
		CGPoint ptsWHT[] = { CGPointMake(pts[0].x+2,pts[0].y+2),CGPointMake(pts[3].x+2,pts[3].y-2),  // left white (inside)
							CGPointMake(pts[0].x+2,pts[0].y+2),CGPointMake(pts[1].x-2,pts[1].y+2),	 // top white (inside)
							pts[1],pts[2],															 // right white (outside)
							pts[2],pts[3],															 // bottom white (outside)
			 };
		CGContextSetRGBStrokeColor(context, 1, 1, 1, .4);
		CGContextStrokeLineSegments(context, ptsWHT, 8);
	}
}


- (void)dealloc {
	[backgroundView release];
	[titleLabel release];
	[tapRecognizer release];
	[labels release];
	[drawingLayer release];
    [super dealloc];
}


@end
