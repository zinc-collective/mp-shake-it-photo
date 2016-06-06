//
//  RoundedRectView.mm
//  BananaCamera
//
//  Copyright 2011 Banana Camera Company. All rights reserved.
//

#import "RoundedRectView.h"


@implementation RoundedRectView


- (id)initWithFrame: (CGRect)frame 
{    
    if((self = [super initWithFrame:frame]))
    {
    }
    return self;
}

- (void) drawRect: (CGRect) rect 
{
	CGContextRef ctx = UIGraphicsGetCurrentContext();
    
	CGRect fillFrame = CGRectInset(self.bounds, 20.0, 20.0);
	CGRect strokeFrame = CGRectInset(self.bounds, 20.0, 20.0);
	CGPathRef fillPath = [self newPathForRoundedRect: fillFrame radius: 10 ];
	CGPathRef strokePath = [self newPathForRoundedRect: strokeFrame radius: 10 ];
    
	CGContextAddPath(ctx, fillPath);
    CGContextSetRGBFillColor(ctx, 1.0, 1.0, 1.0, 1.0);
    CGContextFillPath(ctx);

	CGContextAddPath(ctx, strokePath);
    CGContextSetRGBStrokeColor(ctx, 0.67, 0.67, 0.67, 1.0);
    CGContextSetLineWidth(ctx, 1.0);
    CGContextStrokePath(ctx);
    
    CGPathRelease(strokePath);
    CGPathRelease(fillPath);
}

- (CGPathRef) newPathForRoundedRect: (CGRect) rect radius: (CGFloat) radius
{
	CGMutablePathRef retPath = CGPathCreateMutable();
    
	CGRect innerRect = CGRectInset(rect, radius, radius);
    
	CGFloat inside_right = innerRect.origin.x + innerRect.size.width;
	CGFloat outside_right = rect.origin.x + rect.size.width;
	CGFloat inside_bottom = innerRect.origin.y + innerRect.size.height;
	CGFloat outside_bottom = rect.origin.y + rect.size.height;
    
	CGFloat inside_top = innerRect.origin.y;
	CGFloat outside_top = rect.origin.y;
	CGFloat outside_left = rect.origin.x;
    
	CGPathMoveToPoint(retPath, NULL, innerRect.origin.x, outside_top);
    
	CGPathAddLineToPoint(retPath, NULL, inside_right, outside_top);
	CGPathAddArcToPoint(retPath, NULL, outside_right, outside_top, outside_right, inside_top, radius);
	CGPathAddLineToPoint(retPath, NULL, outside_right, inside_bottom);
	CGPathAddArcToPoint(retPath, NULL,  outside_right, outside_bottom, inside_right, outside_bottom, radius);
    
	CGPathAddLineToPoint(retPath, NULL, innerRect.origin.x, outside_bottom);
	CGPathAddArcToPoint(retPath, NULL,  outside_left, outside_bottom, outside_left, inside_bottom, radius);
	CGPathAddLineToPoint(retPath, NULL, outside_left, inside_top);
	CGPathAddArcToPoint(retPath, NULL,  outside_left, outside_top, innerRect.origin.x, outside_top, radius);
    
	CGPathCloseSubpath(retPath);
    
	return retPath;
}

@end
