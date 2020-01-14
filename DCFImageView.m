//
//  DCFImageView.m
//  Sudoku Basic
//
//  Created by David Figge on 12/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DCFImageView.h"


@implementation DCFImageView

@synthesize delegate,ID;

// Internal intialization routine used to initialize the drawing layer
-(id)initAsDrawingLayer:(CGRect)frame withDelegate:(id<DCFImgViewProtocol>)del withID:(int)Id {
	self = [super initWithFrame:frame];
	if (self != nil) {
		self.opaque = NO;				// make see-through
		self.delegate = del;			// Store delegate
		self.ID = Id;
		[self registerTapRecognizer];	// Register the tap recognizers
	}
	return self;
}

// Called to establish new boundaries. Passed on to drawing layer as well
-(void)newFrame:(CGRect)frm {
	self.frame = frm;
	if (drawingLayer != nil) drawingLayer.frame = CGRectMake(0, 0, frm.size.width, frm.size.height); // Drawing layer is based from upper left corner of image
}

// Primary initialization entry point
-(id)initWithImageName:(NSString*)imageName withDelegate:(id<DCFImgViewProtocol>)del withID:(int)Id {
	self = [super init];
	if (self != nil) {
		theImage[0] = [UIImage imageNamed:imageName];				// Create the background image
		[theImage[0] retain];
		theView = [[UIImageView alloc] initWithImage:theImage[0]];
		self.delegate = nil;										// Delegate not used on this layer
		[self addSubview:theView];									// Add background picture to view
		[self sendSubviewToBack:theView];
		curImage = 0;												// Current image being displayed
		CGRect myFrame = CGRectMake(0, 0, theImage[0].size.width, theImage[0].size.height);	// Establish the frame
		self.frame = myFrame;
		self.ID = Id;
			// Now add another view on top that can be for drawing on
		drawingLayer = nil;
		if (del != nil) {											// If there's a delegate, add an additional drawing layer
			drawingLayer = [[DCFImageView alloc] initAsDrawingLayer:myFrame withDelegate:del withID:ID];
			[self addSubview:(UIView*)drawingLayer];
		}
	}
	return self;
}

// Register another image to display (does not change display here)
-(void)addImage:(NSString*)imageName atPlace:(int)place {
	if (place == 0) {
		for (; place < 4; place++)					// Max places
			if ( theImage[place] == nil) break;		// Find room
		if (place == 4) return;						// No more room to add
	}
	if (theImage[place] != nil) [theImage[place] release];
	theImage[place] = [UIImage imageNamed:imageName];
	[theImage[place] retain];
}

// Change the currently displayed image
-(void)setImage:(int)imageNum {
	if (imageNum > 3) return;				// Number too high. Don't do that
	if (theImage[imageNum] == nil) return;	// No image set for that number
	if (curImage == imageNum) return;		// No change
	[theView removeFromSuperview];			// Remove old image
	curImage = imageNum;					// Set up new image
	theView = [[UIImageView alloc] initWithImage:theImage[curImage]];
	[self addSubview:theView];
	[self sendSubviewToBack:theView];
	self.bounds = CGRectMake(0, 0, theImage[curImage].size.width, theImage[curImage].size.height);	// Reset the bounds
	drawingLayer.bounds = self.bounds;		// Reset the drawing layer bounds as well.
}

// Used by drawing layer to catch taps. Tap Recognizers are registered here...
-(void)registerTapRecognizer {
	tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTaps:)];	// Single tap
	tapRecognizer.numberOfTapsRequired = 1;
	[self addGestureRecognizer:tapRecognizer];
	dblTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDblTaps:)];	// Double tap
	dblTapRecognizer.numberOfTapsRequired = 2;
	[self addGestureRecognizer:dblTapRecognizer];
}

// Taps come here (get the point location, then pass on to delegate)
-(void)handleTaps:(UIGestureRecognizer *)sender {
	CGPoint tapPoint = [sender locationInView:sender.view.superview];
	[delegate userTap:ID withLocation:tapPoint];
}

// Double-taps come here (get the point location, then pass on to delegate)
-(void)handleDblTaps:(UIGestureRecognizer *)sender {
	CGPoint tapPoint = [sender locationInView:sender.view.superview];
	[delegate userDblTap:ID withLocation:tapPoint];
}

// Request by system to draw the contents of the window. The image takes care of itself.
-(void)drawRect:(CGRect)bounds {
	if (delegate == nil) return;
	CGContextRef context = UIGraphicsGetCurrentContext();		// Get current context
	[delegate draw:self.ID withContext:context];				// Pass on to delegate
}

// Indicate that a portion of the window needs to be redrawn
-(void)invalidateRect:(CGRect)bounds {
	[theView setNeedsDisplayInRect:bounds];		
	[drawingLayer setNeedsDisplayInRect:CGRectMake(0, 0, bounds.size.width, bounds.size.height)];
	[drawingLayer setNeedsDisplayInRect:bounds];
}

-(void)dealloc {
	[super dealloc];
	[tapRecognizer release];
	[dblTapRecognizer release];
	[drawingLayer release];
	[theImage[0] release];
	[theImage[1] release];
	[theImage[2] release];
	[theImage[3] release];
}

@end
