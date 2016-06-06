//
//  ShakeItPhotoViewController.h
//
//  Copyright 2010 Banana Camera Company. All rights reserved.
//

#import "BananaCameraViewController.h"
#import "ShakeItPhotoImageProcessor.h"

@class ShakeItPhotoImageProcessor;

@interface ShakeItPhotoViewController : BananaCameraViewController<UIAccelerometerDelegate, ShakeItPhotoImageProcessorDelegate>
{
	@private
    UIAccelerationValue				_acceleration[3];				// Used to track the 'shake'
	BOOL							_slideOutAnimationFinished;
    CFAbsoluteTime					_developAnimationStartTime;		// Animation flags for the developing fade in
    NSTimeInterval					_developAnimationDuration;
    double							_undevelopedViewAlpha;        

    // Views displaying the preview content.
    
    UIView*							_frameView;                  // This is the frame layer that houses the polaroid frame.
    UIView*							_undevelopedView;            // This is the undeveloped layer.
    UIView*							_developedView;              // This is the developed layer
	UIView*							_shakeView;

    UITableViewCell*				_fasterShakingCell;
    UITableViewCell*				_polaroidBorderCell;
	UIView*							_footerView;
    BOOL							_imageProcessed;
}

@property(nonatomic, retain) ShakeItPhotoImageProcessor*	  imageProcessor;
@property(nonatomic, retain) IBOutlet UIView*			  shakeView;
@property(nonatomic, retain) IBOutlet UITableViewCell*    fasterShakingCell;
@property(nonatomic, retain) IBOutlet UITableViewCell*    polaroidBorderCell;
@property(nonatomic, retain) IBOutlet UIView*			  footerView;

- (void) startTrackingAcceleration;
- (void) stopTrackingAcceleration;
- (void) animateShake: (CGFloat[3]) accel;

- (IBAction) allowFasterShaking: (id) sender;
- (IBAction) usePolaroidBorder: (id) sender;

- (void) processImage: (UIImage*) originalImage shouldWriteOriginal: (BOOL) writeOriginal;

@end

