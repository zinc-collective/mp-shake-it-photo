//
//  BananaCameraGrowlView.mm
//
//  Copyright Banana Camera Company 2010. All rights reserved.
//

#import "BananaCameraGrowlView.h"
#import "BananaCameraUtilities.h"
#import <QuartzCore/QuartzCore.h>

@implementation BananaCameraGrowlView

static const NSTimeInterval	kRevealAnimationDuration = 1.0;
static const NSTimeInterval	kDismissAnimationDuration = 1.5;

@synthesize	notificationDuration = _notificationDuration;

- (id) initWithFrame: (CGRect) frame 
{
    if((self = [super initWithFrame:frame]))
	{
		_notificationDuration = 2.5;
		
		// set up a rounded border
		CALayer*	layer = [self layer];
		
		// clear the view's background color so that our background
		// fits within the rounded border
		self.backgroundColor = [UIColor clearColor];
		layer.backgroundColor = [UIColor grayColor].CGColor;
		
		layer.borderWidth = 0.0f;
		layer.cornerRadius = 12.0f;
		
		_textLabel = [[UILabel alloc] initWithFrame: self.layer.frame];
		_textLabel.backgroundColor = [UIColor clearColor];
		_textLabel.textColor = [UIColor whiteColor];
		_textLabel.font = [UIFont systemFontOfSize: 18.0];
		_textLabel.textAlignment = NSTextAlignmentCenter;
		
		[self addSubview: _textLabel];
	}
	
	return self;
}

- (void) beginNotificationInViewController: (UIViewController*) vc withNotification: (NSString*) notification
{
	_textLabel.text = notification;
	[_textLabel sizeToFit];
	_textLabel.frame = CenterRectOverRect(_textLabel.frame, self.frame);
	[_textLabel setNeedsDisplay];
	
	self.alpha = 0.0;
	self.frame = CenterRectOverRect(self.frame, vc.view.frame);
	[vc.view addSubview: self];
	
	[UIView beginAnimations: @"notification_begin" context: NULL];
	[UIView setAnimationDuration: kRevealAnimationDuration];
	[UIView setAnimationDelegate: self];
	[UIView setAnimationDidStopSelector: @selector(_animationDidStop:finished:context:)];
	self.alpha = 0.8;
	[UIView commitAnimations];
}

- (void) _endNotification
{
	[UIView beginAnimations: @"notification_end" context: NULL];
	[UIView setAnimationDuration: kDismissAnimationDuration];
	[UIView setAnimationDelegate: self];
	[UIView setAnimationDidStopSelector: @selector(_animationDidStop:finished:context:)];
	self.alpha = 0.0;
	[UIView commitAnimations];
}

- (void) _animationDidStop: (NSString*) animationID finished: (NSNumber*) finished context: (void*) context
{
	if([animationID isEqualToString: @"notification_begin"])
	{
		[self performSelector: @selector(_endNotification) withObject: nil afterDelay: self.notificationDuration];
	}
	else if([animationID isEqualToString: @"notification_end"])
	{
		[self removeFromSuperview];
		[self release];
	}
}

- (void) dealloc
{
	ReleaseAndClear(_textLabel);
	[super dealloc];
}

@end
