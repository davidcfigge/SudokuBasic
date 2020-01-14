//
//  SoundEffect.h
//  Slider
//
//  Created by David Figge on 11/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioServices.h>


@interface SoundEffect : NSObject {
	SystemSoundID soundID;
}

-(id)initWithFile:(NSString*)filename;
-(void)Play;
+(void)SoundOn;
+(void)SoundOff;
+(void)ToggleSound;
+(BOOL)SoundState;

@end
