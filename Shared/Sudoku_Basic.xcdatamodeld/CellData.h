//
//  CellData.h
//  Sudoku OTW
//
//  Created by David Figge on 2/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface CellData :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * cellMode;
@property (nonatomic, retain) NSNumber * pencilMarks9;
@property (nonatomic, retain) NSNumber * userPencil8;
@property (nonatomic, retain) NSNumber * pencilMarks8;
@property (nonatomic, retain) NSNumber * userPencil6;
@property (nonatomic, retain) NSNumber * userPencil5;
@property (nonatomic, retain) NSNumber * pencilMarks7;
@property (nonatomic, retain) NSNumber * userPencil3;
@property (nonatomic, retain) NSNumber * userPencil2;
@property (nonatomic, retain) NSNumber * pencilMarks6;
@property (nonatomic, retain) NSNumber * userPencil0;
@property (nonatomic, retain) NSNumber * userPencil1;
@property (nonatomic, retain) NSNumber * pencilMarks5;
@property (nonatomic, retain) NSNumber * userPencil4;
@property (nonatomic, retain) NSNumber * cellValue;
@property (nonatomic, retain) NSNumber * pencilMarks4;
@property (nonatomic, retain) NSNumber * userPencil7;
@property (nonatomic, retain) NSNumber * userPencil9;
@property (nonatomic, retain) NSNumber * pencilMarks3;
@property (nonatomic, retain) NSNumber * squareNum;
@property (nonatomic, retain) NSNumber * pencilMarks2;
@property (nonatomic, retain) NSNumber * pencilMarks1;
@property (nonatomic, retain) NSNumber * correctValue;
@property (nonatomic, retain) NSNumber * pencilMarks0;
@property (nonatomic, retain) NSNumber * cellNum;

@end



