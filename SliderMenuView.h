//
//  SliderScrollView.h
//  SliderMenu
//
//  Created by David Figge on 1/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
//  Slider Menu provides a horizontal menu (that can be slid) to allow for different 'modes' or 'selections'
//  The value is similar to that of a tab bar, but can be easily scrolled to allow more options, and is visually descriptive
//
//  To use in your program, you need
//    * SliderMenuView.h
//	  * SliderMenuView.m
//    * SliderMenuBase.png  -- Background for ScrollView
//    * SliderMenuSel.png   -- Background for selected items
//
//  To use, you'll need to:
//    1) Create an array of text descriptions
//    2) Call the initWithFrame:withMenuOptions:withFont:withTextColor:withDelegate to create the menu
//
//  The delegate, typically the view controller, must support the SliderMenuProtocol, which has one function: wasTapped.
//    When the user selects a menu option, the wasTapped function is called with the item number (in the array) that was selected. This
//    allows you to change the display based on what was selected.

#import <UIKit/UIKit.h>

@protocol SliderMenuProtocol

-(void)wasTapped:(int)ID;

@end


@interface SliderMenuLabel : UILabel {
	BOOL selected;
	int ID;
	CGRect rect;
}
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) int ID;
@property (nonatomic, assign) CGRect rect;
-(id)initWithFrame:(CGRect)frame withText:(NSString*)labeltext withFont:(UIFont*)font withTextColor:(UIColor*)textcolor withSelected:(BOOL)selState withID:(int)labelID;
@end

@interface SliderMenuView : UIScrollView {
	NSArray* menuOpts;
	NSMutableArray* labels;
	UIFont* font;
	UIColor* color;
	CGSize viewSize;
	<SliderMenuProtocol> delegate;
}
@property ( nonatomic, retain ) NSArray* menuOpts;
@property ( nonatomic, retain ) UIFont* font;
@property ( nonatomic, retain ) UIColor* color;

-(id)initWithFrame:(CGRect)frame withMenuOptions:(NSArray*)opts withFont:(UIFont*)FontOrNil withTextColor:(UIColor*)UIColorOrNil withDelegate:(<SliderMenuProtocol>)del;
//-(CGFloat)calculateContentWidth;
-(void)insertLabels;
-(void)tapped:(UIGestureRecognizer*)gr;

@end
