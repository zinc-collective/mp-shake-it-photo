//
//  BananaCameraUtilities.mm
//
//  Copyright 2010 Banana Camera Company. All rights reserved.
//

#import "BananaCameraUtilities.h"

void LogTiming(NSString* message, uint64_t startTime, uint64_t endTime)
{
    static double conversion = 0.0;
    
    if( conversion == 0.0 )
    {
        mach_timebase_info_data_t info;
        mach_timebase_info(&info);
		conversion = 1e-9 * (double)info.numer / (double)info.denom;
    }
    
    NSLog(@"%@: %e", message, (endTime - startTime) * conversion);
}

CGRect CenterRectOverRect(CGRect a, CGRect b)
{
	CGPoint	centerB;
	CGPoint centerA;
	
	centerB = CGPointMake(CGRectGetMidX(b), CGRectGetMidY(b));
	centerA = CGPointMake(CGRectGetMidX(a), CGRectGetMidY(a));
	
	return CGRectOffset(a, centerB.x - centerA.x, centerB.y - centerA.y);
}

CGSize FitSizeWithSize2(CGSize sizeToFit, CGSize sizeToFitInto)
{
	CGSize	result = sizeToFit;
	
	if(sizeToFit.width < sizeToFit.height)
	{
		CGFloat		scale = sizeToFitInto.width / sizeToFit.width;
		result.width = sizeToFit.width * scale;
		result.height = sizeToFit.height * scale;
		
		while(result.height < sizeToFitInto.height)
		{
			scale += 0.1;
			result.width = sizeToFit.width * scale;
			result.height = sizeToFit.height * scale;
		}
	}
	else
	{
		CGFloat		scale = sizeToFitInto.height / sizeToFit.height;
		result.width = sizeToFit.width * scale;
		result.height = sizeToFit.height * scale;
		
		while(result.width < sizeToFitInto.width)
		{
			scale += 0.1;
			result.width = sizeToFit.width * scale;
			result.height = sizeToFit.height * scale;
		}
	}
	
	result.width = RoundEven(result.width);
	result.height = RoundEven(result.height);
	
	return result;
}

CGSize FitSizeWithSize(CGSize sizeToFit, CGSize sizeToFitInto)
{
	CGFloat	srcAspect = sizeToFit.width / sizeToFit.height;
	CGFloat	dstAspect = sizeToFitInto.width / sizeToFitInto.height;
	
	CGSize	result = sizeToFit;
	
	if(fabs(srcAspect - dstAspect) < 0.01)
	{
		// Aspects are close enough
		result = sizeToFitInto;
	}
	else 
	{
		CGFloat scale = (sizeToFitInto.width / sizeToFit.width);
		if(sizeToFit.height * scale > sizeToFitInto.height)
		{
			scale = sizeToFitInto.height / sizeToFit.height;
		}

		result = CGSizeMake(RoundEven(sizeToFit.width * scale), RoundEven(sizeToFit.height * scale));
		
		while(result.width < sizeToFitInto.width || result.height < sizeToFitInto.height)
		{
			scale += 0.01;
			result = CGSizeMake(RoundEven(sizeToFit.width * scale), RoundEven(sizeToFit.height * scale));
		}
	}

	return result;
}

CGFloat RoundEven(CGFloat a)
{
	long int	result = lrintf(a);
	
	if(result % 2 )
		result += 1;
	
	return((CGFloat)result);
}

CGColorRef CreateDeviceGrayColor(CGFloat w, CGFloat a)
{
    CGColorSpaceRef gray = CGColorSpaceCreateDeviceGray();
    CGFloat comps[] = {w, a};
    CGColorRef color = CGColorCreate(gray, comps);
    CGColorSpaceRelease(gray);
    return color;
}

CGColorRef CreateDeviceRGBColor(CGFloat r, CGFloat g, CGFloat b, CGFloat a)
{
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    CGFloat comps[] = {r, g, b, a};
    CGColorRef color = CGColorCreate(rgb, comps);
    CGColorSpaceRelease(rgb);
    return color;
}
