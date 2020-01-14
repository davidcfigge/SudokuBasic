//
//  HelpViewController.h
//  Class Timer
//
//  Created by David Figge on 1/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDFView.h"
#import "SliderMenuView.h"
#import "PageStatusBar.h"

@protocol iPadHelpProtocol
-(void) helpClosed;
@end

@interface pdfInfo : NSObject {
	CFStringRef pdfName;
}
@property (nonatomic, assign) CFStringRef pdfName;

-(id) initWithName:(CFStringRef)name position:(int)notUsed;

@end

@interface iPadHelpViewController : UIViewController <SliderMenuProtocol,PageChangeProtocol> {
	UIScrollView* scrollview;
	NSArray* pdfData;
	UINavigationBar* navbar;
	PageStatusBar* statusbar;
	PDFView* pdfview;
	CFStringRef pdfName;
	CGSize pdfSize;
	NSString* navTitle;
	id<iPadHelpProtocol> delegate;
}

@property (nonatomic, retain) UIScrollView* scrollview;
@property (nonatomic, retain) UINavigationBar* navbar;
@property (nonatomic, retain) PDFView* pdfview;
@property (nonatomic, assign) CFStringRef pdfName;
@property (nonatomic, retain) NSString* navTitle;

//-(IBAction)Done:(id)sender;
-(id)initWithTitle:(NSString*)title withDelegate:(id<iPadHelpProtocol>)del;
-(void)wasTapped:(int)ID;
-(void)PageChange;
@end
