//
//  CALayer_Additions.h
//
//  Copyright Banana Camera Company 2010. All rights reserved.
//

#import <QuartzCore/CALayer.h>

@interface CALayer(Additions)

- (void) pauseAnimation;
- (void) resumeAnimation;
- (BOOL) isPaused;

@end
