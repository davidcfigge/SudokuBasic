//
//  SliderScrollView.m
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


#import "SliderMenuView.h"

#define MARGINS 15				// Define the margins on both sides of the slider menu

@implementation SliderMenuView

@synthesize menuOpts, font, color;

// The main initialization routine, including:
//  frame: the rectangle for the window to use on the view (slider content size will be calculated automatically)
//  opts: An array of strings containing the text for the menu options
//  FontOrNil: The (UIFont) font to use in the display. If nil, the default label font will be used (system font, size 17)
//  UIColorOrNil: The color for the text as a UIColor. If nil, the text color will be white.
//  del: The object to call when the user selects one of the menu options. The object must support the SliderMenuProtocol protocol, implementing wasTapped.
- (id)initWithFrame:(CGRect)frame withMenuOptions:(NSArray*)opts withFont:(UIFont*)FontOrNil withTextColor:(UIColor*)UIColorOrNil withDelegate:(id<SliderMenuProtocol>)del {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setMenuOpts:opts];			// Save menu opts (and retain)
		[self setFont:FontOrNil];			// Save font
		if (font == nil) font = [UIFont systemFontOfSize:17];	// If nil, default to system font, size 17
		[self setColor:UIColorOrNil];		// Save color
		if (UIColorOrNil == nil) [self setColor:[UIColor whiteColor]];	// If nil, use white
		delegate = del;						// Save the delegate for later use
		[self insertLabels];				// Add the labels to the UIScrollView
		UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)]; // Register tap recognizer
		[self addGestureRecognizer:tap];
		[tap release];
    }
    return self;
}

// Insert labels, as defined by the MenuOpts array, onto the ScrollView window
// When done, set the ContentSize property accordingly
-(void)insertLabels {
	labels = [NSMutableArray arrayWithCapacity:[menuOpts count]];	// Create an array to keep track of the labels (for tap locating)
	[labels retain];
	int currentID = 0;										// Go through giving each label an ID. Start at 0
	CGPoint startingPoint = CGPointMake(MARGINS,0);			// Origin for the first label
	bool selstate = YES;									// Set the first item to be selected, rest not
	for( NSString *string in menuOpts) {					// For each string (will be label) in the menuOpts array
		CGRect labelRect = CGRectMake(startingPoint.x, startingPoint.y, [string sizeWithFont:font].width+(MARGINS*2),self.bounds.size.height);	// Starting rectangle
		// Create a SliderMenuLabel, a subclass of UILabel designed to support this slider menu
		SliderMenuLabel* label = [[SliderMenuLabel alloc] initWithFrame:labelRect withText:string withFont:font withTextColor:color withSelected:selstate withID:(int)currentID];
		selstate = NO;										// Reset selected state to off for rest of menu
		currentID++;										// Increment ID
		[labels addObject:label];							// Add the label to the array of labels
		startingPoint.x += label.bounds.size.width;			// Move to start of next label
		[self addSubview:label];							// Add the label to the view
		[label release];
	}
	viewSize = CGSizeMake(startingPoint.x + MARGINS, self.bounds.size.height);	// Done now. Calculate the size of the contents
	[self setContentSize:viewSize];							// Set the contentSize for the scrollview.
}

// This function draws up the background image (SliderMenuBase.png) as the background for the ScrollView
- (void)drawRect:(CGRect)rect {
	UIImage *bg = [[UIImage imageNamed:@"SliderMenuBase.png"] stretchableImageWithLeftCapWidth:MARGINS topCapHeight:0];
	[bg drawInRect:self.bounds];
}

// Gesture Recongizer executes this function when user taps on the window
// This function determines what label was tapped, selects it, and notifies the registered delegate
-(void)tapped:(UIGestureRecognizer*)gr {
	int ID = -1;																// Start with ID being an illegal value
	CGPoint tapPoint = [gr locationInView:gr.view];								// Locate the point within the view where the tap occurred
	if (tapPoint.x < MARGINS || tapPoint.x > viewSize.width-MARGINS) return;	// If in the margins, ignore
	for (SliderMenuLabel* label in labels) {									// Check each label
		if (CGRectContainsPoint(label.rect,tapPoint)) ID = label.ID;			// If within the label's rectanglar area, reset ID to this label
		[label setSelected:(label.ID == ID)];									// Set selected to ON or OFF as appropriate
		[label setNeedsDisplay];												// Force a redraw of the label
	}
	[self setNeedsDisplay];														// Let's redraw the whole window
	[delegate wasTapped:ID];													// Tell the delegate which label was tapped
}

- (void)dealloc {
    [super dealloc];
	[menuOpts release];
	[labels release];
	[font release];
	[color release];
}


@end

// The SliderMenuLabel is a subclass of Label designed to support the SliderMenu. It should ONLY be called by the SliderMenuView class

@implementation SliderMenuLabel

@synthesize selected, ID, rect;

// Create the SliderMenuLabel
//  Frame: The frame for the label
//  labeltext: the text to appear on the label
//  font: the font for the text
//  TextColor: the color for the text
//  selState: ON (selected) or OFF (not selected)
//  labelID: a unique ID for this label
-(id)initWithFrame:(CGRect)frame withText:(NSString*)labeltext withFont:(UIFont*)font withTextColor:(UIColor*)textcolor withSelected:(BOOL)selState withID:(int)labelID {
	self = [super initWithFrame:frame];
	if (!self) return self;
	[self setRect:frame];
	[self setText:labeltext];
	[self setSelected:selState];
	[self setID:labelID];
	[self setBackgroundColor:[UIColor clearColor]];		// Don't let the default label draw routine write over our background
	[self setTextColor:textcolor];
	[self setFont:font];
	[self setTextAlignment:UITextAlignmentCenter];
	return self;
}

// This implementation of drawRect is used to draw the background of the label (selected or unselected), as well as a gray border
-(void)drawRect:(CGRect)drawrect {
	if (selected) {
		UIImage *bg = [[UIImage imageNamed:@"SliderMenuSel.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];	// Draw the 'selected' border
		[bg drawInRect:self.bounds];
	}
	CGContextRef context = UIGraphicsGetCurrentContext();		// Grab the current context
	UIGraphicsPushContext(context);								// Save the current state
	CGContextSetRGBStrokeColor(context, .5, .5, .5, 1);			// Draw a gray border
	CGContextSetLineWidth(context, 1);							// of width 1
	CGContextStrokeRect(context, self.bounds);
	UIGraphicsPopContext();										// Restore the context
	[super drawRect:drawrect];									// Use the normal label routine to finish drawing
}

@end

