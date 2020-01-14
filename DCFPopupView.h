//
//  DCFPopupView.h
//  Sudoku Basic
//
//  Created by David Figge on 12/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DCFPopupView;

// Objects using this popup must support the following function and protocol
@protocol DCFPopupViewDelegate
-(void)	DCFPopupDidSelect:(DCFPopupView*)popup item:(int)itemnum withID:(int)msgID;	// Sent when user selects an item
-(void) DCFPopupCancelled:(DCFPopupView*)popup withID:(int)msgID;					// Sent if user cancels (clicks outside window)
@end
	
@interface DCFPopupView : UIView {
	UIImageView* imgView;						// The image's view
	UIView* backgroundView;						// The background view (lightly grayed)
	NSMutableArray* labels;						// Labels on window
	DCFPopupView* drawingLayer;					// Drawing layer for outlines and such (drawing layer is another DCFPopupView)
	bool isDrawingLayer;						// Flag to indicate if this is the drawing layer
	DCFPopupView* parent;						// Parent view (if drawing layer)
	id<DCFPopupViewDelegate> delegate;			// delegate for results
	UITapGestureRecognizer* tapRecognizer;		// Gesture Recognizer for taps
	int selectedItem;							// Item selected in tap
	int msgID;									// ID of popup (set on intializations by calling object
	UILabel* titleLabel;						// Label containing title
}

@property (nonatomic, retain) NSMutableArray* labels;

-(UILabel*)addLabelWithFrame:(CGRect)frame withText:(NSString*)text;		// Add a label with frame and text
- (id)initWithTitle:(NSString*)title withBaseImage:(NSString*)imgName withFrame:(CGRect)frm withDelegate:(id<DCFPopupViewDelegate>)del withID:(int)Id;		// Initialize object
-(id)initAsDrawingLayer:(CGRect)frame withImgView:(UIImageView*)imgview;		// Called by initWithTitle to initialize drawing layer
-(void)handleTaps:(UIGestureRecognizer *)sender;							// Tap gesture handler
-(int)getSelection:(CGPoint)pt;												// Translates tapped point to specific label containing tap
-(void)sendSelectedVal:(NSTimer*)timer;										// Used to send selection after animation draws clicking highlight
-(void)reCenter:(CGRect)frame;												// Used to recenter image if orientation change
-(void)reCenter:(CGRect)frame withChange:(CGPoint)chg;						// Used to recenter drawing layer if orientation change (called internally)

@end
