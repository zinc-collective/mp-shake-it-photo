//
//  CALayer_Additions.mm
//
//  Copyright Banana Camera Company 2010. All rights reserved.
//

#import "CALayer_Additions.h"

@implementation CALayer(Additions)

- (void) pauseAnimation
{
	CFTimeInterval pausedTime = [self convertTime:CACurrentMediaTime() fromLayer:nil];
	self.speed = 0.0;
	self.timeOffset = pausedTime;
}

- (void) resumeAnimation
{
	CFTimeInterval pausedTime = [self timeOffset];
	self.speed = 1.0;
	self.timeOffset = 0.0;
	self.beginTime = 0.0;
	CFTimeInterval timeSincePause = [self convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
	self.beginTime = timeSincePause;
}

- (BOOL) isPaused
{
	return self.timeOffset != 0.0;
}

@end
