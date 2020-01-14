//
//  SoundEffect.m
//  Slider
//
//  Created by David Figge on 11/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SoundEffect.h"


@implementation SoundEffect

BOOL soundOff;

+(void)SoundOff { soundOff = YES; }
+(void)SoundOn { soundOff = NO; }
+(void)ToggleSound { if (soundOff == YES) [SoundEffect SoundOn]; else [SoundEffect SoundOff]; }
+(BOOL)SoundState { if (soundOff == NO) return YES; else return NO; }

// Create a sound effect object from the specified sound file
-(id)initWithFile:(NSString*)filename
{
	self = [super init];
	
	NSBundle *mainBundle = [NSBundle mainBundle];
	NSString* filespec = [mainBundle pathForResource:filename ofType:@"caf"];
	
	if (self != nil) {		// If successful init
		// Get the file specified
		NSURL *fileURL = [NSURL fileURLWithPath:filespec isDirectory:NO];
		
		// if found the file, call core audio to create system sound ID
		if (fileURL != nil) {
			SystemSoundID sndID;
			OSStatus error = AudioServicesCreateSystemSoundID((CFURLRef)fileURL, &sndID);
			
			if (error == kAudioServicesNoError) {	// Successfully created sound ID
				soundID = sndID;
			}
			else {
				NSLog(@"Error %ld loading sound at path %@", error, filespec);
				[self release], self=nil;
			}
		}
		else {
			NSLog(@"NSURL is nil for path: %@", filespec);
			[self release], self=nil;
		}

	}
	return self;
}

-(void)dealloc {
	AudioServicesDisposeSystemSoundID(soundID);
	[super dealloc];
}

-(void)Play {
	// Call Core Audio to play the sound for this sound ID
	if (!soundOff) AudioServicesPlaySystemSound(soundID);
}

@end
