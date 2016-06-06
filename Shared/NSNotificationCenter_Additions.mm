//
//  NSNotificationCenter_Additions.mm
//
//  Copyright Banana Camera Company 2010. All rights reserved.
//

#import "NSNotificationCenter_Additions.h"

@implementation NSNotificationCenter (MainThread)

- (void) postNotificationOnMainThread: (NSNotification*) notification
{
	[self performSelectorOnMainThread: @selector(postNotification:) withObject: notification waitUntilDone: YES];
}

- (void) postNotificationOnMainThreadName: (NSString*) aName object: (id) anObject
{
	NSNotification* notification = [NSNotification notificationWithName: aName object: anObject];
	[self postNotificationOnMainThread: notification];
}

- (void) postNotificationOnMainThreadName: (NSString*) aName object: (id) anObject userInfo: (NSDictionary*) aUserInfo
{
	NSNotification* notification = [NSNotification notificationWithName: aName object: anObject userInfo: aUserInfo];
	[self postNotificationOnMainThread: notification];
}

@end