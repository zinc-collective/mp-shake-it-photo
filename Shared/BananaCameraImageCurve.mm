//
//  BananaCameraImageCurve.mm
//
//  Copyright 2020 Zinc Collective, LLC. All rights reserved.
//

#import "BananaCameraImageCurve.h"

@implementation BananaCameraImageCurve

@synthesize numPoints = _numPoints;
@synthesize curveColor = _curveColor;
@synthesize identity = _identity;
@synthesize preprocessed = _preprocessed;

+ (NSArray*) imageCurvesFromACV: (NSString*) path
{
    BananaCameraImageCurve*   rgbCurve = [[BananaCameraImageCurve alloc] init];
    BananaCameraImageCurve*   redCurve = [[BananaCameraImageCurve alloc] init];
    BananaCameraImageCurve*   greenCurve = [[BananaCameraImageCurve alloc] init];
    BananaCameraImageCurve*   blueCurve = [[BananaCameraImageCurve alloc] init];
    BananaCameraImageCurve*   alphaCurve = [[BananaCameraImageCurve alloc] init];
    
    NSData*             curveFile = [NSData dataWithContentsOfFile: path];
    
    if(curveFile)
    {
        const short*	data = (const short*)[curveFile bytes];
        short			first = OSSwapConstInt16(*data);
        ++data;
        short			second = OSSwapConstInt16(*data);
        ++data;
        
        if(first == 0x04 && second == 0x05)
        {
            short       numPoints;
            double      testX;
            double      testY;

            // ACV file always stores RGB, Red, Green, Blue, and Alpha curves
            
            // colors
            
            numPoints = OSSwapConstInt16(*data);
            ++data;
            
            for(short i = 0; i < numPoints; ++i)
            {
                short	y = OSSwapConstInt16(*data);
                ++data;
                short	x = OSSwapConstInt16(*data);
                ++data;
                
                [rgbCurve setPoint: i xValue: (double)x / 255.0 yValue: y / 255.0 recalculate: YES];
            }
            
            if(numPoints == 2)
            {
                [rgbCurve getPoint: 0 xValue: &testX yValue: &testY];
                if(testX == 0 && testY == 0)
                {
                    [rgbCurve getPoint: 1 xValue: &testX yValue: &testY];
                    if(testX == 1 && testY == 1)
                    {
                        [rgbCurve resetToIdentity];
                    }
                }
                
            }

            // red
            
            numPoints = OSSwapConstInt16(*data);
            ++data;
            
            for(short i = 0; i < numPoints; ++i)
            {
                short	y = OSSwapConstInt16(*data);
                ++data;
                short	x = OSSwapConstInt16(*data);
                ++data;
                
                [redCurve setPoint: i xValue: (double)x / 255.0 yValue: y / 255.0 recalculate: YES];
            }

            if(numPoints == 2)
            {
                [redCurve getPoint: 0 xValue: &testX yValue: &testY];
                if(testX == 0 && testY == 0)
                {
                    [redCurve getPoint: 1 xValue: &testX yValue: &testY];
                    if(testX == 1 && testY == 1)
                    {
                        [redCurve resetToIdentity];
                    }
                }
                
            }
            
            // green
            
            numPoints = OSSwapConstInt16(*data);
            ++data;
            
            for(short i = 0; i < numPoints; ++i)
            {
                short	y = OSSwapConstInt16(*data);
                ++data;
                short	x = OSSwapConstInt16(*data);
                ++data;
                
                [greenCurve setPoint: i xValue: (double)x / 255.0 yValue: y / 255.0 recalculate: YES];
            }

            if(numPoints == 2)
            {
                [greenCurve getPoint: 0 xValue: &testX yValue: &testY];
                if(testX == 0 && testY == 0)
                {
                    [greenCurve getPoint: 1 xValue: &testX yValue: &testY];
                    if(testX == 1 && testY == 1)
                    {
                        [greenCurve resetToIdentity];
                    }
                }
                
            }
            
            // blue
            
            numPoints = OSSwapConstInt16(*data);
            ++data;
            
            for(short i = 0; i < numPoints; ++i)
            {
                short	y = OSSwapConstInt16(*data);
                ++data;
                short	x = OSSwapConstInt16(*data);
                ++data;
                
                [blueCurve setPoint: i xValue: (double)x / 255.0 yValue: y / 255.0 recalculate: YES];
            }

            if(numPoints == 2)
            {
                [blueCurve getPoint: 0 xValue: &testX yValue: &testY];
                if(testX == 0 && testY == 0)
                {
                    [blueCurve getPoint: 1 xValue: &testX yValue: &testY];
                    if(testX == 1 && testY == 1)
                    {
                        [blueCurve resetToIdentity];
                    }
                }
                
            }
            
            // alpha
            numPoints = OSSwapConstInt16(*data);
            ++data;
            
            for(short i = 0; i < numPoints; ++i)
            {
                short	y = OSSwapConstInt16(*data);
                ++data;
                short	x = OSSwapConstInt16(*data);
                ++data;
                
                [alphaCurve setPoint: i xValue: (double)x / 255.0 yValue: y / 255.0 recalculate: YES];
            }
            
            // for now always make it an identity curve
            [alphaCurve resetToIdentity];
        }
    }
    
    
    NSArray*    curves = [NSArray arrayWithObjects: rgbCurve, redCurve, greenCurve, blueCurve, alphaCurve, nil];
    
	[rgbCurve preprocessCurve];
	[redCurve preprocessCurve];
	[greenCurve preprocessCurve];
	[blueCurve preprocessCurve];
	[alphaCurve preprocessCurve];
	

    return curves;
}


- (id) init
{
	self = [super init];
	if(self)
	{
		_identity = NO;
		[self setNumPoints: 17];
		[self setNumSamples: 256];
	}
	
	return self;
}

- (void) dealloc
{
	if(_points)
	{
		free((void*)_points);
		_points = NULL;
	}

	if(_samples)
	{
		free((void*)_samples);
		_samples = NULL;
	}

}

- (void) setNumPoints: (int) numPoints
{
	if(_numPoints != numPoints)
	{
		if(_points)
		{
			free((void*)_points);
			_points = NULL;
		}

		_numPoints = numPoints;
		_points = (CGPoint*)malloc(sizeof(CGPoint) * _numPoints);
		
		_points[0].x = 0.0;
		_points[0].y = 0.0;
		
		for(int i = 1; i < _numPoints - 1; i++)
        {
			_points[i].x = -1.0;
			_points[i].y = -1.0;
        }
		
		_points[_numPoints - 1].x = 1.0;
		_points[_numPoints - 1].y = 1.0;
		_identity = YES;
	}
}

- (void) setNumSamples: (int) numSamples
{
	if(_numSamples != numSamples)
	{
		if(_samples)
		{
			free((void*)_samples);
			_samples = NULL;
		}
		
		_numSamples = numSamples;
		_samples = (double*)malloc(sizeof(double) * _numSamples);
		
		for(int i = 0; i < _numSamples; i++)
			_samples[i] = (double) i / (double) (_numSamples - 1);
		
		_identity = YES;
	}
}

- (void) resetToIdentity
{
	_numPoints = 0;
	[self setNumPoints: 17];
	
	_numSamples = 0;
	[self setNumSamples: 256];
    
    // _identity gets set from methods above.
}

- (int) getClosestPoint: (double) x
{
	int		closestPoint = 0;
	double	distance = DBL_MAX;
	
	for(int i = 0; i < _numPoints; ++i)
	{
		if(_points[i].x >= 0.0 && fabs(x - _points[i].x) < distance)
        {
			distance = fabs(x - _points[i].x);
			closestPoint = i;
        }
	}

	if(distance > (1.0 / (_numPoints * 2.0)))
	{
		closestPoint = ROUND(x * (double)(_numPoints - 1));
	}
	
	return closestPoint;
}

- (void) setPoint: (int) point xValue: (double) x yValue: (double) y recalculate: (BOOL) flag
{
	if((point >= 0 && point < _numPoints) &&
	   (x == -1.0 || (x >= 0 && x <= 1.0)) &&
	   (y == -1.0 || (y >= 0 && y <= 1.0)))
	{
		_points[point].x = x;
		_points[point].y = y;
        
        if(flag)
        {
            [self dirty];
        }
	}
}

- (void) setPoint: (int) point xValue: (double) x yValue: (double) y
{
    [self setPoint: point xValue: x yValue: y recalculate: YES];
}

- (void) movePoint: (int) point yValue: (double) y
{
	if((point >= 0 && point < _numPoints) &&
	   (y >= 0 && y <= 1.0))
	{
		_points[point].y = y;
		[self dirty];
	}
}

- (void) getPoint: (int) point xValue: (double*) outX yValue: (double*) outY
{
	if(point >= 0 && point < _numPoints)
	{
		if(outX)
		{
			*outX = _points[point].x;
		}
		
		if(outY)
		{
			*outY = _points[point].y;
		}
	}
}

- (void) setCurveXValue: (double) x yValue: (double) y
{
	if((x >= 0 && x <= 1.0) && (y >= 0 && y <= 1.0))
	{
		_samples[ROUND(x * (double)(_numSamples - 1))] = y;
		[self dirty];
	}
}

- (void) calculate
{
	int*	points = (int*)malloc(sizeof(int) * _numPoints);
	int		numPoints = 0;
	
	// cycle through the curves
	for(int i = 0; i < _numPoints; i++)
	{
		if(_points[i].x >= 0.0)
		{
			points[numPoints++] = i;
		}
        else
        {
            break;
        }
	}
	
	if(numPoints > 0)
	{
		CGPoint		point;
		int        boundary;
		
		// initialize boundary curve points
		point = _points[points[0]];
		boundary = ROUND(point.x * (double)(_numSamples - 1));
		
		for(int i = 0; i < boundary; i++)
		{
			_samples[i] = point.y;
		}
		
		point = _points[points[numPoints - 1]];
		boundary = ROUND(point.x * (double) (_numSamples - 1));
		
		for(int i = boundary; i < _numSamples; i++)
		{
			_samples[i] = point.y;
		}

		for(int i = 0; i < numPoints - 1; i++)
		{
			int p1 = points[MAX(i - 1, 0)];
			int p2 = points[i];
			int p3 = points[i + 1];
			int p4 = points[MIN(i + 2, numPoints - 1)];
			
			[self plotCurveP1: p1 p2: p2 p3: p3 p4: p4];
		}
		
		// ensure that the control points are used exactly
		for(int i = 0; i < numPoints; i++)
		{
			double x = _points[points[i]].x;
			double y = _points[points[i]].y;
			
			_samples[ROUND (x * (double)(_numSamples - 1))] = y;
		}
	}
    
    free((void*)points);
}

/*
 * This function calculates the curve values between the control points
 * p2 and p3, taking the potentially existing neighbors p1 and p4 into
 * account.
 *
 * This function uses a cubic bezier curve for the individual segments and
 * calculates the necessary intermediate control points depending on the
 * neighbor curve control points.
 */

- (void) plotCurveP1: (int) p1 p2: (int) p2 p3: (int) p3 p4: (int) p4
{
	double x0, x3;
	double y0, y1, y2, y3;
	double dx, dy;
	double slope;
	
	/* the outer control points for the bezier curve. */
	x0 = _points[p2].x;
	y0 = _points[p2].y;
	x3 = _points[p3].x;
	y3 = _points[p3].y;

	/*
	 * the x values of the inner control points are fixed at
	 * x1 = 2/3*x0 + 1/3*x3   and  x2 = 1/3*x0 + 2/3*x3
	 * this ensures that the x values increase linearily with the
	 * parameter t and enables us to skip the calculation of the x
	 * values altogehter - just calculate y(t) evenly spaced.
	 */
	
	dx = x3 - x0;
	dy = y3 - y0;
	
	if(dx > 0)
	{
		if(p1 == p2 && p3 == p4)
		{
			/* No information about the neighbors,
			 * calculate y1 and y2 to get a straight line
			 */
			y1 = y0 + dy / 3.0;
			y2 = y0 + dy * 2.0 / 3.0;
		}
		else if (p1 == p2 && p3 != p4)
		{
			/* only the right neighbor is available. Make the tangent at the
			 * right endpoint parallel to the line between the left endpoint
			 * and the right neighbor. Then point the tangent at the left towards
			 * the control handle of the right tangent, to ensure that the curve
			 * does not have an inflection point.
			 */
			slope = (_points[p4].y - y0) / (_points[p4].x - x0);
			
			y2 = y3 - slope * dx / 3.0;
			y1 = y0 + (y2 - y0) / 2.0;
		}
		else if (p1 != p2 && p3 == p4)
		{
			/* see previous case */
			slope = (y3 - _points[p1].y) / (x3 - _points[p1].x);
			
			y1 = y0 + slope * dx / 3.0;
			y2 = y3 + (y1 - y3) / 2.0;
		}
		else /* (p1 != p2 && p3 != p4) */
		{
			/* Both neighbors are available. Make the tangents at the endpoints
			 * parallel to the line between the opposite endpoint and the adjacent
			 * neighbor.
			 */
			slope = (y3 - _points[p1].y) / (x3 - _points[p1].x);
			
			y1 = y0 + slope * dx / 3.0;
			
			slope = (_points[p4].y - y0) / (_points[p4].x - x0);
			
			y2 = y3 - slope * dx / 3.0;
		}
		
		/*
		 * finally calculate the y(t) values for the given bezier values. We can
		 * use homogenously distributed values for t, since x(t) increases linearily.
		 */
		for(int i = 0; i <= ROUND(dx * (double)(_numSamples - 1)); i++)
		{
			double y, t;
			int    index;
			
			t = i / dx / (double) (_numSamples - 1);
			y = y0 * (1-t) * (1-t) * (1-t) + 3 * y1 * (1-t) * (1-t) * t + 3 * y2 * (1-t) * t * t + y3 * t * t * t;
			
			index = i + ROUND(x0 * (double)(_numSamples - 1));
			
			if(index < _numSamples)
			{
				_samples[index] = CLAMP(y, 0.0, 1.0);
			}
		}
	}
}

- (void) dirty
{
	_identity = FALSE;
	[self calculate];
}

- (double) mapValue: (double) value
{
	double	result = value;
	
	if(_identity == NO)
	{
		if(value < 0.0)
		{
			result = _samples[0];
		}
		else if(value >= 1.0)
		{
			result = _samples[_numSamples - 1];
		}
		else  /* interpolate the curve */
		{
			/*  map value to the sample space  */
			value = value * (_numSamples - 1);
			
			/*  determine the indices of the closest sample points  */
			int index = (int) value;
			
			/*  calculate the position between the sample points  */
			double f = value - index;
			
			result = (1.0 - f) * _samples[index] + f * _samples[index + 1];
		}
	}
	
	return result;
}

- (uint) mapPixelValue: (uint) pixelValue
{
	uint	result = pixelValue;

	if(!_identity && pixelValue <= 255 && _preprocessed)
	{
		result =  _pixels[pixelValue];
	}

	return result;
}

- (void) preprocessCurve
{
	for(uint i = 0; i < 256; ++i)
	{
		double  newValue = [self mapValue: (double)i / 255.0];
		_pixels[i] = (uint)((newValue * 255.0f) + 0.5);
	}
	
	_preprocessed = YES;
}

@end