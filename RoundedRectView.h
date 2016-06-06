//
//  RoundedRectView.h
//  BananaCamera
//
//  Copyright 2011 Banana Camera Company. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RoundedRectView : UIView 
{
}

- (CGPathRef) newPathForRoundedRect: (CGRect) rect radius: (CGFloat) radius;

@end
