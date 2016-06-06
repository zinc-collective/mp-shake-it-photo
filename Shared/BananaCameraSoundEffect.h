//
//  BananaCameraSoundEffect.h
//
//  Copyright Banana Camera Company 2010. All rights reserved.
//

#import <AudioToolbox/AudioServices.h>

@interface BananaCameraSoundEffect : NSObject 
{
    @private
    SystemSoundID   soundID;
}

- (id) initWithContentsOfFile: (NSString*) audioFile;
- (void) dealloc;

- (void) play;

@end
