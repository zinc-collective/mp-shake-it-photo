//
//  BananaCameraImageCurve.h
//
//  Copyright 2010 Banana Camera Company. All rights reserved.
//

#import <UIKit/UIKit.h>

enum
{
    CURVE_NONE   = 0,
    CURVE_COLORS = 1 << 0,
    CURVE_RED    = 1 << 1,
    CURVE_GREEN  = 1 << 2,
    CURVE_BLUE   = 1 << 3,
    CURVE_ALPHA  = 1 << 4
};

@interface BananaCameraImageCurve : NSObject
{
	@private
	int			_numPoints;
	CGPoint*	_points;
	int			_numSamples;
	double*		_samples;
	BOOL		_identity;
	UIColor*	_curveColor;
	
	uint		_pixels[256];				// 1K buffer
	BOOL		_preprocessed;
}

@property(nonatomic) int numPoints;
@property(nonatomic, strong) UIColor* curveColor;
@property(nonatomic, readonly) BOOL identity;
@property(nonatomic, readonly) BOOL preprocessed;

+ (NSArray*) imageCurvesFromACV: (NSString*) path;

- (id) init;
- (void) dealloc;

- (void) setNumPoints: (int) numPoints;
- (void) setNumSamples: (int) numSamples;
- (int) getClosestPoint: (double) x;
- (void) setPoint: (int) point xValue: (double) x yValue: (double) y;
- (void) setPoint: (int) point xValue: (double) x yValue: (double) y recalculate: (BOOL) flag;
- (void) movePoint: (int) point yValue: (double) y;
- (void) getPoint: (int) point xValue: (double*) outX yValue: (double*) outY;
- (void) setCurveXValue: (double) x yValue: (double) y;
- (void) resetToIdentity;
- (void) calculate;
- (void) plotCurveP1: (int) p1 p2: (int) p2 p3: (int) p3 p4: (int) p4;
- (void) dirty;

- (double) mapValue: (double) value;
- (uint) mapPixelValue: (uint) pixelValue;
- (void) preprocessCurve;

@end

#define ROUND(x) ((int) ((x) + 0.5))
#define SQR(x) ((x) * (x))
#define CLAMP(x,l,u) ((x)<(l)?(l):((x)>(u)?(u):(x)))

/* Limit a (0->511) int to 255 */
#define MAX255(a)  ((a) | (((a) & 256) - (((a) & 256) >> 8)))

/* Clamp a >>int32<<-range int between 0 and 255 inclusive */
#define CLAMP0255(a)  CLAMP(a,0,255)

#define DEG2RAD(angle) ((angle) * (2.0 * M_PI) / 360.0)
#define RAD2DEG(angle) ((angle) * 360.0 / (2.0 * M_PI))
