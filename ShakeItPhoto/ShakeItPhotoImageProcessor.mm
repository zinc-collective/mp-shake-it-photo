//
//  ShakeItPhotoImageProcessor.mm
//
//  Copyright Banana Camera Company 2010. All rights reserved.
//

#import "ShakeItPhoto-Swift.h"
#import "ShakeItPhotoImageProcessor.h"
#import "ShakeItPhotoConstants.h"
#import "BananaCameraUtilities.h"
#import "BananaCameraConstants.h"
#import "BananaCameraImage.h"
#import "BananaCameraImageCurve.h"
#import "NSNotificationCenter_Additions.h"
#import "UIImage+Resize.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "ALAssetsLibrary+CSNAdditions.h"

// Returns an affine transform that takes into account the image orientation when drawing a scaled image

static inline CGAffineTransform transformForOrientationAndSize(UIImageOrientation orientation, CGSize newSize) 
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch(orientation)
    {
        case UIImageOrientationDown:           // EXIF = 3
        case UIImageOrientationDownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, newSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:           // EXIF = 6
        case UIImageOrientationLeftMirrored:   // EXIF = 5
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:          // EXIF = 8
        case UIImageOrientationRightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, 0, newSize.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
    }
    
    switch(orientation)
    {
        case UIImageOrientationUpMirrored:     // EXIF = 2
        case UIImageOrientationDownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:   // EXIF = 5
        case UIImageOrientationRightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, newSize.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
    }
    
    return transform;
}

static inline void adjustForOrientation(CGContextRef context, UIImageOrientation orientation, float w, float h)
{
    if(orientation != UIImageOrientationUp && w > 0.0 && h > 0.0)
    {
        CGAffineTransform transform;
        switch(orientation)
        {
            case UIImageOrientationDown:
            {
                transform = CGAffineTransformMake(-1, 0, 0, -1, w, h);
                break;
            }
            case UIImageOrientationLeft:
            {
                transform = CGAffineTransformMake( 0,  h/w, -w/h,  0,  w, 0);
                break;
            }
            case UIImageOrientationRight:
            {
                transform = CGAffineTransformMake( 0, -h/w,  w/h,  0,  0, h);
                break;
            }
            case UIImageOrientationUpMirrored:
            {
                transform = CGAffineTransformMake(-1,    0,    0,  1,  w, 0);
                break;
            }
            case UIImageOrientationDownMirrored:
            {
                transform = CGAffineTransformMake( 1,    0,    0, -1,  0, h);
                break;
            }
            case UIImageOrientationLeftMirrored:
            {
                transform = CGAffineTransformMake( 0, -h/w, -w/h,  0,  w, h);
                break;
            }
            case UIImageOrientationRightMirrored:
            {
                transform = CGAffineTransformMake( 0,  h/w,  w/h,  0,  0, 0);
                break;
            }
            default:
            {
                transform = CGAffineTransformIdentity;
                break;
            }
        }
        
        CGContextConcatCTM(context, transform);
    }
}

@interface ShakeItPhotoImageProcessor(Private)
- (void) _process;
- (void) _processFinalImage;

- (NSString*) _framePath: (BOOL)usePolaroid;

- (void) _drawImageAtPath: (NSString*) inPath 
                  context: (CGContextRef) inContext
                landscape: (BOOL) inLandscape
                blendMode: (CGBlendMode) inBlendMode
                    alpha: (CGFloat) inAlpha
           finalImageSize: (CGSize) finalSize;

- (CGSize) _previewImageSize;
- (CGSize) _finalImageSize: (CGFloat*) outPolaroidOffset;

- (BOOL) _isLandscape;

- (void) _writeProcessedImageToPhotoLibrary: (BananaCameraImage*) image;
- (void) _writeOriginalImageToPhotoLibrary: (UIImage*) image;


@end

@implementation ShakeItPhotoImageProcessor

@synthesize rawImage = _rawImage;
@synthesize delegate = _delegate;
@synthesize writeOriginalToPhotoLibrary = _writeOriginalToPhotoLibrary;
@synthesize usePolaroidAssets = _usePolaroidAssets;

+ (ShakeItPhotoImageProcessor*) imageProcessorForImage: (UIImage*) image 
                                          withDelegate: (NSObject<ShakeItPhotoImageProcessorDelegate>*) delegate
                           writeOriginalToPhotoLibrary: (BOOL) writeOriginal
{
    ShakeItPhotoImageProcessor*  processor = [[ShakeItPhotoImageProcessor alloc] init];
    if(processor)
    {
        processor.rawImage = image;
        processor.delegate = delegate;
        processor.writeOriginalToPhotoLibrary = writeOriginal;
        processor.usePolaroidAssets = [delegate shouldUsePolaroidAssets];
        
        if(ApplicationDelegate().backgroundTasksSupported)
        {
            UIApplication*						app = [UIApplication sharedApplication];
            __block UIBackgroundTaskIdentifier	bgTask = UIBackgroundTaskInvalid;
            
            // Request permission to run in the background. Provide an
            // expiration handler in case the task runs long.
            
            bgTask = [app beginBackgroundTaskWithExpirationHandler: ^{
                // Synchronize the cleanup call on the main thread in case
                // the task actually finishes at around the same time.
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(bgTask != UIBackgroundTaskInvalid)
                    {
                        [app endBackgroundTask:bgTask];
                        bgTask = UIBackgroundTaskInvalid;
                    }
                });
            }];
            
            
            [ALAssetsLibrary csn_requestAccessToAssetsLibraryWithCompletionBlock:^(BOOL granted, NSError *error) {
                // Start the long-running task and return immediately.
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                    // Process the image.
                    [processor _process];
                    
                    // Synchronize the cleanup call on the main thread in case
                    // the expiration handler is fired at the same time.
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(bgTask != UIBackgroundTaskInvalid)
                        {
                            [app endBackgroundTask:bgTask];
                            bgTask = UIBackgroundTaskInvalid;
                        }
                    });
                });
            }];
        }
        else
        {
            [NSThread detachNewThreadSelector: @selector(_process) toTarget: processor withObject: nil];
        }
    }
    return processor;
}


- (void) _process
{
    @autoreleasepool {
        
        NSString*			curvePath = [[NSBundle mainBundle] pathForResource: @"shakeitphoto" ofType: @"acv"];
        
        _curves = [BananaCameraImageCurve imageCurvesFromACV: curvePath];
        
        // border
        // overlay (80% overlay)
        // curves
        // original
        
        [self _processFinalImage];
        
    }
}

- (NSString*) _framePath: (BOOL)usePolaroid {
    // Always return assets as if they were UIImageOrientationUp
    
    NSString * pathName = @"frame";
    
    if (usePolaroid) {
        pathName = [pathName stringByAppendingString:@"_polaroid"];
    }
    
    return [[NSBundle mainBundle] pathForResource:pathName ofType:@"png"];
}

- (CGSize) _previewImageSize
{
    UIScreen*	mainscreen = [UIScreen mainScreen];
    CGFloat		scale = 1.0;
    
    if([mainscreen respondsToSelector: @selector(displayLinkWithTarget:selector:)]) {
        scale = mainscreen.scale;
    }
    
    CGSize		previewSize;
    
    previewSize.width  = 320.0;
    previewSize.height = 316.0;
    
    // Front facing camera.
    
    if(self.rawImage.size.width == 480.0 && self.rawImage.size.height == 640.0)
    {
        // TODO - need to figure out how to scale this.
    }
    
    // account for scale
    
    previewSize.height *= scale;
    previewSize.width  *= scale;
    
    // swap for landscape orientation
    
    if(self.rawImage.size.width > self.rawImage.size.height)
    {
        previewSize = CGSizeMake(previewSize.height, previewSize.width);
    }
    
    NSLog(@"###---> Preview Image Size = %@", NSStringFromCGSize(previewSize));
    return previewSize;
}

- (CGSize) _finalImageSize: (CGFloat*) outPolaroidOffset
{
    CGSize	finalSize = self.rawImage.size;
    CGFloat	testDim = MIN(finalSize.width, finalSize.height);
    NSLog(@"###---> _finalImageSize => [rawImage, testDim] = %@ --- %f", NSStringFromCGSize(finalSize), testDim);
    
    if(testDim >= 1700.0) {
        if(_usePolaroidAssets) {
            finalSize = CGSizeMake(1920.0, 2300.0);
        } else {
            finalSize = CGSizeMake(1920.0, 1876.0);
        }
        
        *outPolaroidOffset = 2300.0 - 1876.0;
    } else if(testDim >= 1300.0) {
        if(_usePolaroidAssets) {
            finalSize = CGSizeMake(1520.0, 1822.0);
        } else {
            finalSize = CGSizeMake(1520.0, 1486.0);
        }
        
        *outPolaroidOffset = 1822.0 - 1486.0;
    } else {
        if(_usePolaroidAssets) {
            finalSize = CGSizeMake(1200.0, 1438.0);
        } else {
            finalSize = CGSizeMake(1200.0, 1172.0);
        }
        
        *outPolaroidOffset = 1438.0 - 1172.0;
    }
    
    return finalSize;
}

- (BOOL) _isLandscape
{
    return self.rawImage.size.width > self.rawImage.size.height;
}

+(CGRect) computeImageRect:(CGSize)finalSize usePolaroidAssets:(BOOL)_usePolaroidAssets
{
    CGRect		imageRect = CGRectZero;
    finalSize = CGSizeMake(1920.0, 2300.0);
    NSLog(@"###---> _computeImageRect(BEFORE-A) = %@", NSStringFromCGRect(imageRect));
    NSLog(@"###---> _computeImageRect(BEFORE-B) = %@ --- %i", NSStringFromCGSize(finalSize), _usePolaroidAssets);
    
    if(_usePolaroidAssets)
    {
        imageRect = CGRectMake(finalSize.width * kInteriorLeftPolaroid,
                               finalSize.height * kInteriorTopPolaroid,
                               finalSize.width - ((finalSize.width * kInteriorLeftPolaroid) + (finalSize.width * kInteriorRightPolaroid)),
                               finalSize.height - ((finalSize.height * kInteriorTopPolaroid) + (finalSize.height * kInteriorBottomPolaroid)));
    }
    else
    {
        imageRect = CGRectMake(finalSize.width * kInteriorLeft,
                               finalSize.height * kInteriorTop,
                               finalSize.width - ((finalSize.width * kInteriorLeft) + (finalSize.width * kInteriorRight)),
                               finalSize.height - ((finalSize.height * kInteriorTop) + (finalSize.height * kInteriorBottom)));
    }
    
    NSLog(@"###---> _computeImageRect(AFTER) = %@", NSStringFromCGRect(imageRect));
    return CGRectIntegral(imageRect);
}

#define SIP_ORIGINAL 1

- (void) _processFinalImage
{
    START_TIMING(processFinalImage);
    
    @autoreleasepool {
        
        BOOL				landscape = [self _isLandscape];
        CGFloat             polaroidOffset = 0.0;
        CGSize				finalSize = [self _finalImageSize: &polaroidOffset];
        CGRect              imageRect = [ShakeItPhotoImageProcessor computeImageRect:finalSize
                                                                   usePolaroidAssets:_usePolaroidAssets];
        
        BananaCameraImage*	finalImage = [[BananaCameraImage alloc] initWithImage: self.rawImage
                                                                            size: finalSize
                                                                       imageRect: imageRect];
        
        if(self.writeOriginalToPhotoLibrary == NO)
        {
            self.rawImage = nil;
        }
        
        CGContextRef		context = [finalImage pushContext];
        
        START_TIMING(renderBlue);
        
        if(_usePolaroidAssets)
        {
            CGContextSaveGState(context);
            CGContextTranslateCTM(context, 0, polaroidOffset);
        }
        
        [self _drawImageAtPath: [[NSBundle mainBundle] pathForResource:@"blue" ofType:@"jpg"]
                       context: context
                     landscape: landscape
                     blendMode: kCGBlendModeScreen
                         alpha: _usePolaroidAssets ? 0.45 : 0.3
                finalImageSize: finalSize];
        END_TIMING(renderBlue);
        
        START_TIMING(renderGreen);
        [self _drawImageAtPath: [[NSBundle mainBundle] pathForResource:@"green" ofType:@"jpg"]
                       context: context
                     landscape: landscape
                     blendMode: kCGBlendModeOverlay
                         alpha: 1.0
                finalImageSize: finalSize];
        END_TIMING(renderGreen);
        
        if(_usePolaroidAssets)
        {
            CGContextRestoreGState(context);
        }
        
        // Generate a preview image that doesn't include the frame.
        
        {
            
            CGImageRef imageRef = finalImage.CGImageRef;
            UIImage*	finalPreviewImage = [[UIImage alloc] initWithCGImage:imageRef];
            
            UIImage* scaledImage = [finalPreviewImage resizedImage:CGSizeMake(640.0, 640.0) interpolationQuality:kCGInterpolationDefault];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [_delegate imageProcessor:self didFinishProcessingPreviewImage:scaledImage];
            });
            
            CGImageRelease(imageRef);
            
        }
        
        START_TIMING(renderFrame);
        
        NSString * framePath = [self _framePath: _usePolaroidAssets];
        [self _drawImageAtPath: framePath
                       context: context
                     landscape: landscape
                     blendMode: kCGBlendModeNormal
                         alpha: 1.0
                finalImageSize: finalSize];
        
        END_TIMING(renderFrame);
        
        [finalImage popContext];
        
        // Done processing the final image - need to write the created image to the
        // the photo library.
        
        [self _writeProcessedImageToPhotoLibrary: finalImage];
        
        if(_writeOriginalToPhotoLibrary && _rawImage)
        {
            [self _writeOriginalImageToPhotoLibrary: _rawImage];
            _rawImage = nil;
        }
        
        END_TIMING(processFinalImage);
        
    }
}

- (void) _writeProcessedImageToPhotoLibrary: (BananaCameraImage*) image
{
//    [self modernWriteProcessedImageToPhotoLibraryWithImage:image.CGImageRef];
    CGImageRef	imageRef = image.CGImageRef;
    UIImage*	imageNew = [UIImage imageWithCGImage: imageRef];
    UIImageWriteToSavedPhotosAlbum(imageNew, nil, NULL, NULL);
    
    NSData*		imageData = UIImageJPEGRepresentation(imageNew, 1.0);
    if(imageData)
    {
        NSString*	uniquePath = [ApplicationDelegate() createUniqueImagePath];
        [imageData writeToFile: uniquePath atomically: NO];
        
        NSDictionary*	userInfo = nil;
        userInfo = [NSDictionary dictionaryWithObject: [NSURL fileURLWithPath: uniquePath isDirectory: NO] forKey: @"url"];
        [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName: kDidWriteProcessedImageToPhotoLibraryNotification
                                                                        object: self
                                                                      userInfo: userInfo];
    }
    
    CGImageRelease(imageRef);
}

- (void) _writeOriginalImageToPhotoLibrary: (UIImage*) originalImage
{
//    [self modernWriteOriginalImageToPhotoLibraryWithImage:originalImage];
    UIImageWriteToSavedPhotosAlbum(originalImage, nil, NULL, NULL);
    
    NSDictionary*	userInfo = nil;
    userInfo = [NSDictionary dictionaryWithObject: @"original" forKey: @"url"];
    
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName: kDidWriteOriginalImageToPhotoLibraryNotification
                                                                    object: self
                                                                  userInfo: userInfo];
}

- (void) _drawImageAtPath: (NSString*) inPath 
                  context: (CGContextRef) inContext
                landscape: (BOOL) inLandscape
                blendMode: (CGBlendMode) inBlendMode
                    alpha: (CGFloat) inAlpha
           finalImageSize: (CGSize) finalSize
{	
    NSURL*		url = [NSURL fileURLWithPath: inPath];
    NSString*	pathExtension = [inPath pathExtension];
    
    if(url)
    {
        // May want to use an in memory system here.
        
        CGDataProviderRef	dataProvider = CGDataProviderCreateWithURL((CFURLRef)url);
        
        if(dataProvider)
        {
            CGImageRef		imageRef = NULL;
            
            if([pathExtension compare: @"png" options: NSCaseInsensitiveSearch] == NSOrderedSame)
            {
                imageRef = CGImageCreateWithPNGDataProvider(dataProvider, NULL, false, kCGRenderingIntentDefault);
            }
            else if(([pathExtension compare: @"jpg" options: NSCaseInsensitiveSearch] == NSOrderedSame) ||
                    ([pathExtension compare: @"jpeg" options: NSCaseInsensitiveSearch] == NSOrderedSame))
            {
                imageRef = CGImageCreateWithJPEGDataProvider(dataProvider, NULL, false, kCGRenderingIntentDefault);
            }
            
            if(imageRef)
            {
                CGContextSaveGState(inContext);
                
                CGRect		imageRect = CGRectMake(0, 0, finalSize.width, finalSize.height);
                
                CGContextSetAlpha(inContext, inAlpha);
                CGContextSetBlendMode(inContext, inBlendMode);
                
                CGContextDrawImage(inContext, imageRect, imageRef);
                
                CGImageRelease(imageRef);
                CGContextRestoreGState(inContext);
            }
            
            CGDataProviderRelease(dataProvider);
        }
    }
}

@end

