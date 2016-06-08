//
//  BananaCameraImage.h
//
//  Copyright 2010 Banana Camera Company. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CGContext.h>
#import <CoreGraphics/CGImage.h>

@class BananaCameraImageCurve;

@interface BananaCameraImage : NSObject
{
    @private
    CGContextRef        _contextRef;        // CGContext for the image
    //unsigned long*      _rawBytes;          // Raw pixel buffer
    uint                _bufferSize;        // Pixel buffer size in bytes
    CGSize              _size;              // Geometric size
	UIImageOrientation	_orientation;		// Orientation
    unsigned char       _reds[256];
    unsigned char       _greens[256];
    unsigned char       _blues[256];

	CGImageRef			_borderImageRef;
	NSString*			_imagePath;
    
    CGRect              _renderRect;
}

@property(nonatomic, readonly) CGContextRef			context;
//@property(nonatomic, readonly) unsigned long*		bytes;
@property(nonatomic, readonly) uint					bufferSize;
@property(nonatomic, readonly) CGSize				size;
@property(nonatomic, readonly) CGImageRef			CGImageRef;
@property(nonatomic, readonly) NSString*			imagePath;
@property(nonatomic, readonly) UIImageOrientation   orientation;
@property(nonatomic, readonly) CGRect               renderRect;




+ (BananaCameraImage*) imageWithSize: (CGSize) size orientation: (UIImageOrientation) orientation;
+ (CGColorSpaceRef) deviceRGBColorSpace;
+ (CGColorRef) genericGrayColor80;

- (id) initWithImage: (UIImage*) image size: (CGSize) size margin: (CGFloat) margin;
- (id) initWithImage: (UIImage*) image size: (CGSize) size imageRect: (CGRect) imageRect;
- (id) initWithSize: (CGSize) size colorSpace: (CGColorSpaceRef) colorspace orientation: (UIImageOrientation) orientation;
- (void) dealloc;

- (CGContextRef) pushContext;
- (void) popContext;

- (uint) curveApplyMask: (NSArray*) curves;

- (void) setBorderImage: (NSString*) imagePath;
- (void) applyBorder;

//- (void) writePNGRepresentationToPath: (NSString*) path;
//- (void) writeJPGRepresentationToPath: (NSString*) path;
- (void) dumpPixels;

@end
