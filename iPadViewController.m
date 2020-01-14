    //
//  iPadViewController.m
//  Sudoku Basic
//
//  Created by David Figge on 11/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "iPadViewController.h"
#import "UIManager.h"


@implementation iPadViewController

@synthesize leftRailView, rightRailView, board, controlPad, backgroundView, busyView, settings, config, gameManager;

#define VOSCREENWIDTH 768							// Width of screen in vertical orientation
#define VOSCREENHEIGHT 1024							// Height of screen in vertical orientation
#define HOSCREENWIDTH 1024							// Width of screen in horizontal orientation
#define HOSCREENHEIGHT 768							// Height of screen in horizontal orientation
#define VOBOARDWIDTH 736							// Width of (playing) board in vertical orientation
#define VOBOARDHEIGHT 736							// Height of (playing) board in vertical orientation
#define VOBOARDXLOC 16								// 'Home' x coord of board (vertical orientation)
#define VOBOARDYLOC 16								// 'Home' y coord of board (vertical orientation)
#define PADBOARDSEPARATION 0						// Distance between board and control pad
#define VOCONTROLPADHEIGHT 256						// Height of control pad (vertical orientation)
#define VOCONTROLPADWIDTH 736						// Width of control pad (vertical orientation)
#define HOCONTROLPADHEIGHT VOCONTROLPADWIDTH		// Height of control pad (horizontal orientation)
#define HOCONTROLPADWIDTH VOCONTROLPADHEIGHT		// Width of control pad (horizontal orientation)
#define CELLWIDTH 74								// Width of cell
#define CELLHEIGHT 74								// Height of cell

#define PADCELLWIDTH CELLWIDTH						// Width of cell on control pad
#define PADCELLHEIGHT CELLHEIGHT					// Height of cell on control pad
#define PADCELLLINEWID 3							// Width of line separating cells on control pad
#define VOPADSETTINGSBTNX 9							// X coord of settings button (vertical orientation)
#define VOPADSETTINGSBTNY 214						// Y coord of settings button (vertical orientation)
#define VOPADSETTINGSBTNWID 149						// Width of settings button (vertical orientation)
#define VOPADSETTINGSBTNHT 33						// Height of settings button (vertical orientation)
#define VOPADNEWBTNX 202							// X coord of new button (vertical orientation)
#define VOPADNEWBTNY 214							// Y coord of new button (vertical orientation)
#define VOPADNEWBTNWID 148							// Width of new button (vertical orientation)
#define VOPADNEWBTNHT 33							// Height of new button (vertical orientation)
#define VOPADPAUSEBTNX 395							// X coord of pause button (vertical orientation)
#define VOPADPAUSEBTNY 214							// Y coord of pause button (vertical orientation)
#define VOPADPAUSEBTNWID 148						// Width of pause button (vertical orientation)
#define VOPADPAUSEBTNHT 33							// Height of pause button (vertical orientation)
#define VOPADTIMERLBLX 578							// X coord of timer label (vertical orientation)
#define VOPADTIMERLBLY 214							// Y coord of timer label (vertical orientation)
#define VOPADTIMERLBLWID 149						// Width of timer label (vertical orientation)
#define VOPADTIMERLBLHT 33							// Height of timer label (vertical orientation)
#define VOFILTERBTNX 202							// X coord of filter ('SOLO') button (vertical orientation)
#define VOFILTERBTNY 9								// Y coord of filter ('SOLO') button (vertical orientation)
#define VOFILTERBTNWID 148							// Width of filter ('SOLO') button (vertical orientation)
#define VOFILTERBTNHT 34							// Height of filter ('SOLO') button (vertical orientation)
#define VOAUTOBTNX 395								// X coord of auto button (vertical orientation)
#define VOAUTOBTNY 9								// Y coord of auto button (vertical orientation)
#define VOAUTOBTNWID 150								// Width of auto button (vertical orientation)
#define VOAUTOBTNHT 34								// Height of auto button (vertical orientation)
#define VOSOUNDBTNX 20								// X coord of Sound icon
#define VOSOUNDBTNY VOFILTERBTNY								// Y coord of Sound icon
#define VOSOUNDBTNWID 30							// Width of sound icon
#define VOSOUNDBTNHT 30								// Height of sound icon

#define HOPADSETTINGSBTNX 9							// X coord of settings button (horizontal orientation)
#define HOPADSETTINGSBTNY 9							// Y coord of settings button (horizontal orientation)
#define HOPADSETTINGSBTNWID 33						// Width of settings button (horizontal orientation)
#define HOPADSETTINGSBTNHT 149						// Height of settings button (horizontal orientation)
#define HOPADNEWBTNX 9								// X coord of new button (horizontal orientation)
#define HOPADNEWBTNY 202							// Y coord of new button (horizontal orientation)
#define HOPADNEWBTNWID 33							// Width of new button (horizontal orientation)
#define HOPADNEWBTNHT 149							// Height of new button (horizontal orientation)
#define HOPADPAUSEBTNX 9							// X coord of pause button (horizontal orientation)
#define HOPADPAUSEBTNY 395							// Y coord of pause button (horizontal orientation)
#define HOPADPAUSEBTNWID 33							// Width of pause button (horizontal orientation)
#define HOPADPAUSEBTNHT 149							// Height of pause button (horizontal orientation)
#define HOPADTIMERLBLX 9							// X coord of timer label (horizontal orientation)
#define HOPADTIMERLBLY 578							// Y coord of timer label (horizontal orientation)
#define HOPADTIMERLBLWID 33							// Width of timer label (horizontal orientation)
#define HOPADTIMERLBLHT 149							// Height of timer label (horizontal orientation)
#define HOFILTERBTNX 214							// X coord of filter ('SOLO') button (horizontal orientation)
#define HOFILTERBTNY 202							// Y coord of filter ('SOLO') button (horizontal orientation)
#define HOFILTERBTNWID 34							// Width of filter ('SOLO') button (horizontal orientation)
#define HOFILTERBTNHT 149							// Height of filter ('SOLO') button (horizontal orientation)
#define HOAUTOBTNX 214								// X coord of auto button (horizontal orientation)
#define HOAUTOBTNY 395								// Y coord of auto button (horizontal orientation)
#define HOAUTOBTNWID 34								// Width of auto button (horizontal orientation)
#define HOAUTOBTNHT 150								// Height of auto button (horizontal orientation)
#define HOSOUNDBTNX HOFILTERBTNX					// X coord of Sound icon
#define HOSOUNDBTNY HOCONTROLPADHEIGHT - 50			// Y coord of Sound icon
#define HOSOUNDBTNWID 30							// Width of sound icon
#define HOSOUNDBTNHT 30								// Height of sound icon

#define BOARDID 1									// ID of (playing) board
#define PADID 2										// ID of control pad

// Primary initializer. Takes parameter of main window 
- (id)initWithMainWindow:(UIWindow*)window {
    [super initWithNibName:nil bundle:nil];
    if (self) {
		mainWindow = window;						// Save window for future use
		isAnimatingPad = isAnimatingBoard = true;
		ippwc = nil;								// Indicator to orientation change routines that no menu/message box is displayed
		busyView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		busyView.hidesWhenStopped = YES;
		busyActive = false;							// Busy indicator not active
		[self setSettings];							// Set up the Settings variable
		[self setConfig];							// Set configuration information
		[self themeSetUp];							// Set up for current theme
    }
    return self;
}

-(void)sleep {										// App is going into background
	[gameManager sleep];
}

-(void)wake {										// App is waking up from background
	[gameManager wake];								// Tell game manager to wake up
}

// View Protocol Functions. These functions are specifically used by the UI manager

// Show the help screen
-(void)showHelp {
	iPadHelpViewController *hvc = [[iPadHelpViewController alloc] initWithTitle:@"Sudoku Help" withDelegate:self];
	hvc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	hvc.modalPresentationStyle = UIModalPresentationFormSheet;
	[self presentModalViewController:hvc animated:YES];	
}

-(void)helpClosed {
	[gameManager RestoreTimerState];
	[self setSettingsSelected:UNSELECTED];
}

-(void)setSoundSelected:(BOOL)state {
	soundButton.selected = state;
	[controlPad invalidateRect:soundButton.boundaries];
}

// Set the board to a specific location (no animation)
-(void)setBoard:(int)boardType toLocation:(int)HIDDENorSHOWN {
	UIView* brd = (boardType == GAMEBOARD ? (UIView*)[self board] : (UIView*)[self controlPad]); // Is it board or pad?
	brd.frame = [self getLocation:boardType withShown:HIDDENorSHOWN];	// Move to appropriate location
}

// Move the board to the specified location (with animation)
-(void)moveBoard:(int)boardType toLocation:(int)HIDDENorSHOWN withTime:(float)sec {
	UIView* brd = (boardType == GAMEBOARD ? (UIView*)[self board] : (UIView*)[self controlPad]);	// Is it board or pad?
	CGRect loc = [self getLocation:boardType withShown:HIDDENorSHOWN];	// Get the destination
	if (boardType == GAMEBOARD) {
		isAnimatingBoard = true;
		[NSTimer scheduledTimerWithTimeInterval:sec target:self selector:@selector(doneAnimatingBoard:) userInfo:nil repeats:NO];
	}
	else {
		isAnimatingPad = true;
		[NSTimer scheduledTimerWithTimeInterval:sec target:self selector:@selector(doneAnimatingPad:) userInfo:nil repeats:NO];
	}
	[UIView beginAnimations:nil context:nil];						// Start animating change in settings
	[UIView setAnimationDuration:sec];								// Specify number of seconds
	[brd setFrame:loc];												// Move to here
	[UIView commitAnimations];										// Start animation
}

// Show a 'busy' indicator if specified number of seconds go by without request to turn it off.
-(void)showBusy {
	[self centerBusyView];
	if ([busyView isAnimating] == NO) 
		[busyView startAnimating];
}

-(void)cancelBusy {
	if ([busyView isAnimating] == YES)
		[busyView stopAnimating];	
}

-(void)centerBusyView {
	CGRect boardRect = [self getLocation:GAMEBOARD withShown:SHOWN];
	busyView.center = CGPointMake(boardRect.origin.x + boardRect.size.width/2, boardRect.origin.y + boardRect.size.height/2);
}

-(void)setPausedCaption:(char*)caption {	// Set the caption on the paused button
	pauseButton.text = caption;					// Set the caption
	[controlPad invalidateRect:pauseButton.boundaries];	// Redraw the button text
}

-(void)setAutoCaption:(char*)caption {		// Set the caption on the Auto button
	autoButton.text = caption;					// Set the caption
	[controlPad invalidateRect:autoButton.boundaries];  // Redraw the text
}

-(void)selectPaused:(int)style {				// Indicate if the Paused button is on or off (ISSELECTED, NOTSELECTED)
	pauseButton.selected = style;					// Set the style
	[controlPad invalidateRect:pauseButton.boundaries];  // Redraw the button text
}

-(void)setNewSelected:(int)state {			// Turn on/off the NEW highlight
	newButton.selected = state;					// Set the highlight
	[controlPad invalidateRect:newButton.boundaries];  // Redraw the button text
}

-(void)setSettingsSelected:(int)state {			// Set the settings (help) button to ON or OFF
	settingsButton.selected = state;
	[controlPad invalidateRect:settingsButton.boundaries];
}

// Force the auto button to redraw with appropriate mode
-(void)redrawAutoButton {
	autoButton.selected = settings.pencilMode;
	[controlPad invalidateRect:autoButton.boundaries];
}

// Force the filter button to redraw with appropriate mode
-(void)redrawFilterButton {
	filterButton.selected = (settings.filterMode ? SELECTED : NOTSELECTED);
	[controlPad invalidateRect:filterButton.boundaries];
}

// Redraw the entire board
-(void)redrawBoard {
	[board invalidateRect:board.frame];
}

// Redraw the entire control pad
-(void)redrawPad {
	[controlPad invalidateRect:controlPad.frame];
}

// Display a message box in the middle of the window
// Message box has text and an OK button
-(void)displayMessageBox:(NSString*)title withMessage:(NSString*)message {
	[self displayMessageBox:title withMessage:message withYesNo:NO];
}

-(void)displayMessageBox:(NSString *)title withMessage:(NSString *)message withYesNo:(BOOL)YesNo {
	// Create popup window
	ippwc = [[iPadPopupWindowController alloc] initWithTitle:title withFrame:[config screenRect] withPCDelegate:self withID:MSGBOXID];
	// Add a label for the message
	UILabel* textLabel = [ippwc addLabelwithFrame:CGRectMake(0, 80, 0, 240) withText:message];
	textLabel.numberOfLines = 8;		// Max lines
	textLabel.font = [UIFont fontWithName:@"Helvetica" size:24];	// Set the text font and size
	
	if (YesNo == NO) {
		textLabel = [ippwc addLabelwithFrame:CGRectMake(0,330,0,40) withText:@"OK"];		// Add an OK button
		textLabel.backgroundColor = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:1];		// Make the OK button be white on black
		textLabel.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
	}
	else {
		textLabel = [ippwc addLabelwithFrame:CGRectMake(160, 330, 110, 40) withText:@"No"];
		textLabel.backgroundColor = [UIColor colorWithRed:1 green:.2 blue:.2 alpha:1];		// Make the NO button be white on red
		textLabel.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
		textLabel = [ippwc addLabelwithFrame:CGRectMake(30,330,115,40) withText:@"Yes"];
		textLabel.backgroundColor = [UIColor colorWithRed:.2 green:.5 blue:.2 alpha:1];		// Make the YES button be white on green
		textLabel.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
	}
	[ippwc display:self.view fromController:self];					// Display the message box
}

// Display the NEW menu
-(void)showNewMenu {
	// Create the popup menu with the title NEW GAME
	ippwc = [[iPadPopupWindowController alloc] initWithTitle:@"New Game" withFrame:[config screenRect] withPCDelegate:self withID:NEWMENUID];
	UILabel* lbl;
	
	// For each option, create a label object, making a lighter background
	lbl = [ippwc addLabelwithFrame:CGRectMake(0, 80, 0, 40) withText:@"Easiest"];
	lbl.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:.2];
	lbl = [ippwc addLabelwithFrame:CGRectMake(0, 132, 0, 40) withText:@"Easier"];
	lbl.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:.2];
	lbl = [ippwc addLabelwithFrame:CGRectMake(0, 184, 0, 40) withText:@"Normal"];
	lbl.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:.2];
	lbl = [ippwc addLabelwithFrame:CGRectMake(0, 236, 0, 40) withText:@"Harder"];
	lbl.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:.2];
	lbl = [ippwc addLabelwithFrame:CGRectMake(0, 288, 0, 40) withText:@"Hardest"];
	lbl.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:.2];
	
	// Add a cancel button in red
	UILabel* cancel = [ippwc addLabelwithFrame:CGRectMake(0, 330, 0, 40) withText:@"Cancel"];
	cancel.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:.5];
	cancel.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];

	// Display the menu
	[ippwc display:self.view fromController:self];
}

// When the user selects an item from the popup menu, it comes here
-(void)PopupController:(UIViewController*)controller didSelectItem:(int)item withID:(int)msgID {
	switch (msgID) {		// Which menu was displaying?
		case NEWMENUID:			// If new menu
			[gameManager newGameSelected:item];	// Pass on request to game manager
			break;
		case MSGBOXID:
			[gameManager msgBoxSelected:item];
			break;
	}
	[ippwc release];
	ippwc = nil;
	[gameManager popupDismissed];
}

// If the user cancels the popup menu (tapping outside the menu), it comes here
-(void)PopupControllerSelectionCanceled:(UIViewController*)controller withID:(int)msgID {
	switch (msgID) {		// Which menu was displaying
		case NEWMENUID:			// If new menu
			[gameManager newGameCanceled];	// Pass on cancel to game manager
			break;
	}
	[ippwc release];
	ippwc = nil;
	[gameManager popupDismissed];
}

// Update the timer display with a new time value
-(void)updateTimer:(char*)string {
	// The vertical orientation doesn't have room for the text "Elapsed:" like the horizontal does. Deal with that.
	if (config.orientation == LANDSCAPELEFT || config.orientation == LANDSCAPERIGHT)
		timeButton.text = string+9;			// Display time only (ASSUMES ELAPSED: IN FRONT!)
	else
		timeButton.text = string;			// Display entire string
	[controlPad invalidateRect:timeButton.boundaries];		// Cause the window to be redrawn
}

// Set a specific cell to highlighted or not
-(void)setCtlPadCmdSelected:(int)cellNbr toVal:(int)selected {
	Cell* cb = [ctlPadCells objectAtIndex:cellNbr];	// Get cell in question
	if (cb.selected == selected) return;		// If nothing changed, we're done
	cb.selected = selected;						// Change the setting
	[controlPad invalidateRect:cb.frame];		// Redraw the cell
}

-(void)resetBoard {							// Do what's needed to make the board redraw even if off the screen
	if (board != nil) {
		[board release];					// Remove current board
		[board removeFromSuperview];
	}
	// Now create a new one
	board = [[DCFImageView alloc] initWithImageName:@"GridOldPaper.png" withDelegate:self withID:BOARDID];
	board.frame = [config getLocation:BOARDHIDDEN];
	[self.view addSubview:board];
}
	
// End of View Protocol Functions

// DCFImgView protocol functions (delegate-based function request from board/pad)

// Draw up the contents of the board
-(void)draw:(int)ID withContext:(CGContextRef)context {
	// Start by setting the context for standard text
	CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0));
	
	// Now pass on request based on ID of item
	if (ID == BOARDID) {
		[gameManager drawCellsContents:context];		// Defer cells to game manager
	}
	if (ID == PADID) {									// For pad...
		for (Cell* c in ctlPadCells) {					// Draw each cell (cmd buttons)
			[c draw:context];
		}
		for (CmdButton* t in ctlPadTouchPoints)			// Now it non-cell buttons/labels
			[t draw:context];
	}
}

// User double tapped on board
-(void)userDblTap:(int)ID withLocation:(CGPoint)pt {
	int sqID = NOHIT;									// Default to no hit
	switch (ID) {
		case BOARDID:									// If board
			[gameManager dblTappedCellAtPoint:pt];		// Defer to game manager
			break;
		case PADID:										// If control pad
			for (id<Touchable> t in ctlPadTouchPoints) {	// Look at all touchable elements
				sqID = [t wasHit:pt];						// If this was it
				if (sqID != NOHIT) break;					// if this cell was hit break out of loop;
			}
			if (sqID == NOHIT) return;						// If none hit we're done
			if (sqID < 18) [gameManager dblTappedCtlPadCell:sqID]; // If MARK or PENCIL MARK let game manager handle it
			break;										// Nothing else supports double-taps
	}
}

// User single-tapped on board
-(void)userTap:(int)ID withLocation:(CGPoint)pt {
	int sqID = NOHIT;									// Default to no hit
	switch (ID) {
		case BOARDID:									// If game board
			[gameManager tappedCellAtPoint:pt];				// defer to game manager to handle it
			break;
		case PADID:										// If control pad
			for (id<Touchable> t in ctlPadTouchPoints) {		// Look at all touchable objects
				sqID = [t wasHit:pt];						// Was this cell hit?
				if (sqID != NOHIT) break;					// Yes, then break out of loop
			}
			if (sqID == NOHIT) return;					// If nothing hit, leave
			if (sqID < 18) [gameManager tappedCtlPadCell:sqID];  // If number or pencil mark, let game manager handle it
			if (sqID == IDPADBTNNEW) return [gameManager tappedNew];		// Handle each button by callling game manager function for it
			if (sqID == IDPADBTNSETTINGS) return [gameManager tappedSettings];
			if (sqID == IDPADBTNPAUSE) return [gameManager tappedPause];
			if (sqID == IDPADBTNAUTO) return [gameManager tappedAuto];
			if (sqID == IDPADBTNFILTER) return [gameManager tappedFilter];
			if (sqID == IDPADSOUNDICON) return [gameManager tappedSound];
			break;
	}
}


// End of DCFImgView protocol functions

// Return the rectangle for the board/pad when hidden/shown
-(CGRect)getLocation:(int)boardType withShown:(int)HiddenOrShown {
	int bs;
	if (boardType == GAMEBOARD) bs = (HiddenOrShown==SHOWN ? BOARDSHOWN : BOARDHIDDEN);	// Board settings
	else bs = (HiddenOrShown == SHOWN ? PADSHOWN : PADHIDDEN);		// Pad settings
	return [config getLocation:bs];									// Return location (given orientation)
}

// This function is called when user has changed orientation. This one indicates leaving an orientation for another
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	config.orientation = toInterfaceOrientation;			// Orientation we're going to
	leftRailView.hidden = YES;								// Hide the rail images
	rightRailView.hidden = YES;
	board.hidden = YES;										// Hide the board
	controlPad.hidden = YES;								// Hide the control panel
}

// This function is called when the user has changed orientation. This one indicates arriving at new orientation
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	switch (config.orientation) {
		case PORTRAIT:			// Portrait and upside down both have vertical rails and horizontal control pad
		case UPSIDEDOWN:
			[leftRailView setImage:0];								// Use the vertical image of the rails
			[leftRailView newFrame:CGRectMake(238, 0, 37, 1024) ];
			[rightRailView setImage:0];
			[rightRailView newFrame:CGRectMake(494, 0, 37, 1024)];
			[self setUpCtlPad];										// Set up the control pad for this orientation
			
			[controlPad setImage:0];								// Use the horizontal version of the pad images
			break;
		case LANDSCAPELEFT:		// Landscape orientations both have horizontal rails and vertical control pad
		case LANDSCAPERIGHT:
			[leftRailView setImage:1];								// Use horizontal rails
			[leftRailView newFrame:CGRectMake(0, 238, 1024, 37)];
			[rightRailView setImage:1];
			[rightRailView newFrame:CGRectMake(0, 494, 1024, 37)];
			[self setUpCtlPad];										// Set up the control pad for this orientation
			[controlPad setImage:1];								// Use the vertical version of the pad images
			break;
	}
	if (isAnimatingBoard || gameManager.isPaused) {
		[board newFrame:[config getLocation:BOARDHIDDEN]];
		if (!gameManager.isPaused && !gameManager.isGenerating) {
			[self moveBoard:GAMEBOARD toLocation:SHOWN withTime:3];
		}
	}
	else {
		[board newFrame:[config getLocation:BOARDSHOWN]];
	}
	if (isAnimatingPad) {
		[controlPad newFrame:[config getLocation:PADHIDDEN]];
		[self moveBoard:CTRLPAD toLocation:SHOWN withTime:2];
	}
	else {
		[controlPad newFrame:[config getLocation:PADSHOWN]];
	}
	if (ippwc != nil)
		[ippwc reCenterWindow:[config screenRect]];
	leftRailView.hidden = NO;		// Turn on rails
	rightRailView.hidden = NO;
	board.hidden = NO;				// Turn on board
	controlPad.hidden = NO;			// Turn on control pad
	[self redrawPad];				// Redraw the pad (as orientation has changed)
	[self redrawAutoButton];		// Redraw auto and filter (SOLO) buttons
	[self redrawFilterButton];
	[gameManager refreshCtlPad];	// Make pad reflect currently selected cell
	[self setSoundSelected:[SoundEffect SoundState]];
}

// Cause a specific area of the board to be redrawn
-(void)invalidateBoardRect:(CGRect)rect {
	[board invalidateRect:rect];
}

// Initialize the 'settings' variable appropriately
-(void)setSettings {
	self.settings = [Settings settings];	// Get the 'settings' address from the Settings object
}

// Set up the control pad's various buttons and such for the current orientation
-(void)setUpCtlPad {
	[self setPadForOrientation];						// Set up for everything except cells (which is done here)
	if (ctlPadCells == nil) [ctlPadCells release];		// Release any existing control pad cells array
	ctlPadCells = [[NSMutableArray alloc] initWithCapacity:18];		// Create new array for control pad cells
	CGRect cellFrame;									// various working variables
	int xcoord;
	int ycoord;
	int cellnum = 0;
	switch (config.orientation) {						// Which orientation are we?
		case UPSIDEDOWN:								// Vertically oriented...
		case PORTRAIT:
			ycoord = config.padBorder.y + config.padGridLineWidth+2;				// start y coordinate of top row of cells
			for (int y = 0; y < 2; y++) {										// Rows in control pad
				xcoord = config.padBorder.x + config.padGridLineWidth+2;			// start of first square this row
				for (int x = 0; x < NUMBERSPERROW; x++) {						// For each cell in this row
					cellFrame = CGRectMake(xcoord, ycoord, config.padGridBtnSize.width, config.padGridBtnSize.height);	// Calculate the frame
					Cell* c = [[Cell alloc] initWithFrame:cellFrame square:cellnum];	// Create a new cell with that frame and cell number
					if (y == 0) c.value = x+1;									// If value, set the value
					else [c setPencilMark:x+1 toValue:MARK_ON];					// Otherwise set the pencil mark on
					c.cellMode = CELLCMD;										// Mark that this is a button-based cell
					[ctlPadCells addObject:c];									// Add it to the list of cells
					[ctlPadTouchPoints addObject:c];							// Also add it to the list of touch points so it can be touched
					[c release];
					cellnum++;													// Next cell number
					xcoord += config.cellSize.width + config.padGridLineWidth;		// Move to start of next cell
				}
				ycoord += config.padGridBtnSize.height + config.padGridLineWidth;	// Move to next row
			}
			break;
		case LANDSCAPELEFT:
		case LANDSCAPERIGHT:							// Horizontally oriented
			for (int x = 0; x < 2; x++) {										// Columns in control pad
				xcoord = [config getLocation:PADSHOWN].size.width - config.padBorder.y - config.padGridLineWidth;
				//				xcoord = [config getLocation:PADSHOWN].size.width - config.padGridLineWidth;	// Right edge of last column
				xcoord -= (1+x) * (config.padGridBtnSize.width + config.padGridLineWidth);		// xcoord of upper left corner of column
				xcoord += 2;													// Moving this value makes it work right (fudge factor)
				ycoord = config.padBorder.x + config.padGridLineWidth+2;		// ycoord of upper left corner of column
				for (int y = 0; y < NUMBERSPERROW; y++) {						// For each row in column
					cellFrame = CGRectMake(xcoord, ycoord, config.padGridBtnSize.width, config.padGridBtnSize.height);	// calculate the frame
					Cell* c = [[Cell alloc] initWithFrame:cellFrame square:cellnum];			// Create cell with that frame and number
					if (x == 0) c.value = y+1;								// If value, set the value
					else [c setPencilMark:y+1 toValue:MARK_ON];				// Otherwise set the pencil mark
					c.cellMode = CELLCMD;									// Tell it this is used as a command
					[ctlPadCells addObject:c];								// Add it to the list of cells
					[ctlPadTouchPoints addObject:c];						// Also add it to the list of touch points so it can be touched
					[c release];
					cellnum++;												// Next cell number
					ycoord += config.cellSize.height + config.gridLineWidth; // Next row down
				}
			}
		break;
	}
}

// This function's job is to set up the Config object with the appropriate values for the board and control pad
// This structure is read in by the Config object and used throughout the game
-(void)setConfig {
	struct configInfo info = {
		IPADDEVICE,
		CGRectMake(VOBOARDXLOC, VOBOARDYLOC, VOBOARDWIDTH, VOBOARDHEIGHT),								// Board shown portrait
		CGRectMake(VOBOARDXLOC, -VOBOARDHEIGHT, VOBOARDWIDTH, VOBOARDHEIGHT),							// Board hidden portrait
		CGRectMake(VOBOARDXLOC, VOBOARDYLOC+VOCONTROLPADHEIGHT+PADBOARDSEPARATION, VOBOARDWIDTH, VOBOARDHEIGHT),		// Board shown upside down
		CGRectMake(VOBOARDXLOC, VOSCREENHEIGHT, VOBOARDWIDTH, VOBOARDHEIGHT),											// Board hidden upside down
		CGRectMake(HOSCREENWIDTH-VOBOARDYLOC-VOBOARDWIDTH, VOBOARDXLOC, VOBOARDHEIGHT, VOBOARDWIDTH),					// Board shown landscape left
		CGRectMake(HOSCREENWIDTH, VOBOARDXLOC, VOBOARDWIDTH, VOBOARDHEIGHT),											// Board hidden landscape left
		CGRectMake(VOBOARDYLOC, VOBOARDXLOC, VOBOARDWIDTH, VOBOARDHEIGHT),												// Board shown landscape right
		CGRectMake(-VOBOARDWIDTH, VOBOARDXLOC, VOBOARDWIDTH, VOBOARDHEIGHT),											// Board hidden landscape right
		CGRectMake(VOBOARDXLOC, VOBOARDYLOC+VOBOARDHEIGHT+PADBOARDSEPARATION, VOCONTROLPADWIDTH, VOCONTROLPADHEIGHT),	// Pad shown portrait
		CGRectMake(VOBOARDXLOC, VOSCREENHEIGHT, VOCONTROLPADWIDTH, VOCONTROLPADHEIGHT),									// Pad hidden portrait
		CGRectMake(VOBOARDXLOC, VOBOARDYLOC, VOCONTROLPADWIDTH, VOCONTROLPADHEIGHT),					// Pad shown upside down
		CGRectMake(VOBOARDXLOC, -VOCONTROLPADHEIGHT, VOCONTROLPADWIDTH, VOCONTROLPADWIDTH),				// Pad hidden upside down
		CGRectMake(HOSCREENWIDTH-VOBOARDYLOC-VOBOARDWIDTH-PADBOARDSEPARATION-HOCONTROLPADWIDTH, VOBOARDXLOC, HOCONTROLPADWIDTH, HOCONTROLPADHEIGHT), // Pad shown landscape left
		CGRectMake(-HOCONTROLPADWIDTH, VOBOARDXLOC, HOCONTROLPADWIDTH, HOCONTROLPADHEIGHT),				// Pad hidden landscape left
		CGRectMake(VOBOARDYLOC+VOBOARDWIDTH+PADBOARDSEPARATION, VOBOARDXLOC, HOCONTROLPADWIDTH, HOCONTROLPADHEIGHT), // Pad shown landscape right
		CGRectMake(HOSCREENWIDTH, VOBOARDXLOC, HOCONTROLPADWIDTH, HOCONTROLPADHEIGHT),					// Pad hidden landscape right
		CGSizeMake(CELLWIDTH, CELLHEIGHT), // cell size
		{	// Pencil mark offsets
			CGPointMake(10,15),CGPointMake(30,15),CGPointMake(50,15),
			CGPointMake(10,37),CGPointMake(30,37),CGPointMake(50,37),
			CGPointMake(10,59),CGPointMake(30,59),CGPointMake(50,59)
		},
		CGPointMake(22,47), // Value offset
		CGPointMake(20,20), // board Border (x = left, y = top)
		3,					// Grid line width
		CGPointMake(20, 50),	// Pad border
		PADCELLLINEWID,		// Pad grid line width
		CGSizeMake(PADCELLWIDTH, PADCELLHEIGHT),	// Pad grid button size
	};
		
	self.config = [Config config];						// Get the Config object (stored in config class variable)
	[config setConfiguration:&info];				// Use structure to set up values
	// Set up the names of the control pad buttons
	[config setPadBtnText:PADBTNFILTER text:"Solo"];	// Set up the various button texts
	[config setPadBtnText:PADBTNAUTO text:"Auto"];
	[config setPadBtnText:PADBTNSETTINGS text:"Help"];
	[config setPadBtnText:PADBTNNEW text:"New"];
	[config setPadBtnText:PADBTNPAUSE text:"Pause"];
	[config setPadBtnText:PADRECTTIMER text:"Elapsed: "];
	[config setPadBtnText:PADSOUNDICON text:nil];
}

// Reset the 'animating board' flag
-(void)doneAnimatingBoard:(NSTimer*)timer {
	isAnimatingBoard = false;
}

// Reset the 'animating pad' flag
-(void)doneAnimatingPad:(NSTimer*)timer {
	isAnimatingPad = false;
}

// This function is used to set the various control pad buttons and labels for the current configuration
-(void)setPadForOrientation {
	switch (config.orientation) {
		case PORTRAIT:
		case UPSIDEDOWN:
			[config setPadButtonRect:PADBTNFILTER frame:CGRectMake(VOFILTERBTNX, VOFILTERBTNY, VOFILTERBTNWID, VOFILTERBTNHT)];		// filter ('SOLO') button
			[config setPadButtonRect:PADBTNAUTO frame:CGRectMake(VOAUTOBTNX, VOAUTOBTNY, VOAUTOBTNWID, VOAUTOBTNHT)];				// Auto button
			[config setPadButtonRect:PADBTNSETTINGS frame:CGRectMake(VOPADSETTINGSBTNX, VOPADSETTINGSBTNY, VOPADSETTINGSBTNWID, VOPADSETTINGSBTNHT)]; // Settings button
			[config setPadButtonRect:PADBTNNEW frame:CGRectMake(VOPADNEWBTNX, VOPADNEWBTNY, VOPADNEWBTNWID, VOPADNEWBTNHT)];		// New button
			[config setPadButtonRect:PADBTNPAUSE frame:CGRectMake(VOPADPAUSEBTNX, VOPADPAUSEBTNY, VOPADPAUSEBTNWID, VOPADPAUSEBTNHT)];	// Pause button
			[config setPadButtonRect:PADRECTTIMER frame:CGRectMake(VOPADTIMERLBLX, VOPADTIMERLBLY, VOPADTIMERLBLWID, VOPADTIMERLBLHT)];	// Timer label
			[config setPadButtonRect:PADSOUNDICON frame:CGRectMake(VOSOUNDBTNX, VOSOUNDBTNY, VOSOUNDBTNWID, VOSOUNDBTNHT)];
			
			// Now Create an array of rectangles to use for hit testing
			
			if (ctlPadTouchPoints != nil) [ctlPadTouchPoints release];
			ctlPadTouchPoints = [[NSMutableArray alloc] initWithCapacity:23];
			pauseButton = [[CmdButton alloc] initWithRect:[config getPadButtonRect:PADBTNPAUSE] withID:IDPADBTNPAUSE withText:[config getPadBtnText:PADBTNPAUSE] aligned:TEXTALIGNCTR isVertical:NO isTouchable:YES fontType:FONTCMDSTRING];
			[ctlPadTouchPoints addObject:pauseButton];
			[pauseButton release];
			settingsButton = [[CmdButton alloc] initWithRect:[config getPadButtonRect:PADBTNSETTINGS] withID:IDPADBTNSETTINGS withText:[config getPadBtnText:PADBTNSETTINGS] aligned:TEXTALIGNCTR isVertical:NO isTouchable:YES fontType:FONTCMDSTRING];
			[ctlPadTouchPoints addObject:settingsButton];
			[settingsButton release];
			newButton = [[CmdButton alloc] initWithRect:[config getPadButtonRect:PADBTNNEW] withID:IDPADBTNNEW withText:[config getPadBtnText:PADBTNNEW] aligned:TEXTALIGNCTR isVertical:NO isTouchable:YES fontType:FONTCMDSTRING];
			[ctlPadTouchPoints addObject:newButton];
			[newButton release];
			timeButton = [[CmdButton alloc] initWithRect:[config getPadButtonRect:PADRECTTIMER] withID:IDPADRECTTIMER withText:"Elapsed: 0:00" aligned:TEXTALIGNRIGHT isVertical:NO isTouchable:NO fontType:FONTTIMESTRING];//[config getPadBtnText:PADRECTTIMER]];
			[ctlPadTouchPoints addObject:timeButton];
			[timeButton release];
			autoButton = [[CmdButton alloc] initWithRect:[config getPadButtonRect:PADBTNAUTO] withID:IDPADBTNAUTO withText:[config getPadBtnText:PADBTNAUTO] aligned:TEXTALIGNCTR isVertical:NO isTouchable:YES fontType:FONTOPTSTRING];
			[ctlPadTouchPoints addObject:autoButton];
			[autoButton release];
			filterButton = [[CmdButton alloc] initWithRect:[config getPadButtonRect:PADBTNFILTER] withID:IDPADBTNFILTER withText:[config getPadBtnText:PADBTNFILTER] aligned:TEXTALIGNCTR isVertical:NO isTouchable:YES fontType:FONTOPTSTRING];
			[ctlPadTouchPoints addObject:filterButton];
			[filterButton release];
			soundButton = [[CmdButton alloc] initWithRect:[config getPadButtonRect:PADSOUNDICON] withID:IDPADSOUNDICON withImageSel:@"SoundOn.png" withImageUnsel:@"SoundOff.png"];
			[ctlPadTouchPoints addObject:soundButton];
			[soundButton release];
			break;
		case LANDSCAPERIGHT:
		case LANDSCAPELEFT:
			[config setPadButtonRect:PADBTNFILTER frame:CGRectMake(HOFILTERBTNX, HOFILTERBTNY, HOFILTERBTNWID, HOFILTERBTNHT)];		// Filter ('SOLO') button
			[config setPadButtonRect:PADBTNAUTO frame:CGRectMake(HOAUTOBTNX, HOAUTOBTNY, HOAUTOBTNWID, HOAUTOBTNHT)];				// Auto button
			[config setPadButtonRect:PADBTNSETTINGS frame:CGRectMake(HOPADSETTINGSBTNX, HOPADSETTINGSBTNY, HOPADSETTINGSBTNWID, HOPADSETTINGSBTNHT)]; // Settings button
			[config setPadButtonRect:PADBTNNEW frame:CGRectMake(HOPADNEWBTNX, HOPADNEWBTNY, HOPADNEWBTNWID, HOPADNEWBTNHT)];		// New button
			[config setPadButtonRect:PADBTNPAUSE frame:CGRectMake(HOPADPAUSEBTNX, HOPADPAUSEBTNY, HOPADPAUSEBTNWID, HOPADPAUSEBTNHT)];	// Pause button
			[config setPadButtonRect:PADRECTTIMER frame:CGRectMake(HOPADTIMERLBLX, HOPADTIMERLBLY, HOPADTIMERLBLWID, HOPADTIMERLBLHT)];	// Timer label
			[config setPadButtonRect:PADSOUNDICON frame:CGRectMake(HOSOUNDBTNX, HOSOUNDBTNY, HOSOUNDBTNWID, HOSOUNDBTNHT)];
			
			// Create an array of rectangles to use for hit testing
			
			if (ctlPadTouchPoints != nil) [ctlPadTouchPoints release];
			ctlPadTouchPoints = [[NSMutableArray alloc] initWithCapacity:23];
			pauseButton = [[CmdButton alloc] initWithRect:[config getPadButtonRect:PADBTNPAUSE] withID:IDPADBTNPAUSE withText:[config getPadBtnText:PADBTNPAUSE] aligned:TEXTALIGNCTR isVertical:YES isTouchable:YES fontType:FONTCMDSTRING];
			[ctlPadTouchPoints addObject:pauseButton];
			[pauseButton release];
			settingsButton = [[CmdButton alloc] initWithRect:[config getPadButtonRect:PADBTNSETTINGS] withID:IDPADBTNSETTINGS withText:[config getPadBtnText:PADBTNSETTINGS] aligned:TEXTALIGNCTR isVertical:YES isTouchable:YES fontType:FONTCMDSTRING];
			[ctlPadTouchPoints addObject:settingsButton];
			[settingsButton release];
			newButton = [[CmdButton alloc] initWithRect:[config getPadButtonRect:PADBTNNEW] withID:IDPADBTNNEW withText:[config getPadBtnText:PADBTNNEW] aligned:TEXTALIGNCTR isVertical:YES isTouchable:YES fontType:FONTCMDSTRING];
			[ctlPadTouchPoints addObject:newButton];
			[newButton release];
			timeButton = [[CmdButton alloc] initWithRect:[config getPadButtonRect:PADRECTTIMER] withID:IDPADRECTTIMER withText:"0:00" aligned:TEXTALIGNRIGHT isVertical:YES isTouchable:NO fontType:FONTTIMESTRING];//[config getPadBtnText:PADRECTTIMER]];
			[ctlPadTouchPoints addObject:timeButton];
			[timeButton release];
			autoButton = [[CmdButton alloc] initWithRect:[config getPadButtonRect:PADBTNAUTO] withID:IDPADBTNAUTO withText:[config getPadBtnText:PADBTNAUTO] aligned:TEXTALIGNCTR isVertical:YES isTouchable:YES fontType:FONTOPTSTRING];
			[ctlPadTouchPoints addObject:autoButton];
			[autoButton release];
			filterButton = [[CmdButton alloc] initWithRect:[config getPadButtonRect:PADBTNFILTER] withID:IDPADBTNFILTER withText:[config getPadBtnText:PADBTNFILTER] aligned:TEXTALIGNCTR isVertical:YES isTouchable:YES fontType:FONTOPTSTRING];
			[ctlPadTouchPoints addObject:filterButton];
			[filterButton release];
			soundButton = [[CmdButton alloc] initWithRect:[config getPadButtonRect:PADSOUNDICON] withID:IDPADSOUNDICON withImageSel:@"SoundOn.png" withImageUnsel:@"SoundOff.png"];
			[ctlPadTouchPoints addObject:soundButton];
			[soundButton release];
			break;
		default:
			break;
	}
}

// This function is called when the view needs to be created (one time), and is used to set up the game view. Always starts in portrait (may switch to other orientation before display)
- (void)loadView {
	// Base view for all the subviews. Used as a general container for the other views
	UIView* baseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 768, 1024)];
	self.view = baseView;
	[baseView release];
	
	// First add the background image
	self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"carrib.png"]];
	[baseView addSubview:backgroundView];
	
	
	// Now the left rail
	leftRailView = [[DCFImageView alloc] initWithImageName:@"Rail.png" withDelegate:nil withID:0];
	[baseView addSubview:leftRailView];
	leftRailView.frame = CGRectMake(238, 0, 37, 1024);
	[leftRailView addImage:@"RailHoriz.png" atPlace:1];		// Second image for displaying in landscape
	
	// Now the right rail
	rightRailView = [[DCFImageView alloc] initWithImageName:@"Rail.png" withDelegate:nil withID:0];
	[baseView addSubview:rightRailView];
	rightRailView.frame = CGRectMake(494,0,37,1024);
	[rightRailView addImage:@"RailHoriz.png" atPlace:1];	// Second image for displaying in landscape
	
	// Now the board
	board = [[DCFImageView alloc] initWithImageName:@"GridOldPaper.png" withDelegate:self withID:BOARDID];
	board.frame = [config getLocation:BOARDHIDDEN];
	[baseView addSubview:board];
	
	// Now the controlpad
	controlPad = [[DCFImageView alloc] initWithImageName:@"ControlPad.png" withDelegate:self withID:PADID];
	controlPad.frame = [config getLocation:PADHIDDEN];
	[controlPad addImage:@"ControlPadVert.png" atPlace:1];	// Second image for displaying in landscape
	[baseView addSubview:controlPad];
	[self setUpCtlPad];										// Set up the control pad for this orientation
	//[Cell borders:true];	// Uncomment this to see the borders of the command buttons on the control pad
	
	// Insert the busy indicator
	[baseView addSubview:busyView];

	// Set up the UI Manager and the Game Manager
	UIManager* uim = [[UIManager alloc] initWithViewController:self];
	gameManager = [[GameManager alloc] initWithUIManager:uim];
	[uim release];
}

// After the view is displayed, we set up the game
- (void)viewDidLoad {
    [super viewDidLoad];
	[gameManager initialGameSetup];
}

// The response from this function indicates if we can handle rotation or not. We can.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

// This function is called as the view unloads
- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)setFilterLight:(int)val {			// Turn on the filter light for a specific number
	for (int x = 0; x < NUMBERSPERROW; x++) {
		Cell* c = [ctlPadCells objectAtIndex:x];
		if (x == val-1) {					// Turn filter light on for this cell
			if (c.filterLight == true) return;		// Already on. You can ignore.
			c.filterLight = true;
			[controlPad invalidateRect:c.frame];
		}
		else {
			if (c.filterLight == true) {	// Light was on. Turn it off
				c.filterLight = false;
				[controlPad invalidateRect:c.frame];
			}
		}

	}
}
	
- (void)dealloc {
	[busyView release];
	[backgroundView release];
	[leftRailView release];
	[rightRailView release];
	[busyView release];
	[settings release];
	[config release];
	[board release];
	[controlPad release];
	[gameManager release];
	[UIManager release];
	[ctlPadCells release];
	[ctlPadTouchPoints release];
    [super dealloc];
}

// This function sets the various font settings (and some just color settings) used in the program.
-(void)themeSetUp {
	// Fonts
	// (cell) default value (e.g. a 'given' number)
	[settings setThemeInfo:FONTDEFVALUE fontName:"Arial" fontSize:36 fontRed:0 fontGreen:0 fontBlue:.5 fontAlpha:1];
	// (cell) value
	[settings setThemeInfo:FONTVALUE fontName:"Papyrus" fontSize:40 fontRed:0.1 fontGreen:0.1 fontBlue:0.1 fontAlpha:1];
	// (cell) value on error
	[settings setThemeInfo:FONTERRVALUE fontName:"Papyrus" fontSize:40 fontRed:1 fontGreen:0 fontBlue:0 fontAlpha:1];
	// pencil marks
	[settings setThemeInfo:FONTPENCIL fontName:"Papyrus" fontSize:12 fontRed:0 fontGreen:0 fontBlue:0 fontAlpha:1];
	// highlighted pencil marks
	[settings setThemeInfo:FONTHIGHLTPENCIL fontName:"Papyrus" fontSize:12 fontRed:0.83 fontGreen:0.25 fontBlue:.08 fontAlpha:1];
	// command strings (command buttons on control pad)
	[settings setThemeInfo:FONTCMDSTRING fontName:"Arial Rounded MT Bold" fontSize:20 fontRed:.6 fontGreen:.6 fontBlue:.6 fontAlpha:1];
	// command strings (command buttons on control pad)
	[settings setThemeInfo:FONTCMDSTRINGSEL fontName:"Arial Rounded MT Bold" fontSize:20 fontRed:1 fontGreen:1 fontBlue:1 fontAlpha:1];
	// option strings (option buttons on control pad)
	[settings setThemeInfo:FONTOPTSTRING fontName:"Arial Rounded MT Bold" fontSize:20 fontRed:0.3 fontGreen:0.3 fontBlue:0.3 fontAlpha:1];
	// Selected option strings
	[settings setThemeInfo:FONTOPTSTRINGSEL fontName:"Arial Rounded MT Bold" fontSize:20 fontRed:0 fontGreen:.5 fontBlue:.5 fontAlpha:1];
	// Selected option strings 2
	[settings setThemeInfo:FONTOPTSTRINGSEL2 fontName:"Arial Rounded MT Bold" fontSize:20 fontRed:0 fontGreen:.5 fontBlue:.5 fontAlpha:1];
	// Selected option strings 3
	[settings setThemeInfo:FONTOPTSTRINGSEL3 fontName:"Arial Rounded MT Bold" fontSize:20 fontRed:0 fontGreen:.5 fontBlue:.5 fontAlpha:1];
	// Menu item (new menu)
	[settings setThemeInfo:FONTMENUITEM fontName:"Papyrus" fontSize:24 fontRed:1 fontGreen:1 fontBlue:1 fontAlpha:1];
	// Time string (displayed on control pad)
	[settings setThemeInfo:FONTTIMESTRING fontName:"Arial Rounded MT Bold" fontSize:16 fontRed:0 fontGreen:0 fontBlue:0 fontAlpha:1];
	// Control pad value (must appear on button)
	[settings setThemeInfo:FONTCTLPADVALUE fontName:"Arial Rounded MT Bold" fontSize:40 fontRed:0.6 fontGreen:0.6 fontBlue:0.6 fontAlpha:1];
	// Control pad value selected (must appear on button)
	[settings setThemeInfo:FONTCTLPADVALUESEL fontName:"Arial Rounded MT Bold" fontSize:40 fontRed:1 fontGreen:1 fontBlue:1 fontAlpha:1];
	// Control pad pencil mark (must appear on button)
	[settings setThemeInfo:FONTCTLPADPENCIL fontName:"Arial Rounded MT Bold" fontSize:14 fontRed:0.6 fontGreen:0.6 fontBlue:0.6 fontAlpha:1];
	// Control pad pencil mark (must appear on button)
	[settings setThemeInfo:FONTCTLPADPENCILSEL fontName:"Arial Rounded MT Bold" fontSize:14 fontRed:1 fontGreen:1 fontBlue:1 fontAlpha:1];
	// Control pad pencil mark excluded (must appear on button)
	[settings setThemeInfo:FONTCTLPADPENCILEXCL fontName:"Arial Rounded MT Bold" fontSize:14 fontRed:1 fontGreen:0 fontBlue:0 fontAlpha:1];
	// Set the highlight for the selected cell to red. No font
	[settings setThemeInfo:FONTCELLSELECTED fontName:"" fontSize:0 fontRed:1 fontGreen:0 fontBlue:0 fontAlpha:1];
	// Set the highlight for the just-left selected cell to brownish. No font.
	[settings setThemeInfo:FONTCELLLEFTSELECTED fontName:"" fontSize:0 fontRed:0.2 fontGreen:0.2 fontBlue:0.2 fontAlpha:1];
	// Set the color for the shading that is used to shade cells that don't match the target
	[settings setThemeInfo:FONTCELLFILTERSHADING fontName:"" fontSize:0 fontRed:0 fontGreen:0 fontBlue:0 fontAlpha:.33];
	// Set the color for the shading that is used for the command buttons and cells (dark color, shadow)
	[settings setThemeInfo:FONTCMDBTNBORDERDARK fontName:"" fontSize:0 fontRed:0 fontGreen:0 fontBlue:0 fontAlpha:.66];
	// Set the color for the shading that is used for the command buttons and cells (light color, reflection)
	[settings setThemeInfo:FONTCMDBTNBORDERLIGHT fontName:"" fontSize:0 fontRed:.8 fontGreen:.8 fontBlue:.8 fontAlpha:.66];
	// Set the color for the filter number cell light)
	[settings setThemeInfo:FONTCMDFILTERLIGHT fontName:"" fontSize:0 fontRed:1 fontGreen:1 fontBlue:0 fontAlpha:1];
}


@end
