//
//  Datastore.h
//  Class Timer
//
//  Created by David Figge on 12/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Cell.h"
#import "GameSettings.h"
#import "CellData.h"

// This file assists you in creating a permanent (disk) datastore for holding simple configuration information.
// It supports one record of settings. The record MUST have been defined as a RESOURCE/DATA MODEL file (.xcdatamodel).
// The default entity name is "settings" but can be overridden.

// Steps to using this file
// 1. Use FILE/NEW FILE to create a new RESOURCE/DATA MODEL file.
// 2. Create a new ENTITY called "settings" (the default name) or another name you prefer
// 3. For each data element you want to save, create an attribute within the entity.
// 4. With the data model editor active, use NEW/NEW FILE to create a COCOA TOUCH CLASS/MANAGED OBJECT CLASS file that defines the entity as a class


@interface Datastore : NSObject {
	NSString* dataFileName;
	NSString* entityName;
	NSMutableArray* settingsArray;
	NSMutableArray* cellArray;
}
-(id)init;
-(id)init:(NSString*)entity;
-(void*)getSettingsRecord;
-(void*)getCellRecords;
-(void)saveAllRecords;
-(void)loadCellData:(NSArray *)cells;
-(void)saveCellData:(NSArray *)cells;
-(void)saveGameSettings:(BOOL)gameOver audio:(BOOL)audioOn hours:(int)hrs minutes:(int)mins seconds:(int)secs currentLevel:(int)level;
-(BOOL)getGameSettingsAudio;
-(BOOL)getGameSettingsGameOver;
-(int)getGameSettingsTimerHours;
-(int)getGameSettingsTimerMinutes;
-(int)getGameSettingsTimerSeconds;
-(int)getGameSettingsCurrentLevel;
-(bool)isDataStored;

-(NSManagedObjectContext*)managedObjectContext;
-(NSPersistentStoreCoordinator*)coordinator;
-(NSURL*)applicationDocumentsDirectory;
-(NSManagedObjectModel*)managedObjectModel;
@end
