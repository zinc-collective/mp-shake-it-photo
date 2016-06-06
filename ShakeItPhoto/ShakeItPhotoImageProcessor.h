//
//  ShakeItPhotoImageProcessor.h
//
//  Copyright Banana Camera Company 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ShakeItPhotoImageProcessorDelegate;
@class BananaCameraImage;

@interface ShakeItPhotoImageProcessor : NSObject
{
    UIImage*										_rawImage;
    NSObject<ShakeItPhotoImageProcessorDelegate>*   _delegate;
    NSArray*										_curves;
	BOOL											_writeOriginalToPhotoLibrary;
	BOOL											_usePolaroidAssets;
}

@property (nonatomic, retain) UIImage*											rawImage;
@property (nonatomic, assign) NSObject<ShakeItPhotoImageProcessorDelegate>*		delegate;
@property (nonatomic, assign) BOOL												writeOriginalToPhotoLibrary;
@property (nonatomic, assign) BOOL												usePolaroidAssets;

+ (ShakeItPhotoImageProcessor*) imageProcessorForImage: (UIImage*) image 
										  withDelegate: (NSObject<ShakeItPhotoImageProcessorDelegate>*) delegate
						   writeOriginalToPhotoLibrary: (BOOL) writeOriginal;
+ (CGRect) computeImageRect: (CGSize) finalSize usePolaroidAssets:(BOOL)_usePolaroidAssets;

@end

#pragma mark -

@protocol  ShakeItPhotoImageProcessorDelegate

- (void) imageProcessor: (ShakeItPhotoImageProcessor*) ip didFinishProcessingPreviewImage: (UIImage*) previewImage;
- (BOOL) shouldUsePolaroidAssets;

@end
