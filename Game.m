//
//  Game.m
//  Sudoku Basic
//
//  Created by David Figge on 12/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
// This object creates and 'holds' a solvable game
// The puzzle generated is verified to have only one solution.

#import "Game.h"


@implementation Game

-(int)valueAt:(int)row Col:(int)col {						// Return puzzle value for square (defaulted value or 0 for open)
	return given[row][col];
}

-(void)setValueAt:(int)row Col:(int)col Value:(int)val {	// Specify puzzle value for square (0=open, value = defaulted)
	if (val < 10) given[row][col] = val;
}

-(int)solutionAt:(int)row Col:(int)col {					// Return correct answer for square
	return solution[row][col];
}

// Initialize object to an empty board
-(id)init {	
	self = [super init];
	if (!self) return self;
	for (int x = 0; x < NUMBERSPERROW; x++)
		for (int y = 0; y < NUMBERSPERROW; y++)
			solution[x][y] = given[x][y] = avoid[x][y] = 0;	// set all values to (default of) 0
	return self;
}

// Functions for generating a board

// Initialize object to a random game solution (all squares have values that are the solution)
-(id)initRandomGame {
	self = [super init];
	if (!self) return self;
	[self generateGame];
	return self;
}

// Initialize object to a random game solution with only the specified number of defaulted squares
-(id)initRandomGame:(int)squaresGiven {
	self = [super init];
	if (!self) return self;
	
	bool success = false;
	
	while (!success) {
		[self generateGame];								// Generate full solution
		success = [self removeSquares:(81 - squaresGiven)]; // Remove random squares until left with specified number of defaulted squares
	}								 // If can't create it, keep trying until success
	return self;
}

// Generate a random game
-(void)generateGame {
	int row;
	int col;
	for (row = 0; row < NUMBERSPERROW; row++) {			// Init table to all empty
		for (col = 0; col < NUMBERSPERROW; col++) {
			solution[row][col] = 0;
			given[row][col] = 0;
			avoid[row][col] = 0;
		}
	}
	
	[self addRandomValueForRow:0 Col:0];		// Generates a board (via recursion)
	for (int x = 0; x < NUMBERSPERROW; x++) {	// Copy solution into 'given' array (where numbers can be pulled)
		for (int y = 0; y < NUMBERSPERROW; y++) {
			given[x][y] = solution[x][y];
		}
	}
	
}

// A copy constructor. Create a new Game object using the passed game object as a pattern
-(id)initWithGame:(Game*)game {
	self = [super init];
	if (!self) return self;
	for (int x = 0; x < NUMBERSPERROW; x++) {
		for (int y = 0; y < NUMBERSPERROW; y++) {
			solution[y][x] = [game solutionAt:y Col:x];
			given[y][x] = [game valueAt:y Col:x];
			avoid[y][x] = 0;							// Avoid is only used temporarily in the removeSquares process
		}
	}
	return self;
}

// Fill a square with a random value that works, given where the puzzle is at. If unable to do so, return FALSE
// Once you have found a potential value that square, call this function to fill in the next square
//   If this call returns FALSE, the value you just tried didn't work. Try a different value until you find one that works.
//	 If you try all values and none work, return FALSE and have the previous sqaure try a different number
// This function calls itself recursively, creating a random puzzle. Call it from square 0,0 to create a full puzzle
-(bool)addRandomValueForRow:(int)row Col:(int)col {				// Fill in puzzle from given start location (typically 0,0)
	bool numbersUsed[10];										// There are 9 possible values to use (ignore 0)
	solution[row][col] = 0;										// Initialize the solution to 0 (indicating none found yet)
	int possibilities;											// Number of possibilities left to try
	int val = 0;												// Value we're currently trying
	int nrow = row;												// The next square's row (proably in this one)
	int ncol = col+1;											// The next square's column (probably to the right of this one)
	if (ncol > 8) {												// If past the end of the row...
		nrow++;														// use the first column of the next row
		ncol = 0;
	}
	int givenVal = given[row][col];								// If there's already a given value, use it (used for solving existing puzzles instead of creating new ones)
	
	if (givenVal == 0) {										// If there's no given value (either open puzzle or open square in existing puzzle
		for (int x = 0; x < 10; x++) numbersUsed[x] = false;		// The numbersUsed array keeps track of values we've tried that didn't work
																// First, determine choices based on board settings.
		for (int x = 0; x < NUMBERSPERROW; x++) {
			numbersUsed[solution[row][x]] = true;					// Numbers already used in row
			numbersUsed[given[row][x]] = true;
		}
		for (int y = 0; y < NUMBERSPERROW; y++) {
			numbersUsed[solution[y][col]] = true;					// Numbers already used in column
			numbersUsed[given[y][col]] = true;
		}
		int strow = (row/3) * 3;	// starting row of square
		int stcol = (col/3) * 3;	// starting col of square
		for (int x = 0; x < 3; x++)
			for (int y = 0; y < 3; y++) {
				numbersUsed[solution[strow+y][stcol+x]] = true;		// Numbers already used in (3x3) square
				numbersUsed[given[strow+y][stcol+x]] = true;
			}
		possibilities = 0;										// Now count the number of possible values still available
		for (int x = 1; x < 10; x++) 
			if (numbersUsed[x] == false) possibilities++;
	}															// For each element in numbersUsed that is 0, it's a possible value to try
	else			// If there is a default value
		possibilities = 1;	// Then it's the value that must be used

		
	for (;;) {											// Now to find a suitable number for the square
		if (possibilities == 0) {
			solution[row][col] = 0;						// Can't find a number. Reset square to 0 and return
			return false;								// Unable to find good number
		}
		val = givenVal;								// If 'given', there isn't a choice. Used it. Otherwise, val = 0
		if (val == 0) {								// If no given val, we'll have to find a random one
			for(;;) {								// keep trying until we find a number that works
				val = (rand() % 9) + 1;				// Using digits 1 - 9, choose a random one and put it in val
				if (val == avoid[row][col] && possibilities > 1) // If we tried this number in a previous solution (seeing if only one),
					continue;						// Try another if that's an option
				if (numbersUsed[val] == false)		// If we haven't tried this one yet, go for it!
					break;
			}
		}
		solution[row][col] = val;					// Mark as solution
		
		if (nrow == 9) return true;					// If this was last square, we did it!
		if ([self addRandomValueForRow:nrow Col:ncol] == true) break;	// Call this routine again for the next square. If comes back true, we have solution
		numbersUsed[val] = true;						// Couldn't find solution with this number, try again
		possibilities--;
	}
	return true;
}


// Solve the given puzzle. Array 'given' must contain puzzle to solve. Return true if solution is found (put in solution array), false if no solution
-(bool)solve {
	for (int r = 0; r < NUMBERSPERROW; r++)
		for (int c =0; c < NUMBERSPERROW; c++)
			solution[r][c] = 0;					// Reset solution values to none
	bool success =  [self addRandomValueForRow:0 Col:0];

	return success;
}

// This function determines if the existing puzzle (represented by the GIVEN array values) has one and only one solution. It assumes the AVOID array has NOT been set
-(bool) isSingleSolution {
	return [self isSingleSolution:NO];
}

// This function determines if the existing puzzle (represented by the GIVEN array values) has one and only one solution. Specify YES or NO if AVOID array has been set up already
// The test is run by solving the puzzle twice. After the first time, the solution values are copied into the AVOID array.
// The AVOID array contains values that are used only if no other values will work.
// If, after solving the puzzle the second time, only AVOID values were used, there are no other solutions to the given puzzle.
-(bool) isSingleSolution:(BOOL)avoidSet {				// Check to make sure there's only one solution for board defined in 'given'
	if (avoidSet == NO) {								// If coming in not having set the AVOID array, set it here
		for (int row = 0; row < NUMBERSPERROW; row++)		// The AVOID array contains values to avoid using unless there's no other option
			for (int col = 0; col < NUMBERSPERROW; col++)
				avoid[row][col] = 0;
		bool success = [self solve];		// Solve the first time
		if (! success) return false;			// If can't solve it, clearly not a single solution
	
		for (int row = 0; row < NUMBERSPERROW; row++) {	// Now set up the Avoid array with the current solution
			for (int col = 0; col < NUMBERSPERROW; col++) {
				if (given[row][col] == 0) avoid[row][col] = solution[row][col];		// Found 1 solution. Avoid these numbers and try again
			}
		}
	}
	
	[self solve];							// Solve the puzzle again
	for (int row = 0; row < NUMBERSPERROW; row++) {			// Check and see if any SOLUTION values are different than the AVOID values
		for (int col = 0; col < NUMBERSPERROW; col++) {
			if (given[row][col] == 0 && (avoid[row][col] != solution[row][col])) return false;		// Found another solution!
		}
	}
	return true;					// Only solution found was using numbers to avoid. So there's only one solution
}

// This function removes squares 1 or 2 at a time
// After each removal, a check is done to verify that the puzzle still has only one solution
// If multiple solutions are found, the numbers are replaced and we try again.
// If we've tried to remove 80 pairs and still haven't found a viable solution, we give up and return false (where we create another puzzle and try again)
-(bool)removeSquares:(int)num {
	int row, col;
	for (row = 0; row < NUMBERSPERROW; row++)
		for (col = 0; col < NUMBERSPERROW; col++)
			avoid[row][col] = given[row][col] = solution[row][col];		// Copy completed puzzle into 'avoid' and 'given', where we'll remove squares
	
	int count = 0;
	for (int x = 0; x < num; ) {
		int row = rand() % NUMBERSPERROW;				// Find random row and col
		int col = rand() % NUMBERSPERROW;
		if (given[row][col] == 0) continue;				// Already removed that one previously. Try another pair
		int v1 = given[row][col];						// Remove two squares (e.g. 3,5 and 5,3. Note that when row=col we remove only one square, like 3,3)
		int v2 = given[col][row];
		given[row][col] = 0;							// Remove squares from 'given' grid
		given[col][row] = 0;
		if (![self isSingleSolution:YES]) {				// Is there only one solution?
			given[row][col] = v1;						// No longer single solution. Try again
			given[col][row] = v2;						// Replace removed values, try again
			if (count++ > 80) return false;
			continue;
		}
		if (row == col) x++;							// If removed only one square, count only goes up by one
		else x += 2;									// Removed two squares, count goes up by two
	}
	return true;										// If we got all desired squares removed and still have only 1 solution, we succeeded!
}


@end
