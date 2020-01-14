//
//  Game.h
//  Sudoku Basic
//
//  Created by David Figge on 12/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
// This module creates and holds a (solvable) game

#import <Foundation/Foundation.h>
#import "Config.h"


@interface Game : NSObject {
	int solution[NUMBERSPERROW][NUMBERSPERROW];				// Contains the answers for each square
	int given[NUMBERSPERROW][NUMBERSPERROW];				// Contains values for given (defaulted) squares
	int avoid[NUMBERSPERROW][NUMBERSPERROW];				// used when creating the puzzle -- avoid this character until no other option
}

-(int)valueAt:(int)row Col:(int)col;						// Grab value ('given') at location. 0 = open for user's choice
-(void)setValueAt:(int)row Col:(int)col Value:(int)val;		// Store a value ('given') at a location. 0 = open for user's choice
-(int)solutionAt:(int)row Col:(int)col;						// Get the value for the solution to the puzzle for this square
-(void)generateGame;										// Generate random game
-(id)initRandomGame;										// Init class and create a random game
-(id)initRandomGame:(int)squaresGiven;						// Generate a game with specified squares as given (reset open), ensuring single solution
-(id)initWithGame:(Game *)game;								// Init class by copying an existing Game object
-(id)init;													// Init class to all empty
-(bool)addRandomValueForRow:(int)row Col:(int)col;			// Add a (valid) random number for specific row and column, and all ones after it. Call with 0 0 to create puzzle
-(bool)solve;												// Given a puzzle in the 'given' array, put the solution in 'solution'
-(bool)isSingleSolution;									// Solve the puzzle twice looking for two different solutions. If found, return false
-(bool)isSingleSolution:(BOOL)avoidSet;						// Look for multiple solutions, if AvoidSet is true, solve only once for alternate solution
-(bool)removeSquares:(int)num;								// Remove (even nbr) random squares from the puzzle (in solution), put in given. if not single solution, return false
@end
