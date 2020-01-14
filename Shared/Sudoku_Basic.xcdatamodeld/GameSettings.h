//
//  GameSettings.h
//  Sudoku OTW
//
//  Created by David Figge on 2/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface GameSettings :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * audioOnOff;
@property (nonatomic, retain) NSNumber * timerMin;
@property (nonatomic, retain) NSNumber * timerSec;
@property (nonatomic, retain) NSNumber * timerHours;
@property (nonatomic, retain) NSNumber * gameOver;
@property (nonatomic, retain) NSNumber * currentLevel;

@end



