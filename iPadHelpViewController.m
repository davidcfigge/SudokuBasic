//
//  HelpViewController.m
//  Class Timer
//
//  Created by David Figge on 1/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "iPadHelpViewController.h"



@implementation iPadHelpViewController

@synthesize scrollview, navbar, pdfview, pdfName, navTitle;

#define VIEWWIDTH 540
#define VIEWHEIGHT 620
#define NAVBARHEIGHT 44
#define SLIDERMENUHEIGHT 44
#define STATUSBARHEIGHT 30

-(id)initWithTitle:(NSString*)title withDelegate:(id<iPadHelpProtocol>)del{
	self = [super init];
	if (!self) return self;
	delegate = del;
	pdfData  = [NSArray arrayWithObjects:
				[[pdfInfo alloc] initWithName:CFSTR("iPadAppHelp.pdf") position:0 ],
				[[pdfInfo alloc] initWithName:CFSTR("iPadRules.pdf") position:0 ],
				[[pdfInfo alloc] initWithName:CFSTR("iPadLesson1.pdf") position:0 ],
				[[pdfInfo alloc] initWithName:CFSTR("iPadLesson2.pdf") position:0 ],
				[[pdfInfo alloc] initWithName:CFSTR("iPadLesson3.pdf") position:0 ],
				[[pdfInfo alloc] initWithName:CFSTR("iPadLesson4.pdf") position:0 ],
				[[pdfInfo alloc] initWithName:CFSTR("iPadLesson5.pdf") position:0 ],
				[[pdfInfo alloc] initWithName:CFSTR("iPadLesson6.pdf") position:0 ],
				[[pdfInfo alloc] initWithName:CFSTR("iPadLesson7.pdf") position:0 ],
				[[pdfInfo alloc] initWithName:CFSTR("iPadOrigins.pdf") position:0 ],
				[[pdfInfo alloc] initWithName:CFSTR("iPadFAQ.pdf") position:0 ],
				[[pdfInfo alloc] initWithName:CFSTR("iPadAbout.pdf") position:0 ],
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
	
	scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0,NAVBARHEIGHT+SLIDERMENUHEIGHT,VIEWWIDTH,VIEWHEIGHT-NAVBARHEIGHT-SLIDERMENUHEIGHT-STATUSBARHEIGHT)];		// Scroll view takes up rest of screen
	pdfview = [[PDFView alloc] initWithFrame:CGRectMake(0, 0, VIEWWIDTH,VIEWHEIGHT) withPdfName:pdfName withPageChangeDelegate:self];	// Create PDF View
	pdfview.backgroundColor = [UIColor whiteColor];
	
	statusbar = [[PageStatusBar alloc] initWithFrame:CGRectMake(0, VIEWHEIGHT-STATUSBARHEIGHT, VIEWWIDTH, STATUSBARHEIGHT) withTotalPages:0 withDelegate:pdfview];
	
	[self.view addSubview:navbar];				// Nav bar at top
	[self.view addSubview:ssv];					// The slider menu/tab
	[self.view addSubview:statusbar];			// The status bar
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

// Called when user selects a different tab to view
-(void)wasTapped:(int)ID {
	pdfInfo* info = [pdfData objectAtIndex:ID];
	[pdfview changePdf:info.pdfName];
	[statusbar resetWithTotalPages:0];			// Zero indicates it should get the pages from the delegate (pdfview)
	[scrollview setContentSize:pdfview.bounds.size];
	[scrollview setContentOffset:CGPointMake(0, 0) animated:NO];
}

-(void)PageChange {
	[scrollview setContentOffset:CGPointMake(0,0) animated:NO];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation { return YES; }

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
