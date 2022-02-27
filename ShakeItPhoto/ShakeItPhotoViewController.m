//
//  ShakeItPhotoViewController.m
//
//  Copyright 2020 Zinc Collective, LLC. All rights reserved.
//

#import "ShakeItPhotoViewController.h"
#import "ShakeItPhotoConstants.h"
#import "BananaCameraUtilities.h"
#import "BananaCameraConstants.h"
#import "ShakeItPhotoImageProcessor.h"

@import QuartzCore;
@import CoreMotion;


@interface ShakeItPhotoViewController()
- (void) _discardPreviewLayers;
- (void) _buildPreviewLayers;
- (CGSize) _previewImageSize;
- (BOOL) _allowFasterShaking;
- (BOOL) _usePolaroidBorder;
- (void) _animateDevelopedView;

@property (nonatomic,strong) CMMotionManager *motionManager;
@property (nonatomic,assign) BOOL firstLoad;

@end

@implementation ShakeItPhotoViewController

@synthesize shakeView = _shakeView;

- (void) startTrackingAcceleration
{
    CMMotionManager *mm = [[CMMotionManager alloc] init];
    mm.accelerometerUpdateInterval = (1.0 / 5.0);   // 5 Hz
    
    
    [mm startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                             withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {
                                                 
                                                 [self updateAccelerometer:accelerometerData.acceleration];
                                                 
                                                 if(error){
                                                     
                                                     NSLog(@"%@", error);
                                                 }
                                             }];
    
    [self setMotionManager:mm];
}

- (void) stopTrackingAcceleration {
    [_motionManager stopAccelerometerUpdates];
}

// Constant for the high-pass filter.

#define kFilteringFactor 0.1

-(void)updateAccelerometer:(CMAcceleration)acceleration {
    
    //NSLog(@"currentAcceleration %f %f %f",acceleration.x,acceleration.y,acceleration.z);
    
    if(!IsRunningInSimulator())
    {
        _acceleration[0] = acceleration.x * kFilteringFactor + _acceleration[0] * (1.0 - kFilteringFactor);
        _acceleration[1] = acceleration.y * kFilteringFactor + _acceleration[1] * (1.0 - kFilteringFactor);
        _acceleration[2] = acceleration.z * kFilteringFactor + _acceleration[2] * (1.0 - kFilteringFactor);
        
        CGFloat    accel[3];
        
        accel[0] = acceleration.x - _acceleration[0];
        accel[1] = acceleration.y - _acceleration[1];
        accel[2] = acceleration.z - _acceleration[2];
        
        if(fabs(accel[0]) > 0.40 || fabs(accel[1]) > 0.70)
        {
            if(_imageProcessed)
            {
                CFAbsoluteTime  now = CFAbsoluteTimeGetCurrent();
                
                if((now - _developAnimationStartTime) >= 0.30)
                {
                    CFAbsoluteTime  remaining = _developAnimationDuration - (now - _developAnimationStartTime);
                    CFAbsoluteTime  newRemaining;
                    
                    newRemaining = fmax(0.0, remaining - 3.0);	// was 0.8
                    
                    /*
                    if(newRemaining > 0.0) {
                        [UIView animateWithDuration:newRemaining animations:^{
                            _undevelopedView.alpha = _undevelopedViewAlpha = _undevelopedViewAlpha + 0.001;
                        } completion:^(BOOL finished) {
                            [self processingAnimationComplete];
                        }];
                    }*/
                    
                    _developAnimationDuration = newRemaining;
                    _developAnimationStartTime = now;
                }
            }
            
            [self animateShake: accel];
        }
    }
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *defaultVaules = @{kBananaCameraSocialURL:@(NO),
                                    kShakeItPhotoFasterShakingKey:@(YES),
                                    kShakeItPhotoPolaroidBorderKey:@(YES),
                                    kBananaCameraFirstLaunchKey:@(NO)};
    [userDefaults registerDefaults:defaultVaules];
    
    
    [self setFirstLoad:NO];
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSLog(@"viewDidAppear %i",_firstLoad);
    if(_firstLoad == NO) {
        [self handleLaunch];
        [self setFirstLoad:YES];
    }
    
   
}

#pragma mark - Handle Launch


-(void)handleLaunch {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    BOOL isFirstLaunch = [userDefaults boolForKey: kBananaCameraFirstLaunchKey] == NO;
    if(isFirstLaunch) {
        
        [userDefaults setBool: YES forKey: kBananaCameraFirstLaunchKey];
        [userDefaults synchronize];
        [self handleFirstLaunchScenario];
    } else {
        [self handleNormalLaunchScenario];
    }
}

- (void) handleFirstLaunchScenario
{
    // Set defaults to preset values and show the welcome screen
    /*
    [[NSUserDefaults standardUserDefaults] setBool: NO forKey: kBananaCameraSaveOriginalKey];
    [[NSUserDefaults standardUserDefaults] setBool: NO forKey: kShakeItPhotoFasterShakingKey];
    [[NSUserDefaults standardUserDefaults] setBool: YES forKey: kShakeItPhotoPolaroidBorderKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    */
    
    [self showWelcomeView];
    //[super handleFirstLaunchScenario];
}

- (void) handleNormalLaunchScenario
{
    [self disposeOfWelcomeView];
    
    if([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        [self capturePhoto: nil];
    } else {
        [self choosePhoto: nil];
    }
}

#pragma mark - 

- (void) animateShake: (CGFloat[3]) accel
{
	CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath: @"position"];
	animation.removedOnCompletion = NO;
	
	CGFloat             animationDuration = 1.25;
	CGMutablePathRef    animationPath = CGPathCreateMutable();
    
	CGPathMoveToPoint(animationPath, NULL, self.shakeView.center.x, self.shakeView.center.y);
    
	BOOL			useXaxis = YES; // accel[0] > accel[1];
    CGFloat         xVeloc = useXaxis ? 20 : 10;
    CGFloat         xAmplitude = (useXaxis ? 100 : 50) * accel[0];
    CGFloat         xDecay = useXaxis ? 3.0f : 2.0f;
	
	//    CGFloat         yVeloc = useXaxis ? 10 : 20;
	//    CGFloat         yAmplitude = (useXaxis ? 50 : 100) * accel[1];
	//    CGFloat         yDecay = useXaxis ? 2.0f : 3.0f;
	
    int             steps = 25;
    
    for( int i = 0; i < steps; ++i )
    {
        CGFloat     curTime = i * (animationDuration / steps);
        CGFloat     xValue = xAmplitude * sinf( xVeloc * i ) / expf( xDecay * curTime );
        CGFloat     yValue = 0; // yAmplitude * sinf( yVeloc * i ) / expf( yDecay * curTime );
		
		CGPathAddLineToPoint(animationPath, NULL, self.shakeView.center.x - xValue, self.shakeView.center.y - yValue);
    }
    
    CGPathAddLineToPoint(animationPath, NULL, self.shakeView.center.x, self.shakeView.center.y);
    
	animation.path = animationPath;
	animation.duration = animationDuration;
    animation.calculationMode = kCAAnimationLinear;
    animation.removedOnCompletion = NO;
	[self.shakeView.layer addAnimation: animation forKey: @"shake"];
}

- (BOOL) animationIsFinished
{
    return (CFAbsoluteTimeGetCurrent() - _developAnimationStartTime) > _developAnimationDuration;
}

- (void) processImage: (UIImage*) originalImage shouldWriteOriginal: (BOOL) writeOriginal
{
	[self clearBackgroundImage];

	_imageProcessed = NO;
    
    ShakeItPhotoImageProcessor *processor = [ShakeItPhotoImageProcessor imageProcessorForImage: originalImage
                                                                                   withDelegate: self
                                                                    writeOriginalToPhotoLibrary: writeOriginal];
    [self setImageProcessor:processor];
                                             

	// Build the undeveloped image and start animating it.
	
	[self _buildPreviewLayers];

	
	if(_frameView && _undevelopedView)
	{
		CGRect          frame = _frameView.frame;
		CGRect          startFrame = CGRectMake(frame.origin.x,
												-frame.size.height, 
												frame.size.width, 
												frame.size.height);
		
        _frameView.frame       = startFrame;
        _undevelopedView.frame = startFrame;
        
        _slideOutAnimationFinished = NO;
        frame.origin.y = (_shakeView.frame.size.height - frame.size.height - self.toolbar.frame.size.height) / 2.0f;
        
        // delay the start of the animation, otherwise it gets interrupted by
        // the modal transition of the UIImagePicker dismissing
        NSTimeInterval delay = 0.3;
        double time = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
        dispatch_after(time, dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:2.5
                                  delay:0.0
                                options:UIViewAnimationCurveEaseInOut animations:^{
                
                _frameView.frame       = frame;
                _undevelopedView.frame = frame;
                
            } completion:^(BOOL finished) {
                
                NSLog(@"finished %i",finished);
                
                if(finished) {
                    NSLog(@"Animation Completed On Time");
                    [self slideOutAnimationCompelte];
                } else {
                    NSLog(@"Animation Completed Early");
                    //Hack because complete animation fires too early
                    [self performSelector:@selector(slideOutAnimationCompelte) withObject:nil afterDelay:2.5];
                }            
            }];
        });
        
		// Play the sound effect.
		[self playSoundEffect: @"polaroid_eject_effect.aif"];
		
		[self disableToolbarItems: kAllItems];
	}
}

-(void)slideOutAnimationCompelte {
    
    _slideOutAnimationFinished = YES;
    [self startTrackingAcceleration];
    [self animateDevelopedView];
}

#pragma mark - Did Take Picture


//-(void)didTakePicture:(SCNavigationController *)navigationController image:(UIImage *)image {
//    
//    [super didTakePicture:navigationController image:image];
//    [self _discardPreviewLayers];
//    
//    [self dismissViewControllerAnimated:YES completion:^{
//        
//        //[self.view addSubview:[[UIImageView alloc] initWithImage:image]]; return;
//        
//        BOOL writeOriginal = ([[NSUserDefaults standardUserDefaults] boolForKey: kBananaCameraSaveOriginalKey] == YES);
//        
//        // Do we already have a pending image processing operation going
//        if(_imageProcessor) {
//            [ApplicationDelegate() addImageToProcess: image imageFlags: writeOriginal];
//        } else {
//            [self processImage: image shouldWriteOriginal: writeOriginal];
//        }
//    }];
//}
//
//
//- (BOOL)willDismissNavigationController:(SCNavigationController *)navigatonController {
//    
//    [super willDismissNavigationController:navigatonController];
//    
//    if([ApplicationDelegate() imagesToProcess] > 0) {
//        BOOL		imageFlags = NO;
//        NSString*	imagePath = [ApplicationDelegate() nextImageToProcess: &imageFlags];
//        UIImage*	image = [UIImage imageWithContentsOfFile: imagePath];
//        [self processImage: image shouldWriteOriginal: imageFlags];
//    } else {
//        self.toolbar.alpha = 1.0;
//        [self enableToolbarItems: kAllItems];
//    }
//
//    return YES;
//}

#pragma mark - UIImagePickerController

- (void) imagePickerController: (UIImagePickerController*) picker didFinishPickingMediaWithInfo: (NSDictionary*) info
{
	// If write original to disk is set, the base class handles it.
	// This may not work so well for non ios4 phones
	
	[super imagePickerController: picker didFinishPickingMediaWithInfo: info];
    
    NSString* type = [info objectForKey: UIImagePickerControllerMediaType];
    if([type isEqualToString: @"public.image"])
    {
        UIImage*	originalImage = [info objectForKey: UIImagePickerControllerOriginalImage];
		BOOL		writeOriginal = ([[NSUserDefaults standardUserDefaults] boolForKey: kBananaCameraSaveOriginalKey] == YES) &&
									(picker.sourceType != UIImagePickerControllerSourceTypePhotoLibrary);
		
		// Do we already have a pending image processing operation going
		if(_imageProcessor) {
			[ApplicationDelegate() addImageToProcess: originalImage imageFlags: writeOriginal];
        } else {
			[self processImage: originalImage shouldWriteOriginal: writeOriginal];
		}
    } else {
        NSLog(@"selected image is not keyed: [UIImagePickerControllerMediaType: @'public.image']");
    }
}

- (void) imagePickerControllerDidCancel: (UIImagePickerController*) picker
{
	[super imagePickerControllerDidCancel: picker];
	
	if([ApplicationDelegate() imagesToProcess] > 0) {
		BOOL		imageFlags = NO;
		NSString*	imagePath = [ApplicationDelegate() nextImageToProcess: &imageFlags];
		UIImage*	image = [UIImage imageWithContentsOfFile: imagePath];
		[self processImage: image shouldWriteOriginal: imageFlags];
	} else {
		self.toolbar.alpha = 1.0;
		[self enableToolbarItems: kAllItems];
	}
}

- (CGSize) _previewImageSize
{
	//CGSize		originalImageSize = _imageProcessor.rawImage.size;
	CGSize		previewSize = CGSizeZero;
	
	if([self _usePolaroidBorder])
	{
		previewSize.width  = 320.0;
		previewSize.height = 388.0;
	} else {
		previewSize.width  = 320.0;
		previewSize.height = 316.0;
	}
    
    CGFloat r1 = previewSize.width / previewSize.height;
    
    CGFloat scale =  self.view.frame.size.width / previewSize.width;
    previewSize.width  = self.view.frame.size.width;
    previewSize.height *= scale;
    
    CGFloat r2 = previewSize.width / previewSize.height;
    
    NSLog(@"%f %f %f",scale,r1,r2);
    
	return previewSize;
}

- (void) _buildPreviewLayers
{
    [self _discardPreviewLayers];

    @autoreleasepool {

		CGSize				previewSize = [self _previewImageSize];
		UIImage*			framePreviewImage = nil;

		if([self _usePolaroidBorder]) {
			framePreviewImage = [UIImage imageNamed: @"preview_polaroid.png"];
		} else {
			framePreviewImage = [UIImage imageNamed: @"preview.png"];
		}
		
		_frameView = [[UIView alloc] initWithFrame: CGRectMake( CGRectGetMidX(self.view.frame) - previewSize.width/2, 0.0f, previewSize.width, previewSize.height )];
		_frameView.layer.contents = (id)framePreviewImage.CGImage;
		[self.shakeView insertSubview: _frameView belowSubview: self.toolbar];
		
		//previewSize = [self _previewImageSize];
    UIImage*    undevelopedPreviewImage = [UIImage imageNamed: @"film.png"];
    _undevelopedView = [[UIView alloc] initWithFrame: _frameView.frame];
    _undevelopedView.layer.contents = (id)undevelopedPreviewImage.CGImage;
    [self.shakeView insertSubview: _undevelopedView belowSubview: _frameView];
	
    }
}

- (void) _discardPreviewLayers
{
    _frameView.layer.contents = nil;
    [_frameView removeFromSuperview];
    _frameView = nil;
    
    _undevelopedView.layer.contents = nil;
    [_undevelopedView removeFromSuperview];
    _undevelopedView = nil;
	
    _developedView.layer.contents = nil;
    [_developedView removeFromSuperview];
    _developedView = nil;
}

-(void)processingAnimationComplete {

   
}
- (void) clearBackgroundImage
{
    self.shakeView.layer.contents = nil;
    self.shakeView.backgroundColor = self.view.backgroundColor;
}

- (void) setBackgroundImage
{
    //NSLog(@"setting background image");
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    NSInteger height = fmaxf(screenBounds.size.width, screenBounds.size.height);
    NSString *imageName = @"bg_iPhone4";
    
    switch (height) {
        case 480: //3.5
            imageName = @"bg_iPhone4";
            break;
        case 568: //4.0
            imageName = @"bg_iPhone5";
            break;
        case 667: //4.7
            imageName = @"bg_iPhone6";
            break;
        case 736: //5.5
            imageName = @"bg_iPhone6Plus";
            break;
        case 1792:
            imageName = @"bg_iPhoneXR";
            break;
        case 2436:
            imageName = @"bg_iPhoneX";
            break;
        case 2688:
            imageName = @"bg_iPhoneXSmax";
            break;
            
        default:
            break;
    }
    
	UIImage*	background = [UIImage imageNamed: imageName];
	self.shakeView.layer.contents        = (id)background.CGImage;
	self.shakeView.layer.contentsGravity = kCAGravityResizeAspect;
}


- (void) _animateDevelopedView
{
	if(_developedView)
	{
		[self.shakeView insertSubview: _developedView belowSubview: _undevelopedView];
		
		// stash the current time of the starting animation.
		
		if([self _allowFasterShaking]) {
			_developAnimationDuration = 4.0;		// lets try 4 seconds for the faster animation.
		} else {
			_developAnimationDuration = 45.0;
		}
		
		_developAnimationStartTime = CFAbsoluteTimeGetCurrent();
        
        [UIView animateWithDuration:_developAnimationDuration delay:0.0f options:UIViewAnimationCurveEaseInOut animations:^{
            _undevelopedView.alpha =  0.001f;
        } completion:^(BOOL finished) {
            
            [_undevelopedView removeFromSuperview];
            _undevelopedView = nil;
            [self stopTrackingAcceleration];
        }];
	}
}

- (void) imageProcessor: (ShakeItPhotoImageProcessor*) ip didFinishProcessingPreviewImage: (UIImage*) previewImage
{
    _imageProcessor = nil;
	_imageProcessed = YES;
    _developedView = [[UIImageView alloc] initWithFrame: _undevelopedView.frame];
    if(previewImage != nil) {
        if(_developedView != nil) {
            [_developedView setImage:previewImage];
//            [self animateDevelopedView];
        } else {
            
            NSLog(@"missing _developedView");
        }
    } else {
        
        NSLog(@"missing previewImage");
//        NSLog(@"missing previewImage: %@", previewImage);
//        NSLog(@"missing _developedView: %@", _developedView);
    }
    
//    _developedView.layer.contents = (id)previewImage.CGImage;
    
	//_developedView.layer.contentsGravity = kCAGravityResizeAspect;
    
    [self animateDevelopedView];
}

-(void)animateDevelopedView {
    if(_slideOutAnimationFinished && _imageProcessed) {
        [self _animateDevelopedView];
        [self enableToolbarItems: kCapturePhotoItem | kPickPhotoItem | kSettingsItem];
    }
}

- (BOOL) shouldUsePolaroidAssets
{
	return [self _usePolaroidBorder];
}

- (void) imageProcessorWroteOriginalImageToLibrary: (NSNotification*) notification
{
	[super imageProcessorWroteOriginalImageToLibrary: notification];
}

- (void) imageProcessorWroteProcessedImageToLibrary: (NSNotification*) notification
{
	//NSLog(@"imageProcessorWroteProcessedImageToLibrary triggered");
	
	[super imageProcessorWroteProcessedImageToLibrary: notification];
	
	if([ApplicationDelegate() imagesToProcess] > 0)
	{
		BOOL		imageFlags = NO;
		NSString*	imagePath = [ApplicationDelegate() nextImageToProcess: &imageFlags];
		UIImage*	image = [UIImage imageWithContentsOfFile: imagePath];
		[self processImage: image shouldWriteOriginal: imageFlags];
	}
	else
	{
		//NSLog(@"No images to process");
	}
}


- (BOOL) _allowFasterShaking
{
	return [[NSUserDefaults standardUserDefaults] boolForKey: kShakeItPhotoFasterShakingKey];
}

- (BOOL) _usePolaroidBorder
{
	return [[NSUserDefaults standardUserDefaults] boolForKey: kShakeItPhotoPolaroidBorderKey];
}

- (IBAction) usePolaroidBorder: (id) sender
{
	UISwitch*	usePolariodBorderSwitch = (UISwitch*)sender;
	[[NSUserDefaults standardUserDefaults] setBool: [usePolariodBorderSwitch isOn] forKey: kShakeItPhotoPolaroidBorderKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction) allowFasterShaking: (id) sender
{
	UISwitch*	fasterShakingSwitchSwitch = (UISwitch*)sender;
	[[NSUserDefaults standardUserDefaults] setBool: [fasterShakingSwitchSwitch isOn] forKey: kShakeItPhotoFasterShakingKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)applicationWillResignActive {
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self setFirstLoad:NO];
        NSLog(@"set first load %i",_firstLoad);
    }];
}

- (void) applicationWillEnterForeground
{
	[super applicationWillEnterForeground];

	if([ApplicationDelegate() imagesToProcess] > 0) {
		BOOL		imageFlags = NO;
		NSString*	imagePath = [ApplicationDelegate() nextImageToProcess: &imageFlags];
		UIImage*	image = [UIImage imageWithContentsOfFile: imagePath];
		[self processImage: image shouldWriteOriginal: imageFlags];
	} else {
        
        [self viewDidAppear:NO];
        
        //[self setFirstLoad:NO];
        
        /*
		if([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
		{
			[self capturePhoto: nil];
		} else {
			[self choosePhoto: nil];
		}*/
	}
}

- (void) applicationDidEnterBackground
{
    [self setFirstLoad:NO];
    [self _discardPreviewLayers];
	[super applicationDidEnterBackground];
}

- (NSString*) defaultPhotoName
{
	return @"Taken with ShakeItPhoto for the iPhone";
}

@end
