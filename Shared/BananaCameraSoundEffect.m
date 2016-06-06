//
//  BananaCameraSoundEffect.m
//
//  Copyright Banana Camera Company 2010. All rights reserved.
//

#import "BananaCameraSoundEffect.h"

@implementation BananaCameraSoundEffect

- (id) initWithContentsOfFile: (NSString*) audioFile
{
    self = [super init];
    if( self )
    {
        NSURL*  audioURL = [NSURL fileURLWithPath: audioFile];
        OSStatus err = AudioServicesCreateSystemSoundID( (CFURLRef)audioURL, &soundID );
        if( err != noErr )
        {
            [self release];
            self = nil;
        }
    }
    
    return( self );
}

- (void) dealloc
{
    if( soundID )
        AudioServicesDisposeSystemSoundID( soundID );
    
    [super dealloc];
}

- (void) play
{
    AudioServicesPlaySystemSound( soundID );
}

@end
