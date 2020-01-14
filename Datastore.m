//
//  Datastore.m
//  Class Timer
//
//  Created by David Figge on 12/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Datastore.h"

@implementation Datastore

-(id)init {
	return [self init:@"settings"];
}

-(id)init:(NSString*)entity {
	self = [super init];
	if (self) {
		entityName = entity;
		dataFileName = [NSString stringWithFormat:@"%@.sqlite",entity];
		settingsArray = nil;
	}
	return self;
}

-(NSManagedObjectContext*)managedObjectContext {
	static NSManagedObjectContext* context = nil;
	if (context == nil) {
		context = [[NSManagedObjectContext alloc] init];
		[context setPersistentStoreCoordinator:[self coordinator]];
	}
	return context;
}

-(NSPersistentStoreCoordinator*)coordinator {
	static NSPersistentStoreCoordinator* coordinator = nil;
	if (coordinator != nil)
		return coordinator;
	
	NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"settings.sqlite"];
	
	NSError* error = nil;
	
	coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
	if (![coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
		// Handle error appropriately, probably just defaulting properties
	}
	return coordinator;
}

-(NSURL*)applicationDocumentsDirectory {
	return [[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
}

-(NSManagedObjectModel*)managedObjectModel {
	static NSManagedObjectModel* objectModel = nil;
	if (objectModel == nil) {
		NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Sudoku_Basic" withExtension:@"momd"];
		objectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
	}
	return objectModel;
}

-(void)saveCellData:(NSArray*)cells {
	[self getCellRecords];				// Put cell records into cellArray
	for (Cell* cell in cells) {
		int index = cell.squareNum;
		CellData* cd = [cellArray objectAtIndex:index];
		[cd setCellNum:[NSNumber numberWithShort:cell.squareNum]];
		[cd setCellMode:[NSNumber numberWithShort:cell.cellMode]];
		[cd setCellValue:[NSNumber numberWithShort:cell.value]];
		[cd setCorrectValue:[NSNumber numberWithShort:cell.correctValue]];
		[cd setPencilMarks0:[NSNumber numberWithShort:[cell pencilMark:0]]];
		[cd setPencilMarks1:[NSNumber numberWithShort:[cell pencilMark:1]]];
		[cd setPencilMarks2:[NSNumber numberWithShort:[cell pencilMark:2]]];
		[cd setPencilMarks3:[NSNumber numberWithShort:[cell pencilMark:3]]];
		[cd setPencilMarks4:[NSNumber numberWithShort:[cell pencilMark:4]]];
		[cd setPencilMarks5:[NSNumber numberWithShort:[cell pencilMark:5]]];
		[cd setPencilMarks6:[NSNumber numberWithShort:[cell pencilMark:6]]];
		[cd setPencilMarks7:[NSNumber numberWithShort:[cell pencilMark:7]]];
		[cd setPencilMarks8:[NSNumber numberWithShort:[cell pencilMark:8]]];
		[cd setPencilMarks9:[NSNumber numberWithShort:[cell pencilMark:9]]];
		[cd setUserPencil0:[NSNumber numberWithShort:[cell userPencilMark:0]]];
		[cd setUserPencil1:[NSNumber numberWithShort:[cell userPencilMark:1]]];
		[cd setUserPencil2:[NSNumber numberWithShort:[cell userPencilMark:2]]];
		[cd setUserPencil3:[NSNumber numberWithShort:[cell userPencilMark:3]]];
		[cd setUserPencil4:[NSNumber numberWithShort:[cell userPencilMark:4]]];
		[cd setUserPencil5:[NSNumber numberWithShort:[cell userPencilMark:5]]];
		[cd setUserPencil6:[NSNumber numberWithShort:[cell userPencilMark:6]]];
		[cd setUserPencil7:[NSNumber numberWithShort:[cell userPencilMark:7]]];
		[cd setUserPencil8:[NSNumber numberWithShort:[cell userPencilMark:8]]];
		[cd setUserPencil9:[NSNumber numberWithShort:[cell userPencilMark:9]]];
	}
	[self saveAllRecords];
}

-(void)loadCellData:(NSArray*)cells {
	[self getCellRecords];
	int index = 0;
	for (CellData* cd in cellArray) {
		index = [[cd cellNum] shortValue];
		Cell* cell = [cells objectAtIndex:index];
		[cell setSquareNum:index];
		[cell setCellMode:[[cd cellMode]shortValue]];
		[cell setValue:[[cd cellValue]shortValue]];
		[cell setCorrectValue:[[cd correctValue]shortValue]];
		[cell setPencilMark:0 toValue:[[cd pencilMarks0]shortValue]];
		[cell setPencilMark:1 toValue:[[cd pencilMarks1]shortValue]];
		[cell setPencilMark:2 toValue:[[cd pencilMarks2]shortValue]];
		[cell setPencilMark:3 toValue:[[cd pencilMarks3]shortValue]];
		[cell setPencilMark:4 toValue:[[cd pencilMarks4]shortValue]];
		[cell setPencilMark:5 toValue:[[cd pencilMarks5]shortValue]];
		[cell setPencilMark:6 toValue:[[cd pencilMarks6]shortValue]];
		[cell setPencilMark:7 toValue:[[cd pencilMarks7]shortValue]];
		[cell setPencilMark:8 toValue:[[cd pencilMarks8]shortValue]];
		[cell setPencilMark:9 toValue:[[cd pencilMarks9]shortValue]];
		[cell setUserPencilMark:0 toValue:[[cd userPencil0]shortValue]];
		[cell setUserPencilMark:1 toValue:[[cd userPencil1]shortValue]];
		[cell setUserPencilMark:2 toValue:[[cd userPencil2]shortValue]];
		[cell setUserPencilMark:3 toValue:[[cd userPencil3]shortValue]];
		[cell setUserPencilMark:4 toValue:[[cd userPencil4]shortValue]];
		[cell setUserPencilMark:5 toValue:[[cd userPencil5]shortValue]];
		[cell setUserPencilMark:6 toValue:[[cd userPencil6]shortValue]];
		[cell setUserPencilMark:7 toValue:[[cd userPencil7]shortValue]];
		[cell setUserPencilMark:8 toValue:[[cd userPencil8]shortValue]];
		[cell setUserPencilMark:9 toValue:[[cd userPencil9]shortValue]];
		index++;
	}
}

-(void)saveGameSettings:(BOOL)gameOver audio:(BOOL)audioOn hours:(int)hrs minutes:(int)mins seconds:(int)secs currentLevel:(int)level {
	GameSettings *gs = [self getSettingsRecord];
	[gs setGameOver:[NSNumber numberWithBool:gameOver]];
	[gs setAudioOnOff:[NSNumber numberWithBool:audioOn]];
	[gs setTimerHours:[NSNumber numberWithShort:hrs]];
	[gs setTimerMin:[NSNumber numberWithShort:mins]];
	[gs setTimerSec:[NSNumber numberWithShort:secs]];
	[gs setCurrentLevel:[NSNumber numberWithShort:level]];
	[self saveAllRecords];
}

-(BOOL)getGameSettingsAudio {
	GameSettings* gs = [self getSettingsRecord];
	return [[gs audioOnOff] boolValue];
}

-(BOOL)getGameSettingsGameOver {
	GameSettings* gs = [self getSettingsRecord];
	return [[gs gameOver] boolValue];
}

-(int)getGameSettingsTimerHours {
	GameSettings* gs = [self getSettingsRecord];
	return [[gs timerHours] intValue];
}

-(int)getGameSettingsTimerMinutes {
	GameSettings* gs = [self getSettingsRecord];
	return [[gs timerMin] intValue];
}

-(int)getGameSettingsTimerSeconds {
	GameSettings* gs = [self getSettingsRecord];
	return [[gs timerSec] intValue];
}

-(int)getGameSettingsCurrentLevel {
	GameSettings* gs = [self getSettingsRecord];
	return [[gs currentLevel] intValue];
}

-(bool)isDataStored {
	if (settingsArray == nil) {
		NSFetchRequest* request = [[ NSFetchRequest alloc] init];			// Fetch request object
		NSEntityDescription* entity = [NSEntityDescription entityForName:@"GameSettings" inManagedObjectContext:[self managedObjectContext]];	// Description of desired entity
		[request setEntity:entity];											// Establish request
		NSError *error = nil;
		settingsArray = [[[self managedObjectContext] executeFetchRequest:request error:&error] mutableCopy];		// Make request from data store
		if ([settingsArray count] == 0) {
			return false;
		}
	}
	return true;
}

-(void*)getCellRecords {
	if (cellArray == nil) {
		NSFetchRequest* request = [[ NSFetchRequest alloc] init];			// Fetch request object
		NSEntityDescription* entity = [NSEntityDescription entityForName:@"CellData" inManagedObjectContext:[self managedObjectContext]];	// Description of desired entity
		[request setEntity:entity];											// Establish request
		NSError *error = nil;
		cellArray = [[[self managedObjectContext] executeFetchRequest:request error:&error] mutableCopy];		// Make request from data store
		if (cellArray == nil) {
			NSException* dsExc = [NSException exceptionWithName:@"DatastoreException" reason:@"Unable to read cells from data store" userInfo:nil];
			@throw dsExc;
		}
		[cellArray retain];
		if ([cellArray count] == 0) {
			for (int x = 0; x < 81; x++) {
				[cellArray addObject:[NSEntityDescription insertNewObjectForEntityForName:@"CellData" inManagedObjectContext:[self managedObjectContext]]];
			}
			[[self managedObjectContext] save:&error];
		}
	}
	return cellArray;	
}

-(void*)getSettingsRecord {
	if (settingsArray != nil && [settingsArray count] == 0) {
		[settingsArray release];
		settingsArray = nil;
	}
	if (settingsArray == nil) {
		NSFetchRequest* request = [[ NSFetchRequest alloc] init];			// Fetch request object
		NSEntityDescription* entity = [NSEntityDescription entityForName:@"GameSettings" inManagedObjectContext:[self managedObjectContext]];	// Description of desired entity
		[request setEntity:entity];											// Establish request
		NSError *error = nil;
		settingsArray = [[[self managedObjectContext] executeFetchRequest:request error:&error] mutableCopy];		// Make request from data store
		if (settingsArray == nil) {
			NSException* dsExc = [NSException exceptionWithName:@"DatastoreException" reason:@"Unable to read game settings from data store" userInfo:nil];
			@throw dsExc;
		}
		[settingsArray retain];
		if ([settingsArray count] == 0) {
			[settingsArray addObject:[NSEntityDescription insertNewObjectForEntityForName:@"GameSettings" inManagedObjectContext:[self managedObjectContext]]];
			[[self managedObjectContext] save:&error];
		}
	}
	return [settingsArray objectAtIndex:0];
}

-(void)saveAllRecords {
	NSError* error = nil;
	[[self managedObjectContext] save:&error];
	if (error != nil) {
		NSException* exc = [NSException exceptionWithName:@"DatastoreException" reason:[NSString stringWithFormat:@"Error during data save: %@",[error localizedDescription]] userInfo:nil];
		@throw exc;
	}
}
@end
