//
//  NSNotificationCenter_Additions.h
//
//  Copyright Banana Camera Company 2010. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNotificationCenter(MainThread)

- (void) postNotificationOnMainThread: (NSNotification*) notification;
- (void) postNotificationOnMainThreadName: (NSString*) aName object: (id) anObject;
- (void) postNotificationOnMainThreadName: (NSString*) aName object: (id) anObject userInfo: (NSDictionary*) aUserInfo;

@end
