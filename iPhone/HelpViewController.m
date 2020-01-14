//
//  HelpViewController.m
//  Class Timer
//
//  Created by David Figge on 1/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HelpViewController.h"

@implementation pdfInfo
@synthesize pdfName;

#define VIEWWIDTH 320
#define VIEWHEIGHT 480
#define NAVBARHEIGHT 44
#define SLIDERMENUHEIGHT 44
#define STATUSBARHEIGHT 30

-(id) initWithName:(CFStringRef)name position:(int)notused {   // For some reason, the second parameter seems needed
	self = [super init];
	if (!self) return nil;
	[self setPdfName:name];
	return self;
}
@end

@implementation HelpViewController

@synthesize scrollview, navbar, pdfview, pdfName, navTitle;

-(id)initWithTitle:(NSString*)title withDelegate:(id<iPhoneHelpProtocol>)del{
	self = [super init];
	if (!self) return self;
	delegate = del;
	pdfData  = [NSArray arrayWithObjects: 
				[[pdfInfo alloc] initWithName:CFSTR("iPhoneAppHelp.pdf") position:0 ],
				[[pdfInfo alloc] initWithName:CFSTR("iPhoneRules.pdf") position:0 ],
				[[pdfInfo alloc] initWithName:CFSTR("iPhoneLesson1.pdf") position:0 ],
				[[pdfInfo alloc] initWithName:CFSTR("iPhoneLesson2.pdf") position:0 ],
				[[pdfInfo alloc] initWithName:CFSTR("iPhoneLesson3.pdf") position:0 ],
				[[pdfInfo alloc] initWithName:CFSTR("iPhoneLesson4.pdf") position:0 ],
				[[pdfInfo alloc] initWithName:CFSTR("iPhoneLesson5.pdf") position:0 ],
				[[pdfInfo alloc] initWithName:CFSTR("iPhoneLesson6.pdf") position:0 ],
				[[pdfInfo alloc] initWithName:CFSTR("iPhoneLesson7.pdf") position:0 ],
				[[pdfInfo alloc] initWithName:CFSTR("iPhoneOrigins.pdf") position:0 ],
				[[pdfInfo alloc] initWithName:CFSTR("iPhoneFAQ.pdf") position:0 ],
				[[pdfInfo alloc] initWithName:CFSTR("iPhoneAbout.pdf") position:0 ],
				nil];
	[pdfData retain];
																		  
	pdfInfo* info = [pdfData objectAtIndex:0];
	[self setPdfName:info.pdfName];
	[self setNavTitle:title];
	return self;
}

-(void)viewDidLoad {
	// First, let's create the navigation bar for the top of the window
	navbar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, VIEWWIDTH, NAVBARHEIGHT)];		// Typically 44px height
	// Create an item to 'push' onto the navigation bar that is a title and a Done button
	UINavigationItem *ttl = [[UINavigationItem alloc] initWithTitle:navTitle];		// Title
	// Create a button to press when the user's done with the help window
	UIBarButtonItem* doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(Done:)]; // calls this class' Done: routine
	// Now set the 'leftBarButtonItem' of the title to be the done button
	ttl.leftBarButtonItem = doneBtn;
	[navbar pushNavigationItem:ttl animated:NO];		// Now push it onto the stack
	[doneBtn release];
	[ttl release];
	
	// Now the slider menu / tab bar
	NSArray* tabs = [ NSArray arrayWithObjects:@"App Help",@"Sudoku Rules",@"Lesson 1",@"Lesson 2",@"Lesson 3",@"Lesson 4",@"Lesson 5",@"Lesson 6",@"Lesson 7",@"Sudoku Origins",@"FAQ",@"About",nil ];
	SliderMenuView* ssv = [[SliderMenuView alloc] initWithFrame:CGRectMake(0, NAVBARHEIGHT, VIEWWIDTH, SLIDERMENUHEIGHT) withMenuOptions:tabs withFont:nil withTextColor:nil withDelegate:self];
	
	scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NAVBARHEIGHT+SLIDERMENUHEIGHT,VIEWWIDTH,VIEWHEIGHT-NAVBARHEIGHT-SLIDERMENUHEIGHT-STATUSBARHEIGHT)];		// Scroll view takes up rest of screen except 30 for status bar
	pdfview = [[PDFView alloc] initWithFrame:CGRectMake(0, 0, VIEWWIDTH, VIEWHEIGHT) withPdfName:pdfName withPageChangeDelegate:self];	// Create one large PDF
	pdfview.backgroundColor = [UIColor whiteColor];
	
	statusbar = [[PageStatusBar alloc] initWithFrame:CGRectMake(0,VIEWHEIGHT-STATUSBARHEIGHT,VIEWWIDTH,STATUSBARHEIGHT) withTotalPages:0 withDelegate:pdfview];
	
	[self.view addSubview:navbar];				// Nav bar at top
	[self.view addSubview:ssv];					// Sliding menu
	[self.view addSubview:statusbar];			// Status bar
	[self.view addSubview:scrollview];			// The scroll view
	[scrollview addSubview:pdfview];			// On top of scroll view is pdf
	[scrollview setScrollEnabled:YES];			// Tell it to allow scrolling
	[scrollview setContentSize:pdfview.bounds.size];		// Set the content size so it will scroll
}

// When user clicks Done button, control comes here. Dismiss the modal view.
-(IBAction)Done:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
	[delegate helpClosed];
}

-(void)wasTapped:(int)ID {
	pdfInfo* info = [pdfData objectAtIndex:ID];
	[pdfview changePdf:info.pdfName];
	[statusbar resetWithTotalPages:0];			// 0 indicates get it from delegate (pdfview)
	[scrollview setContentSize:pdfview.bounds.size];
	[scrollview setContentOffset:CGPointMake(0, 0) animated:NO];
}

-(void)PageChange {
	[scrollview setContentOffset:CGPointMake(0,0) animated:NO];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
	[scrollview release];
	[navbar release];
	[pdfview release];
	[navTitle release];
}


@end

///******
// *
// * The PDFView class is a subclass of UIView, and is designed to display a full PDF document.
// *
// * The PDF document must be formatted as one large page and located within the bundle.
// *
// * Specify the document name in the initWithFrame:withPdfName: method.
// *   Note that the document name must be a CFStringRef. Create this using CFSTR (e.g. withPdfName:CFSTR("MyFile.pdf"))
// *
// */
//@implementation PDFView
//
//@synthesize pdfDoc;
//
//- (id)initWithFrame:(CGRect)frame withPdfName:(CFStringRef)name {
//    self = [super initWithFrame:frame];
//    if (self) {
//		CFURLRef pdfURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), name, NULL, NULL);
//		pdfDoc = CGPDFDocumentCreateWithURL((CFURLRef)pdfURL);
//		CFRelease(pdfURL);
//    }
//    return self;
//}
//
//- (void)drawRect:(CGRect)rect {
//	if (pdfDoc == nil) return;
//    CGContextRef context = UIGraphicsGetCurrentContext();
//	// PDF page drawing expects a Lower-Left coordinate system, so we flip the coordinate system
//	// before we start drawing.
//	CGContextTranslateCTM(context, 0.0, self.bounds.size.height);
//	CGContextScaleCTM(context, 1.0, -1.0);
//	
//	// Grab the first PDF page
//	CGPDFPageRef page = CGPDFDocumentGetPage(pdfDoc, 1);
//	// We're about to modify the context CTM to draw the PDF page where we want it, so save the graphics state in case we want to do more drawing
//	CGContextSaveGState(context);
//	// CGPDFPageGetDrawingTransform provides an easy way to get the transform for a PDF page. It will scale down to fit, including any
//	// base rotations necessary to display the PDF page correctly. 
//	CGAffineTransform pdfTransform = CGPDFPageGetDrawingTransform(page, kCGPDFCropBox, self.bounds, 0, true);
//	// And apply the transform.
//	CGContextConcatCTM(context, pdfTransform);
//	// Finally, we draw the page and restore the graphics state for further manipulations!
//	CGContextDrawPDFPage(context, page);
//	CGContextRestoreGState(context);
//}
//
//
//- (void)dealloc {
//    [super dealloc];
//}
//
//
//@end
