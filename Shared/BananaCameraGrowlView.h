//
//  BananaCameraGrowlView.h
//
//  Copyright Banana Camera Company 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BananaCameraGrowlView : UIView 
{
	@private
	UILabel*		_textLabel;
	NSTimeInterval	_notificationDuration;
}

@property(assign) NSTimeInterval	notificationDuration;

- (void) beginNotificationInViewController: (UIViewController*) vc withNotification: (NSString*) notification;

- (void) _endNotification;
- (void) _animationDidStop: (NSString*) animationID finished: (NSNumber*) finished context: (void*) context;

@end
