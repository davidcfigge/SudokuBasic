//
//  GameManager.m
//  Sudoku Basic
//
//  Created by David Figge on 11/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GameManager.h"


@implementation GameManager

@synthesize uiManager, isPaused, timerActive, currentGame, isGenerating;

void copyPencilMarks(int* dest, int* source); // Internal utility function: copy pencil marks

// Initialize the game manager. Called once at the beginning of the app execution by the ViewController
// The UI manager is also created by the ViewController (so UI manager can call it), and is passed to here to establish its connection from GameManager
-(id)initWithUIManager:(id<UIMgrProtocol>)uiMgr {
	self = [super init];
	if (self != nil) {
		BtnPress = [[SoundEffect alloc] initWithFile:@"BtnPress"];
		OtherBtn = [[SoundEffect alloc] initWithFile:@"OtherBtn"];
		SoloChg = [[SoundEffect alloc] initWithFile:@"SoloChg"];
		BoardMove = [[SoundEffect alloc] initWithFile:@"BoardMove"];
		self.uiManager = uiMgr;							// Store UI Manager object
		config = [Config config];					// Locate and save (shared) configuration object
		[config retain];
		settings = [Settings settings];				// Locate and save (shared) settings object
		[settings retain];
		currentSelection = lastSelection = -1;		// No cell currently selected
		userTappedGiven = false;					// No cell currently selected
		isGenerating = true;
		datastore = [[Datastore alloc] init];
		[uiManager setSoundSelected:[SoundEffect SoundState]];
	}
	return self;
}

// Come here for the initial setup of the first (e.g. default) game
-(void)initialGameSetup {
	// Set up the environment for all games
	srand((unsigned)time(NULL));					// Seed the random number generator
	
	[self createCells];								// Create all the cells
	currentLevel = 2;								// Start with normal level as default
	
	// Set up the environment for the current game (new or reloaded)
	[self configureForGame:71];						// Create a new game (71 is quick to generate, will be thrown away
	[uiManager setBoardPos:HIDDEN];					// Set the board and pad to their hidden locations for entry onto the screen
	[uiManager setPadPos:HIDDEN];
	// First establish a timer that keeps track of elapsed time
	[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(incrementTimer:) userInfo:nil repeats:YES];
	// Here's where we look to see if we're coming back to a game in progress
	if ([datastore isDataStored]) {
		if ([self loadPreviousGame] == true) return;
	}
	
	isPaused = false;								// Start with game active
	isGenerating = true;
	[uiManager showPad];							// Bring on the control pad (board will be brought on as part of a new game process)
	
	// Now create a timer that triggers a new game and starts the animation of the board onto the screen (3 secs allows the pad to get settled first)
	isGenerating  = true;
	[NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(newGameOnScreenUp:) userInfo:nil repeats:NO];
}

-(bool)loadPreviousGame {
	if (![datastore isDataStored]) return false;				// Data not stored, so return code that we didn't load any game
	[datastore loadCellData:cells];
	bool soundflag = [datastore getGameSettingsAudio];
	if (soundflag) [SoundEffect SoundOn];
	else [SoundEffect SoundOff];
	[uiManager setSoundSelected:[SoundEffect SoundState]];
	gameOver = [datastore getGameSettingsGameOver];
	hours = [datastore getGameSettingsTimerHours];
	minutes = [datastore getGameSettingsTimerMinutes];
	seconds = [datastore getGameSettingsTimerSeconds];
	currentLevel = [datastore getGameSettingsCurrentLevel];
	if (gameOver) return false;									// If game is over, start a new one
	[self displayTimer];
	[uiManager showPad];
	isPaused = true;
	timerActive = false;
	isGenerating = false;
	[uiManager setPausedCaption:"Resume"];
	[uiManager selectPaused:SELECTED];
	return true;
}

// Come here when being put into the background
-(void)sleep {
	if (!isPaused) {
		[self tappedPause:YES];				// Go into pause mode, hide board, no sound
	}
	[datastore saveGameSettings:gameOver audio:[SoundEffect SoundState] hours:hours minutes:minutes seconds:seconds currentLevel:currentLevel];
	[datastore saveCellData:cells];
}

// Come here when waking up from being in the background
-(void)wake {
	if (isGenerating) return;
	// Game should be paused (it was put into pause state when it went to sleep).
	if (gameOver)
		[self newGameOnScreenUp:nil];		// Start a new game at the same level
}

// Create the array of cells for the board (e.g. 81 of them)
-(void)createCells {
	cells = [[NSMutableArray alloc] initWithCapacity:81];
	Cell* c;
	CGRect cellFrame;
	int xcoord;
	int ycoord = config.boardBorder.y + config.gridLineWidth;	// Coordinates are always relative to the board. Locate Y coord of upper left cell
	int cellNum = 0;
	for (int y=0; y < NUMBERSPERROW; y++) {						// For each row
		xcoord = config.boardBorder.x + config.gridLineWidth;    // Start of first square in this row
		for (int x = 0; x < NUMBERSPERROW; x++) {					// For each cell in this row
			cellFrame = CGRectMake(xcoord, ycoord, config.cellSize.width, config.cellSize.height);	// Create cell frame rectangle
			c = [[Cell alloc] initWithFrame:cellFrame square:cellNum];
			[cells addObject:c];																	// Create and add the cell object to the array
			[c release];																			// release ownership
			cellNum++;																				// Next cell number
			xcoord += config.cellSize.width + config.gridLineWidth;									// Next cell position
		}
		ycoord += config.cellSize.height + config.gridLineWidth;									// Move down a row
	}
}

// Call to reset the 'elapsed' timer to 0 and start the counting
-(void)startTimer {
	hours = minutes = seconds = 0;
	timerActive = YES;
}

// Called by the timer every second to increment the 'elasped' timer and display it
-(void)incrementTimer:(NSTimer*)timer
{
	if (!timerActive || gameOver == YES) return;		// If not counting (paused or ended game), ignore tick
	seconds++;											// It's been another second
	[self displayTimer];
}

-(void)displayTimer {
	if (seconds >= 60) {								// Make seconds, minutes, and hours accurate to current time
		seconds -= 60;
		minutes++;
		if (minutes >= 60) {
			minutes -= 60;
			hours++;
		}
	}
	if (hours > 0)										// Don't display hours unless it's past 0
		sprintf(timerString,"Elapsed: %d:%02d:%02d",hours,minutes,seconds);
	else
		sprintf(timerString,"Elapsed: %d:%02d",minutes,seconds);
	[uiManager updateTimer:timerString];				// Update the timer display on the screen
}

// Update pencil marks for entire board, marking those that should be highlighted as well
// Called anytime something changes on the board (if Auto or Hint is on)
-(void)autoPencil {
	if (settings.pencilMode == PENCIL_DEFAULT) return;
	int row, col, r, c;
	Cell* curCell;
	int pencils[10];				// One for each digit
	// First, let's get a snapshot of the board
	int theBoard[NUMBERSPERROW][NUMBERSPERROW];
	for (row = 0; row < NUMBERSPERROW; row++) {
		for (col = 0; col < NUMBERSPERROW; col++) {
			curCell	= [cells objectAtIndex:(row * 9 + col)];
			theBoard[row][col] = curCell.value;
		}
	}
	
	// Now we go through for each cell and calculate simple pencil markings, removing/adding those requested by userPencil
	for (row = 0; row < NUMBERSPERROW; row++) {
		for (col = 0; col < NUMBERSPERROW; col++) {
			for (int x = 0; x < 10; x++) pencils[x] = MARK_ON;
			curCell = [cells objectAtIndex:(row * 9 + col)];
			
			// Check the current row
			for (c = 0; c < NUMBERSPERROW; c++)
				pencils[theBoard[row][c]] = MARK_OFF;		// These values already used
			// Now the column
			for (r = 0; r < NUMBERSPERROW; r++)
				pencils[theBoard[r][col]] = MARK_OFF;		// These values already used
			// Now the square
			int stcol = (col / 3) * 3;
			int strow = (row / 3) * 3;
			for (r = strow; r < strow+3; r++) {				// For each cell in the square
				for (c = stcol; c < stcol+3; c++) {
					pencils[theBoard[r][c]] = MARK_OFF;		// These values already used
				}
			}
			// At this point, default pencil marks have been established for this cell
			// Now we apply any modifications the user specified in userPencils
			int *upm = [curCell getUserPencils];
			for (int x = 1; x < 10; x++) {
				if (upm[x] == PENCIL_OFF)
					pencils[x] = MARK_OFF;
			}
			// Now we apply these settings to the cell
			for (int x = 0; x < 10; x++)
				[curCell setPencilMark:x toValue:pencils[x]];
			[uiManager redrawCell:curCell];
		}
	}
	if (settings.pencilMode < PENCIL_HINTS) return;		// If not looking for hints, don't waste the time
	// Looking for hints.
	// Two levels of hints. First, if it's the only pencil mark in the cell, make it a hint
	// Second, if it's the only instance of the number in the row, column, or square make it a hint
	
	int cmarks[10];
	
	for (row = 0; row < NUMBERSPERROW; row++) {
		for (col = 0; col < NUMBERSPERROW; col++) {
			curCell = [cells objectAtIndex:row * 9 + col];		// Get cell to look at
			if (curCell.value != 0) continue;
			copyPencilMarks(cmarks, [curCell getPencilArray]);	// Get a copy of the current pencil marks
			int cnt = 0;
			int thisOne = 0;
			for (int x = 0; x < 10; x++) {							// If only one number, mark it and be done!
				if (cmarks[x] != MARK_OFF) {
					cnt++;
					thisOne = x;
				}
			}
			if (cnt == 1) {
				cmarks[thisOne] = MARK_HINT;						// Set this as the hint
				copyPencilMarks([curCell getPencilArray], cmarks);	// Our work here is done. Copy the modified pencil marks and return
				continue;											// Go to next cell
			}
			// If we made it this far, we need to delve deeper than 'a single choice' for a hint
			
			int nbrcnt[10];
			int* pmarks;
			
			// Start with the col
			for (int x = 0; x < 10; x++) nbrcnt[x] = 0;				// Zero out count
			for (r = 0; r < 9; r++) {								// Here we add up the number of times a number appears in the pencil marks for the column
				Cell *cell = [cells objectAtIndex:r * 9 + col];				// Get the cell from the column
				if (cell == curCell || cell.value != 0) continue;
				pmarks = [cell getPencilArray];						// Get its pencil marks
				for (int x = 1; x < 10; x++)
					if (cmarks[x] != MARK_OFF && pmarks[x] != MARK_OFF) nbrcnt[x]++;	// If there's another pencil mark in the col, count it
			}
			// Now that we've counted all the pencil marks in the column, see if any pencil marks had no matches
			bool marked = false;
			for (int x = 1; x < 10; x++) {
				if (cmarks[x] != MARK_OFF && nbrcnt[x] == 0) {		// Found one!
					cmarks[x] = MARK_HINT;
					marked = true;
					break;
				}
			}
			if (marked) {											// Mark set. Go to next cell
				copyPencilMarks([curCell getPencilArray], cmarks);
				continue;
			}
					
			// No success yet. Let's try the row
			for (int x = 0; x < 10; x++) nbrcnt[x] = 0;				// Zero out count
			for (c = 0; c < 9; c++) {								// Here we add up the number of times a number appears in the pencil marks for the row
				Cell *cell = [cells objectAtIndex:row * 9 + c];		// Get the cell from the row
				if (cell == curCell || cell.value != 0) continue;
				pmarks = [cell getPencilArray];						// Get its pencil marks
				for (int x = 1; x < 10; x++)
					if (cmarks[x] != MARK_OFF && pmarks[x] != MARK_OFF) nbrcnt[x]++;	// If there's another pencil mark in the col, count it
			}
			// Now that we've counted all the pencil marks in the row, see if any pencil marks had no matches
			marked = false;
			for (int x = 1; x < 10; x++) {
				if (cmarks[x] != MARK_OFF && nbrcnt[x] == 0) {		// Found one!
					cmarks[x] = MARK_HINT;
					marked = true;
					break;
				}
			}
			if (marked) {											// Mark set. Go to next cell
				copyPencilMarks([curCell getPencilArray], cmarks);
				continue;
			}
			
			// Finally let's check the square
			for (int x = 0; x < 10; x++) nbrcnt[x] = 0;				// Zero out count
			int stcol = col / 3 * 3;								// Starting column of square
			int strow = row / 3 * 3;								// Starting row
			for (r = strow; r < strow+3; r++) {						// Here we add up the number of times a number appears in the pencil marks for the column
				for (c = stcol; c < stcol+3; c++) {
					Cell *cell = [cells objectAtIndex:r * 9 + c];				// Get the cell from the column
					if (cell == curCell || cell.value != 0) continue;
					pmarks = [cell getPencilArray];						// Get its pencil marks
					for (int x = 1; x < 10; x++)
						if (cmarks[x] != MARK_OFF && pmarks[x] != MARK_OFF) nbrcnt[x]++;	// If there's another pencil mark in the col, count it
				}
			}
			// Now that we've counted all the pencil marks in the column, see if any pencil marks had no matches
			marked = false;
			for (int x = 1; x < 10; x++) {
				if (cmarks[x] != MARK_OFF && nbrcnt[x] == 0) {		// Found one!
					cmarks[x] = MARK_HINT;
					marked = true;
					break;
				}
			}
			if (marked) {											// Mark set. Go to next cell
				copyPencilMarks([curCell getPencilArray], cmarks);
				continue;
			}
			
		}
	}	

}

// Called when the user double-tapped on a cell
// The job of this function is to determine what cell was tapped and to give it a logical value based on the return from the getSuggestion function
-(void)dblTappedCellAtPoint:(CGPoint)pt {
	if (currentSelection == -1) return;		// If can't select cell, return
	Cell* current = [cells objectAtIndex:currentSelection];			// Get current cell
	if ([current wasHit:pt] == NOHIT) return;						// If you didn't tap here, return (typically tapped on given value)
	[BtnPress Play];
	int s = [current getSuggestion];								// Any obvious value I should be taking?
	if (settings.filterMode) s = filterVal;
	if (s > 0) {
		current.value = s;											// Yes. Set it
		[self checkWin];											// Set game over flag if last cell and board accurate
	}
	else {															// No obvious choice. Use the 'last selected' cell if possible
		if (lastSelection == -1) return;							// If none, give up
		Cell* c = [cells objectAtIndex:lastSelection];				// Get location of 'last selection' cell
		current.value = c.value;									// Set the value to that cell's value
		[self checkWin];											// Set game over flag if last cell and board accurate
	}
	if (current.value > 0) [self setFilter:current.value];			// Display with new filter value
	[uiManager redrawCell:current];									// Redraw the cell with the new value
	[self autoPencil];												// Update pencil marks
	[uiManager syncCtlPadWithCell:current];							// Sync pad with current cell
}

// Utility function: copies 10 pencil mark integers from source to destination pointers
void copyPencilMarks(int* dest, int* source)
{
	for (int x = 0; x < 10; x++)
		*dest++ = *source++;
}

// Called when the user taps a cell to select it
// If the cell is a default cell, you can't actually select it, so the 'last selection' mark is put on it
// If the cell is editable, it is selected and the 'last selection' is moved to the previously selected cell
-(void)tappedCellAtPoint:(CGPoint)pt {
	Cell* c;
	int cellNum = -1;
	for (c in cells) {						// Let's first see if we hit within a cell
		if ([c wasHit:pt] != NOHIT) {		// If found one, break out of loop
			cellNum = c.squareNum;				// Remember this cell number!
			break;
		}
	}
	if (cellNum == -1 || cellNum == currentSelection) return;				// If not on cell, ignore tap
	
	// First, check to see if selected a 'given' cell
	if (c.cellMode == CELLREADONLY) {		// Selected a given value. Update 'last' to point to this one
		if (lastSelection != -1) {			// Erase old if any
			Cell* old = [cells objectAtIndex:lastSelection];
			old.selected = NOTSELECTED;
			[uiManager redrawCell:old];
		}
		lastSelection = c.squareNum;
		c.selected = LEFTSELECTED;
		[uiManager redrawCell:c];
		if (settings.filterMode == true) [SoloChg Play];
		[self setFilter:c.value];			// if filter is on, update display to reflect new 'last selected' selection
		userTappedGiven = true;				// Remember that the user tapped a 'given' cell (used when they select next cell)
		return;								// Exit function, we're done
	}
		
	// If you're here, user tapped on an editable cell
	// Erase previous cell's highlight
	if (c.value > 0) [self setFilter:c.value];				// If they tapped on a cell that has a value, use that as the filter value
	if (currentSelection != -1)								// If there was a previous cell selected
	{
		Cell* co = [cells objectAtIndex:currentSelection];		// Get it
		co.selected = NOTSELECTED;								// Unselect it
		[uiManager redrawCell:co];								// Redraw it
	}
	
	// Okay. We can move to here. Should we update LastSelected though?

	// Are we selecting a square that used to be the 'last'? if so, we no longer have 'last selection'
	if (cellNum == lastSelection) lastSelection = -1;
	
	// If there's a current selection, make it 'last selected'
	if (currentSelection != -1) {
		Cell* co = [cells objectAtIndex:currentSelection];
		if (co.value > 0 && !userTappedGiven) {			// Yes, it has a value. Update the 'last selected' marker
			if (lastSelection != -1) {					// Reset last selected cell (if there is one)
				Cell* old = [cells objectAtIndex:lastSelection];
				old.selected = NOTSELECTED;
				[uiManager redrawCell:old];
			}
			co.selected = LEFTSELECTED;					// Set new 'last selected' cell
			lastSelection = co.squareNum;
			[uiManager redrawCell:co];
		}
	}
	userTappedGiven = false;							// Alright, we no longer care what was tapped before this one
	// Now update newly selected cell
	
	c.selected = SELECTED;								// Set current cell as 'selected'
	[uiManager redrawCell:c];
	currentSelection = c.squareNum;						// And remember it
	[uiManager syncCtlPadWithCell:c];					// Sync the control pad with the selected cell
}

// Refresh the control pad to reflect the settings of the currently selected cell (used when orientation changes)
-(void)refreshCtlPad {
	if (currentSelection != -1) {
		Cell* c = [cells objectAtIndex:currentSelection];		// Get currently selected cell
		[uiManager syncCtlPadWithCell:c];						// Sync with it
	}
	[uiManager setPausedCaption:( isPaused ? "Resume" : "Pause")];
	[uiManager selectPaused:( isPaused ? SELECTED : NOTSELECTED)];
	[uiManager redrawFilterButton];
	switch(settings.pencilMode) {
		case PENCIL_OFF:
			[uiManager setAutoCaption:"Auto"];
			break;
		case PENCIL_AUTO:
			[uiManager setAutoCaption:"Auto"];
			break;
		case PENCIL_HINTS:
			[uiManager setAutoCaption:"Hints"];
			break;
	}
	[uiManager redrawAutoButton];
	if (settings.filterMode == true) [uiManager setFilterLight:filterVal];
	[uiManager redrawPad];
}

// Called when user double-taps a control pad cell
// We ignore it, because it has no meaning in this game
-(void)dblTappedCtlPadCell:(int)ID {
	if (settings.filterMode == true && ID < 9 && filterVal == ID+1)
		[self tappedCtlPadCell:ID];
}

// Called when user taps a control pad cell
// Remember that buttons (pause, new) are handled elsewhere
// Here we determine if it was a value cell or a pencil mark cell and act accordingly
-(void)tappedCtlPadCell:(int)ID {
	if (uiManager.isWaiting || isPaused) return;					// If we're in a wait mode, ignore the tap
	if (settings.filterMode == true && ID < 9 && filterVal != ID+1) {		// Reset filter value
		[SoloChg Play];
		[self setFilter:ID+1];
		return;
	}
	if (currentSelection == -1) return;					// If there isn't a currently selected cell to modify, ignore the tap
	[BtnPress Play];
	Cell* c = [cells objectAtIndex:currentSelection];	// Get the currently selected cell
	if (ID < 9) {										// if Number (value) hit
		if (c.value == ID+1)							// If the value was previously set, unset it
			c.value = 0;
		else 
			c.value = ID+1;								// Otherwise set the currently selected cell's value to the value of the pad cell tapped
		[uiManager redrawCell:c];						// Redraw the cell with the new value
		[self autoPencil];								// Do auto pencil markings
		if (c.value > 0) 
			[self setFilter:c.value];						// Update the filter to the currently selected value
		else 
			[self setFilter:filterVal];
		[uiManager syncCtlPadWithCell:c];				// Update control pad to reflect cell's settings
		[self checkWin];								// check for a win
	}
	else {					// Pencil mark selected
		int pm = ID-8;			// Find the pencil mark selected
		if ([settings pencilMode] >= PENCIL_AUTO) {	// If in auto or hint mode, show include/not include instead of on/off
			int v = [c userPencilMark:pm];
			if (v == PENCIL_OFF) v = PENCIL_NONE;
			else v = PENCIL_OFF;
			[c setUserPencilMark:pm toValue:v];
			[self autoPencil];
			[self setFilter:filterVal];
		}
		else {										// Otherwise, toggle the pencil mark
			if ([c pencilMark:pm] == SELECTED)
				[c setPencilMark:pm toValue:NOTSELECTED];
			else
				[c setPencilMark:pm toValue:SELECTED];
		}
		[uiManager redrawCell:c];					// Redraw the cell
		[uiManager syncCtlPadWithCell:c];			// Update control pad to reflect cell's settings
		[self setFilter:filterVal];					// Redraw filtered display as needed
	}

}

// This function, called by a timer, is used to create a new game once the board is HIDDEN
-(void)newGameOnScreenUp:(NSTimer*)timer {
	[uiManager cancelWait];									// Cancel waiting mode if on
	settings.filterMode = false;							// Turn off the filter
	if (currentSelection != -1) {							// Turn off any selected cell
		Cell* c = [cells objectAtIndex:currentSelection];
		c.selected = NOTSELECTED;
		currentSelection = -1;
	}
	if (lastSelection != -1) {								// Turn off any 'last selected' cell
		Cell* c = [cells objectAtIndex:lastSelection];
		c.selected = NOTSELECTED;
		lastSelection = -1;
	}
	[uiManager syncCtlPadWithCell:nil];						// Reset control pad
	[uiManager redrawFilterButton];							// Redraw the filter button to make sure it's not selected
	[uiManager setAutoCaption:"Auto"];						// Reset the AUTO caption to AUTO
	settings.pencilMode = PENCIL_DEFAULT;					// Reset the pencil mode to 'off'
	[uiManager redrawAutoButton];							// Make sure Auto button is 'off'
	if (isPaused) [self tappedPause];						// Turn off paused
	[uiManager redrawPad];									// Make sure entire control pad is drawn properly now
	[uiManager resetBoard];									// Reset the board to initial settings
	[self configureForGame:[settings getCellCount:currentLevel]];	// Create a new game based on current level
	[uiManager setNewSelected:NOTSELECTED];					// Turn off the NEW button
	[uiManager redrawBoard];								// Redraw current default cells
	[BoardMove Play];
	[uiManager showBoard];									// Bring the board onto the screen
	gameOver = NO;											// Reset the GameOver flag to not over (e.g. active)
	isGenerating = false;									// Done generating game
	[self startTimer];										// Restart the elapsed timer
	[uiManager cancelBusy];									// Turn off the busy indicator
}

// The user tapped the NEW button
-(void)tappedNew {
	if (uiManager.isWaiting || isGenerating) return;						// If in waiting mode, ignore it
	timerActive = NO;										// Turn off the timer
	[OtherBtn Play];
	[uiManager setNewSelected:SELECTED];					// Turn on the NEW 'light'
	[uiManager showNewMenu];								// Display the menu for new game
}

// If user cancels out of the NEW menu by clicking outside the window, this function is called
-(void)newGameCanceled {
	[OtherBtn Play];
	[uiManager setNewSelected:NOTSELECTED];					// Turn off the new light
	timerActive = !gameOver;								// Resume the game if appropriate
}

// If user selects an option from the NEW menu, it comes here. The option selected could be cancel.
-(void)newGameSelected:(int)sel {					// User selected menu option (one of which is cancel
	[OtherBtn Play];
	if (sel == 5) return [self newGameCanceled];	// If user selected cancel, perform the newGameCanceled process
	currentLevel = sel;								// Save the level of game selected
	isGenerating = true;
	[uiManager hideBoard];							// Hide the board, and (once hidden) create a new game
	[uiManager showBusy];
	[BoardMove Play];
	[NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(newGameOnScreenUp:) userInfo:nil repeats:NO];
}

-(void)msgBoxSelected:(int)item {					// Called if user selects YES or NO at end of game messagebox
	if (item == 1)
		displayNewMenu = true;
}

-(void)popupDismissed {
	if (displayNewMenu) {
		displayNewMenu = false;
		[self tappedNew];
	}
}

// The user tapped the SOUND icon
-(void)tappedSound {
	[SoundEffect ToggleSound];
	[uiManager setSoundSelected:[SoundEffect SoundState]];
}

// The user tapped the SETTINGS button
-(void)tappedSettings {
	if (uiManager.isWaiting || isGenerating) return;
	[OtherBtn Play];
	[self SaveTimerState];
	timerActive = false;
	[uiManager setSettingsSelected:SELECTED];
	[uiManager showHelp];
}

-(void)SaveTimerState {
	timerState = timerActive;
}

-(void)RestoreTimerState {
	timerActive = timerState;
}

-(void)tappedPause { [self tappedPause:NO]; }

// The user tapped the PAUSE button
-(void)tappedPause:(BOOL)autosleep {
	if (uiManager.isWaiting || isGenerating && autosleep==NO) return;			// If we're in waiting mode, ignore tap
	isPaused = isPaused ? NO : YES;				// Toggle the paused flag
	if (isPaused) {								// If pausing
		timerActive = NO;							// Turn of the timer
		if (autosleep == NO) {
			[uiManager hideBoard];						// Hide the board
			[BoardMove Play];						// Play sound effect
		}
		else
			[uiManager setBoardPos:HIDDEN];
		[uiManager setPausedCaption:"Resume"];		// Reset the 'paused' button to say RESUME
		[uiManager selectPaused:ISSELECTED];		// Highlight the paused button
	}
	else {										// If resuming
		timerActive = YES;							// Turn back on the timer
		[uiManager showBoard];						// Display the board
		[BoardMove Play];							// Play sound effects
		[uiManager setPausedCaption:"Pause"];		// Reset the text on the pause button to PAUSE
		[uiManager selectPaused:NOTSELECTED];		// Turn of the highlight on the pause button
	}
}

// Check to see if the user has won the game
-(bool)checkWin {
	NSString* msg;
	for (Cell* c in cells) {							// Look at all the cells
		if (c.value == 0) return false;					// If any are unselected, we're not over
		if (c.value != c.correctValue) return false;	// If any are just wrong, we're not over
	}
	gameOver = YES;										// Alright! Game over!
	timerActive = false;								// Turn off the timer
	msg = [NSString stringWithFormat:@"You have solved this puzzle with a time of %s.\nWould you like to start another puzzle now?",timerString+9];
	[self displayMessageBox:@"Contratulations!" withMessage:msg withYesNo:YES];	// Display "You Won" message
	return true;
}

// Display an alert-type messagebox on the screen
-(void)displayMessageBox:(NSString*)title withMessage:(NSString*)message withYesNo:(BOOL)YesNo {
	[uiManager displayMessageBox:title withMessage:message withYesNo:YesNo];
}

// User tapped the AUTO button
-(void)tappedAuto {
	if (uiManager.isWaiting || isPaused) return;					// If in waiting mode, ignore tap
	[OtherBtn Play];
	if (settings.pencilMode == PENCIL_MODES_COUNT-1) settings.pencilMode = PENCIL_DEFAULT; // If at end of modes, wrap around to first mode
	else settings.pencilMode++;							// Otherwise just increment the mode
	[uiManager setAutoCaption:(settings.pencilMode <=PENCIL_AUTO ? "Auto" : "Hint")];		// Set to the appropriate caption
	[uiManager redrawAutoButton];						// Redraw the AUTO button
	[uiManager redrawBoard];							// Redraw the board for pencil mark changes
	[self autoPencil];									// Do auto pencil as needed
	if (currentSelection >= 0) {						// Sync pad with current cell now to reflect changes in pencil mode
		Cell* c = [cells objectAtIndex:currentSelection];
		[uiManager syncCtlPadWithCell:c];
	}
}

// User tapped FILTER ('SOLO') button
-(void)tappedFilter {
	if (uiManager.isWaiting || isPaused) return;					// If in waiting mode, ignore tap
	bool f = !settings.filterMode;						// Get the new filter mode setting
	int val = 0;										// Current filter value is 0
	if (f) {											// If turning on filter mode...
		if (currentSelection >= 0) {						// If current selection
			Cell* c = [cells objectAtIndex:currentSelection];	// Get the currently selected cell
			val = c.value;								// Use that value (if any)
		}
		if (val == 0 && lastSelection >= 0) {			// If selected cell has no value (or no current selection)
			Cell* c = [cells objectAtIndex:lastSelection];		// Try using 'last selection'
			val = c.value;
		}
		if (val == 0) return;							// Can't do it, no legitimate value to use
	}
	[OtherBtn Play];
	settings.filterMode = f;							// Set the filter mode
	[uiManager redrawFilterButton];						// Redraw the filter button
	if (f) 
		[self setFilter:val];					// If turning on, set the value to filter on
	else
		[uiManager redrawBoard];							// Redraw the board with filter on/off
	[uiManager redrawPad];
}

// Set the filter value here.
// We dod this by going through all the cells and setting the shadingOn flag if it should be on
-(void)setFilter:(int)val {
	if (!settings.filterMode) return;					// If filter mode off, we're done!
	filterVal = val;									// Set the value to filter on
	// Start by turning on the filter light in the control pad cells for the filter number
	[uiManager setFilterLight:val];						// Turn on the cell with this number
	bool cvals[NUMBERSPERROW][NUMBERSPERROW];			// Create an array of bools to use for filtering, initializing all of them to FALSE (can place value here)
	for (int x = 0; x < NUMBERSPERROW; x++) {
		for (int y = 0; y < NUMBERSPERROW; y++) {
			cvals[y][x] = false;
		}
	}
	
	// Now we go through each cell. As we encounter a cell that matches the target value, we
	// shade in the row, column, and square that it is in (be setting the bool array value to TRUE)
	for (int row = 0; row < NUMBERSPERROW; row++) { 
		for (int col = 0; col < NUMBERSPERROW; col++) {
			Cell* c = [cells objectAtIndex:row * 9 + col];
			if (c.value == val) {				// Found a match. Shade in all areas affected by this cell
				for (int x = 0; x < NUMBERSPERROW; x++) {
					cvals[row][x] = true;		// Shade in column
					cvals[x][col] = true;		// Shade in row
				}
				int strow = row / 3 * 3;		
				int stcol = col / 3 * 3;
				for (int r = strow; r < strow+3; r++) {
					for (int c = stcol; c < stcol+3; c++) {
						cvals[r][c] = true;		// Shade in each cell in it's square
					}
				}
			}
			if (c.value >0) cvals[row][col] = true;	// In all cases, if the cell has a value, it needs to be shaded
		}
	}
	for (int row = 0; row < NUMBERSPERROW; row++) {			// Now go through and set the cell's shadingOn flag to match the bool array's
		for (int col = 0; col < NUMBERSPERROW; col++) {
			Cell *c = [cells objectAtIndex:row * 9 + col];
			c.shadingOn = cvals[row][col];
			if (settings.pencilMode >= PENCIL_AUTO)			// Also shade in those cells where the user has a (red) pencil mark with this value saying 'not this cell'
				if ([c userPencilMark:val] == DESELECTED)
					c.shadingOn = true;
		}
	}
	[uiManager redrawBoard];					// Redraw the board to reflect the new shading
}

// Configure the board for a new game.
// The parameter (numCells) is the number of default values to strive for
// The number of default cells will be either at numCells or one below it
// Rule-of-thumb settings: Tough=21, Hard=25, Medium=29, Easier=33 easy=37
-(void)configureForGame:(int)numCells {
	[currentGame release];
	currentGame = [[Game alloc] initRandomGame:numCells];	// Create a new Game object (with defaults and solution) for specified number of cells
	for (int x = 0; x < NUMBERSPERROW; x++) {							// Make the cells reflect the game squares
		for (int y = 0; y < NUMBERSPERROW; y++) {
			Cell* c = [cells objectAtIndex:y*NUMBERSPERROW+x];
			[c resetVals];												// Reset cell's values
			c.value = [currentGame valueAt:y Col:x];					// Save any value (0 if none, otherwise it's a default value)
			c.correctValue = [currentGame solutionAt:y Col:x];			// Save the correct answer
			c.cellMode = (c.value == 0 ? CELLREADWRITE : CELLREADONLY);	// If there is a value, set the cell's mode to READONLY
		}
	}
}

// Draw the contents of all the cells
// Called by ViewController to draw up board
-(void)drawCellsContents:(CGContextRef)context {
	for (Cell* c in cells) {
		[c draw:context];
	}
}

- (void)dealloc {
	[config release];
	[settings release];
	self.uiManager=nil;
	[currentGame release];
	[cells release];
    [super dealloc];
}


@end
