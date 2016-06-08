//
//  BananaCameraImage.mm
//
//  Copyright 2010 Banana Camera Company. All rights reserved.
//

#import "BananaCameraImage.h"
#import "BananaCameraImageCurve.h"
#import "BananaCameraUtilities.h"

@implementation BananaCameraImage

@synthesize context = _contextRef;
//@synthesize bytes = _rawBytes;
@synthesize size = _size;
@synthesize bufferSize = _bufferSize;
@synthesize imagePath = _imagePath;
@synthesize orientation = _orientation;
@synthesize renderRect = _renderRect;

+ (CGColorSpaceRef) deviceRGBColorSpace
{
    static CGColorSpaceRef  sColorspace = nil;
    
    if(!sColorspace)
    {
        sColorspace = CGColorSpaceCreateDeviceRGB();
    }
    
    return sColorspace;
}

+ (CGColorRef) genericGrayColor80
{
    static CGColorRef   sGenericGrayColor80;
    
    if(!sGenericGrayColor80)
    {
        sGenericGrayColor80 = CreateDeviceGrayColor(0.8, 0.2);
    }
    
    return sGenericGrayColor80;
}

+ (BananaCameraImage*) imageWithSize: (CGSize) size orientation: (UIImageOrientation) orientation
{
    BananaCameraImage*     image = [[BananaCameraImage alloc] initWithSize: size 
																 colorSpace: [BananaCameraImage deviceRGBColorSpace]
																orientation: orientation];
    return [image autorelease];
}

- (id) initWithImage: (UIImage*) image size: (CGSize) size imageRect: (CGRect) imageRect
{
	self = [super init];
	if(self)
	{
		_size = size;
		_orientation = image.imageOrientation;
        //_bufferSize = _size.width * 4 * _size.height;
        //_rawBytes = (unsigned long*)calloc(sizeof(unsigned char), _bufferSize);
		
        _contextRef = CGBitmapContextCreate(NULL,
											_size.width, 
											_size.height, 
											8, 
											_size.width * 4, 
											[BananaCameraImage deviceRGBColorSpace], 
											kCGImageAlphaPremultipliedLast);
		
		[self pushContext];
		CGContextScaleCTM(_contextRef, 1.0, -1.0);
		CGContextTranslateCTM(_contextRef, 0, -_size.height);

		CGSize imageSize  = FitSizeWithSize(image.size, imageRect.size);
		CGRect renderRect = CenterRectOverRect(CGRectMake(0.0, 0.0, imageSize.width, imageSize.height), imageRect);
		_renderRect = renderRect;
        
		START_TIMING(renderFirst);
		[image drawInRect: renderRect blendMode: kCGBlendModeNormal alpha: 1.0];
		END_TIMING(renderFirst);
		
		START_TIMING(renderAgain);
		[image drawInRect: renderRect blendMode: kCGBlendModeOverlay alpha: 1.0];
		END_TIMING(renderAgain);		
		
        [self popContext];
	}
	
	return self;
}

- (id) initWithImage: (UIImage*) image size: (CGSize) size margin: (CGFloat) margin
{
	self = [super init];
	if(self)
	{
		_size = size;
		
		CGSize imageSize = image.size;
		imageSize = FitSizeWithSize(imageSize, CGSizeMake(size.width - margin * 2, size.height - margin * 2));
		
		_orientation = image.imageOrientation;
        //_bufferSize = _size.width * 4 * _size.height;
        //_rawBytes = (unsigned long*)calloc(sizeof(unsigned char), _bufferSize);
		
        _contextRef = CGBitmapContextCreate(NULL,
											_size.width, 
											_size.height, 
											8, 
											_size.width * 4, 
											[BananaCameraImage deviceRGBColorSpace], 
											kCGImageAlphaPremultipliedLast);
		
		[self pushContext];
		CGContextScaleCTM(_contextRef, 1.0, -1.0);
		CGContextTranslateCTM(_contextRef, 0, -_size.height);
		
		CGRect	imageRect = CenterRectOverRect(CGRectMake(0.0, 0.0, imageSize.width, imageSize.height), 
											   CGRectMake(0.0, 0.0, _size.width, _size.height));
		START_TIMING(renderFirst);
		[image drawInRect: imageRect blendMode: kCGBlendModeNormal alpha: 1.0];
		END_TIMING(renderFirst);

		START_TIMING(renderAgain);
		[image drawInRect: imageRect blendMode: kCGBlendModeOverlay alpha: 1.0];
		END_TIMING(renderAgain);		
		
		[self popContext];		
	}
	
	return self;
}

- (id) initWithSize: (CGSize) size colorSpace: (CGColorSpaceRef) colorspace orientation: (UIImageOrientation) orientation
{
    self = [super init];
    if(self)
    {
        uint            bytesPerRow = (size.width * 4);
        CGBitmapInfo    bitmapInfo = kCGImageAlphaPremultipliedLast;

        _size = size;
        //_bufferSize = bytesPerRow * size.height;
        //_rawBytes = (unsigned long*)calloc(sizeof(unsigned char), _bufferSize);
        _contextRef = CGBitmapContextCreate(NULL, size.width, size.height, 8, bytesPerRow, colorspace, bitmapInfo);
		_orientation = orientation;
    }
    
    return self;
}

- (void) dumpPixels
{
    CGContextRelease(_contextRef);
    _contextRef = NULL;
   
    /*
	if(_rawBytes)
	{
		free(_rawBytes);
		_rawBytes = NULL;
	}
    */
	
	if(_borderImageRef)
	{
		CGImageRelease(_borderImageRef);
		_borderImageRef = NULL;
	}
}

- (void) dealloc
{
	//NSLog(@"BananaCameraImage dealloced");
	
	[self dumpPixels];
	
	ReleaseAndClear(_imagePath);
    [super dealloc];
}

- (CGContextRef) pushContext
{
    if(_contextRef)
    {
        UIGraphicsPushContext(_contextRef);
        CGContextSaveGState(_contextRef);
    }
    
    return _contextRef;
}

- (void) popContext
{
    if(_contextRef) {
        CGContextRestoreGState(_contextRef);
        UIGraphicsPopContext();
    }
}

- (CGImageRef) CGImageRef
{
    CGImageRef  result = NULL;
    
    if(_contextRef) {
        result = CGBitmapContextCreateImage(_contextRef);
    }
    
    return result;
}

- (uint) curveApplyMask: (NSArray*) curves
{
    BananaCameraImageCurve*   rgbCurve = [curves objectAtIndex: 0];
    BananaCameraImageCurve*   redCurve = [curves objectAtIndex: 1];
    BananaCameraImageCurve*   greenCurve = [curves objectAtIndex: 2];
    BananaCameraImageCurve*   blueCurve = [curves objectAtIndex: 3];
    
    return ((rgbCurve.identity ? 0 : CURVE_COLORS) |
            (redCurve.identity ? 0 : CURVE_RED) |
            (greenCurve.identity ? 0 : CURVE_GREEN) |
            (blueCurve.identity ? 0 : CURVE_BLUE));
}


- (void) setBorderImage: (NSString*) imagePath
{
	if(_borderImageRef)
	{
		CGImageRelease(_borderImageRef);
		_borderImageRef = NULL;
	}
	
	NSURL*				fileURL = [NSURL fileURLWithPath: imagePath];
	CGDataProviderRef	dataProvider = CGDataProviderCreateWithURL((CFURLRef)fileURL);

	if(dataProvider)
	{
		_borderImageRef = CGImageCreateWithPNGDataProvider(dataProvider, NULL, false, kCGRenderingIntentDefault);
		CGDataProviderRelease(dataProvider);
	}
}

- (void) applyBorder
{
	if(_borderImageRef)
	{
		CGContextSaveGState(_contextRef);

		CGSize			borderImageSize = CGSizeMake(CGImageGetWidth(_borderImageRef), CGImageGetHeight(_borderImageRef));
		CGSize			imageSize = self.size;
		CGSize			tileSize = CGSizeMake(borderImageSize.width / 3, borderImageSize.height / 3);
		CGRect			tileRect;
		
		CGImageRef		bottomLeftTile = CGImageCreateWithImageInRect(_borderImageRef, CGRectMake(0, borderImageSize.height - tileSize.height, tileSize.width, tileSize.height));
		CGImageRef		topLeftTile = CGImageCreateWithImageInRect(_borderImageRef, CGRectMake(0, 0, tileSize.width, tileSize.height));
		CGImageRef		topRightTile = CGImageCreateWithImageInRect(_borderImageRef, CGRectMake(borderImageSize.width - tileSize.width, 0, tileSize.width, tileSize.height));
		CGImageRef		bottomRightTile = CGImageCreateWithImageInRect(_borderImageRef, CGRectMake(borderImageSize.width - tileSize.width, borderImageSize.height - tileSize.height, tileSize.width, tileSize.height));
		CGImageRef		topMiddleTile = CGImageCreateWithImageInRect(_borderImageRef, CGRectMake(tileSize.width, 0, tileSize.width, tileSize.height));
		CGImageRef		bottomMiddleTile = CGImageCreateWithImageInRect(_borderImageRef, CGRectMake(tileSize.width, borderImageSize.height - tileSize.height, tileSize.width, tileSize.height));
		CGImageRef		leftMiddleTile = CGImageCreateWithImageInRect(_borderImageRef, CGRectMake(0, tileSize.height, tileSize.width, tileSize.height));
		CGImageRef		rightMiddleTile = CGImageCreateWithImageInRect(_borderImageRef, CGRectMake(borderImageSize.width - tileSize.width, tileSize.height, tileSize.width, tileSize.height));
		
		// Draw the 4 corners
		
		tileRect = CGRectMake(0, 0, tileSize.width, tileSize.height);
		CGContextDrawImage(_contextRef, tileRect, bottomLeftTile);
		tileRect = CGRectOffset(tileRect, imageSize.width - tileSize.width, 0);
		CGContextDrawImage(_contextRef, tileRect, bottomRightTile);
		tileRect = CGRectOffset(tileRect, 0, imageSize.height - tileSize.height);
		CGContextDrawImage(_contextRef, tileRect, topRightTile);
		tileRect = CGRectOffset(tileRect, -(imageSize.width - tileSize.width), 0);
		CGContextDrawImage(_contextRef, tileRect, topLeftTile);
		
		// Draw top and bottom tiles
		
		{
			CGFloat		remainingWidth = imageSize.width - (tileSize.width * 2);
			int			iterations = (int)remainingWidth / (int)tileSize.width;
			int			leftOverWidth = (int)remainingWidth % (int)tileSize.width;
			
			tileRect = CGRectMake(tileSize.width, 0, tileSize.width, tileSize.height);
			
			for(int i = 0; i < iterations; ++i)
			{
				CGContextDrawImage(_contextRef, tileRect, bottomMiddleTile);
				tileRect = CGRectOffset(tileRect, 0, imageSize.height - tileSize.height);
				CGContextDrawImage(_contextRef, tileRect, topMiddleTile);
				
				tileRect = CGRectOffset(tileRect, tileSize.width, -(imageSize.height - tileSize.height));
			}
			
			if(leftOverWidth > 0)
			{
				CGRect	clipRect;
				
				clipRect = tileRect;
				clipRect.size.width = leftOverWidth;
				
				CGContextSaveGState(_contextRef);
				CGContextClipToRect(_contextRef, clipRect);
				CGContextDrawImage(_contextRef, tileRect, bottomMiddleTile);
				CGContextRestoreGState(_contextRef);
				
				tileRect = CGRectOffset(tileRect, 0, imageSize.height - tileSize.height);
				clipRect = tileRect;
				clipRect.size.width = leftOverWidth;
				
				CGContextSaveGState(_contextRef);
				CGContextClipToRect(_contextRef, clipRect);
				CGContextDrawImage(_contextRef, tileRect, topMiddleTile);
				CGContextRestoreGState(_contextRef);
			}
		}
		
		// Draw left and right tiles
		
		{
			CGFloat		remainingHeight = imageSize.height - (tileSize.height * 2);
			int			iterations = (int)remainingHeight / (int)tileSize.height;
			int			leftOverHeight = (int)remainingHeight % (int)tileSize.height;
			
			tileRect = CGRectMake(0, tileSize.height, tileSize.width, tileSize.height);
			
			for(int i = 0; i < iterations; ++i)
			{
				CGContextDrawImage(_contextRef, tileRect, leftMiddleTile);
				tileRect = CGRectOffset(tileRect, imageSize.width - tileSize.width, 0);
				CGContextDrawImage(_contextRef, tileRect, rightMiddleTile);
				
				tileRect = CGRectOffset(tileRect, -(imageSize.width - tileSize.width), tileSize.height);
			}
			
			if(leftOverHeight > 0)
			{
				CGRect	clipRect;
				
				clipRect = tileRect;
				clipRect.size.height = leftOverHeight;
				
				CGContextSaveGState(_contextRef);
				CGContextClipToRect(_contextRef, clipRect);
				CGContextDrawImage(_contextRef, tileRect, leftMiddleTile);
				CGContextRestoreGState(_contextRef);
				
				tileRect = CGRectOffset(tileRect, imageSize.width - tileSize.width, 0);
				clipRect = tileRect;
				clipRect.size.height = leftOverHeight;
				
				CGContextSaveGState(_contextRef);
				CGContextClipToRect(_contextRef, clipRect);
				CGContextDrawImage(_contextRef, tileRect, rightMiddleTile);
				CGContextRestoreGState(_contextRef);
			}
		}
		
		CGImageRelease(bottomLeftTile);
		CGImageRelease(topLeftTile);
		CGImageRelease(topRightTile);
		CGImageRelease(bottomRightTile);
		CGImageRelease(topMiddleTile);
		CGImageRelease(bottomMiddleTile);
		CGImageRelease(leftMiddleTile);
		CGImageRelease(rightMiddleTile);
		
		CGContextRestoreGState(_contextRef);
	}
}

@end
