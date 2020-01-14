//
//  DCFImageView.h
//  Sudoku Basic
//
//  Created by David Figge on 12/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

// To use the DCFImgView object, you must support communications back via the DCFImgViewProtocol
@protocol DCFImgViewProtocol

-(void)draw:(int)ID withContext:(CGContextRef)context;		// A request to draw the contents of the drawing layer
-(void)userTap:(int)Id withLocation:(CGPoint)pt;			// Called when user taps on the image
-(void)userDblTap:(int)Id withLocation:(CGPoint)pt;			// Called when user double-taps on the image

@end


@interface DCFImageView : UIView {
	id<DCFImgViewProtocol> delegate;							// Object to communicate with (using the DCFImgViewProtocol)
	UIImage* theImage[4];									// Support up to 4 images
	UIImageView* theView;									// The current view
	UIView* drawingLayer;									// The drawing layer
	int ID;													// ID of the image (user defined)
	UITapGestureRecognizer* tapRecognizer;					// Gesture recognizers
	UITapGestureRecognizer* dblTapRecognizer;
	int curImage;											// Current image being displayed
}

@property ( nonatomic, assign) id<DCFImgViewProtocol> delegate;
@property ( nonatomic, assign) int ID;

// This is the entry point for creating the DCFImageView. Specifies the image to display, the delegate to communicate with, and the ID of the object (user defined)
-(id)initWithImageName:(NSString*)imageName withDelegate:(id<DCFImgViewProtocol>)delegate withID:(int)ID;
-(id)initAsDrawingLayer:(CGRect)frame withDelegate:(id<DCFImgViewProtocol>)delegate withID:(int)ID;	// Used internally to initialize the drawing layer
-(void)invalidateRect:(CGRect)bounds;						// Used to redraw all or a portion of the window
-(void)registerTapRecognizer;								// Registers the TAP and DOUBLE-TAP gesture recognizers
-(void)addImage:(NSString*)imageName atPlace:(int)place;	// Add a new image to display
-(void)setImage:(int)imageNum;								// Select the image to display now
-(void)newFrame:(CGRect)frm;								// Establish new frame settings (passes down to all layers)

@end
