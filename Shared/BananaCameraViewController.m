//
//  BananaCameraViewController.m
//
//  Copyright 2020 Zinc Collective, LLC. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "BananaCameraViewController.h"
#import "BananaCameraAppDelegate.h"
#import "BananaCameraUtilities.h"
#import "BananaCameraSoundEffect.h"
#import "BananaCameraConstants.h"
#import "BananaCameraGrowlView.h"
#import "SettingsTableViewController.h"
#import "UIImage+Resize.h"
#import "InstagramActivity.h"
#import "ShakeItPhotoConstants.h"
#import "ShakeItPhotoImageProcessor.h"

#import "BananaCameraConstants.h"


@interface BananaCameraViewController(Private) <UIDocumentInteractionControllerDelegate>
- (void) _orientationChanged: (NSNotification*) notification;
- (UIBarButtonItem*) _settingsBarButtonItem;
- (UIBarButtonItem*) _actionBarButtonItem;
- (UIBarButtonItem*) _capturePhotoBarButtonItem;
- (UIBarButtonItem*) _pickPhotoBarButtonItem;
- (NSString*) _mimeTypeForUTI: (NSString*) uti;
- (NSString*) _createTempFileNameInDirectory: (NSString*) directory extension: (NSString*) ext;

@end

void BananaCameraAudioSessionInterruptionListener(BananaCameraViewController* viewController, UInt32 inInterruptionState);

@implementation BananaCameraViewController

@synthesize toolbar = _toolbar;
@synthesize welcomeView = _welcomeView;
@synthesize croprect = _croprect;

- (void) dealloc 
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];

	[_welcomeView removeFromSuperview];
	
}

- (void) viewDidLoad
{
	//NSLog(@"###---> viewDidLoad");

    [super viewDidLoad];

    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];

    [[NSNotificationCenter defaultCenter] addObserver: self 
                                             selector: @selector(_orientationChanged:)
                                                 name: UIDeviceOrientationDidChangeNotification 
                                               object: nil];

	[[NSNotificationCenter defaultCenter] addObserver: self 
                                             selector: @selector(imageProcessorWroteOriginalImageToLibrary:)
                                                 name: kDidWriteOriginalImageToPhotoLibraryNotification 
                                               object: nil];
	
	[[NSNotificationCenter defaultCenter] addObserver: self 
                                             selector: @selector(imageProcessorWroteProcessedImageToLibrary:)
                                                 name: kDidWriteProcessedImageToPhotoLibraryNotification 
                                               object: nil];
	
    
    [self.view setBackgroundColor:kBackgroundColor];
    [_toolbar setTintColor:[UIColor colorWithWhite:0.9 alpha:1.0]];
    
	[self setBackgroundImage];
	[self setToolbarItems];
	[self disableToolbarItems: kAllItems];
	_toolbar.alpha = 0.0;
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden: YES];
}

- (void) viewDidUnload 
{
	//NSLog(@"###---> viewDidUnload");
	
	[super viewDidUnload];

    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];

    [[NSNotificationCenter defaultCenter] removeObserver: self
													name: UIDeviceOrientationDidChangeNotification 
												  object: nil];

	[[NSNotificationCenter defaultCenter] removeObserver: self
													name: kDidWriteOriginalImageToPhotoLibraryNotification 
												  object: nil];
	
    [[NSNotificationCenter defaultCenter] removeObserver: self
													name: kDidWriteProcessedImageToPhotoLibraryNotification 
												  object: nil];	
	
}

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation 
{
	return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (void) didReceiveMemoryWarning
{
	NSLog(@"###---> didReceiveMemoryWarning");

	[self clearBackgroundImage];
    [super didReceiveMemoryWarning];
}

- (void) _orientationChanged: (NSNotification*) notification
{
    
}

#pragma mark - Capture Photo

- (IBAction) capturePhoto: (id) sender
{
//    BOOL usePolaroid = [[NSUserDefaults standardUserDefaults] boolForKey: kShakeItPhotoPolaroidBorderKey];
    
//    CGSize finalSize = (usePolaroid) ? CGSizeMake(1920.0, 2300.0) : CGSizeMake(1920.0, 1876.0);
//    CGRect imageSize = [ShakeItPhotoImageProcessor computeImageRect:finalSize usePolaroidAssets:usePolaroid];
//    CGRect previewRect = CGRectMake(0, 44, SC_APP_SIZE.width, SC_APP_SIZE.width);
//    previewRect.size.height *= (imageSize.size.height / imageSize.size.width);

    
    //previewRect.size.width = 20.0;
    //previewRect.size.height = 200.0;
    
//    NSLog(@"###---> preview rect %@",NSStringFromCGRect(previewRect));
//    SCNavigationController *nav = [[SCNavigationController alloc] init];
//    nav.scNaigationDelegate = self;
//    //nav.customAlbumName = @"Shake It Photo";
//    [nav showCameraWithParentController:self previewRect:previewRect];
//    [nav release];
    
    if([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.delegate = self;
//        picker.showsCameraControls = NO;
        picker.allowsEditing = NO;
//        picker.modalPresentationStyle =
        
        [self presentViewController:picker animated:YES completion:^{}];
        
        /*
        _toolbar.alpha = 0.0;
		[self disableToolbarItems: kAllItems];
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.delegate = self;
        picker.showsCameraControls = NO;
        picker.allowsEditing = NO;
        picker.modalPresentationStyle = UIModalPresentationCurrentContext;
        
        if([[UIImagePickerController class] respondsToSelector: @selector(isFlashAvailableForCameraDevice:)])
        {
            picker.cameraFlashMode = ApplicationDelegate().flashMode;
        }
        
        BOOL usePolaroid = [[NSUserDefaults standardUserDefaults] boolForKey: kShakeItPhotoPolaroidBorderKey];
        CGRect croprect = CGRectMake(0.0, 55.0, self.view.frame.size.width,
                                     self.view.frame.size.width);
        
        if(usePolaroid) {
            croprect.size.height *= (1714.0f / 1709.0f);
        } else {
            croprect.size.height *= (1714.0f / 1664.0f);
        }
        
        UIView *overlay = [[UIView alloc] initWithFrame:picker.view.frame];
        
        const CGFloat PAD = 0.0;
        UIColor *color = [UIColor colorWithWhite:0.0 alpha:1.0];
        CGSize    size = picker.view.frame.size;
        
        //top
        UIView   *blocker = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0,size.width,croprect.origin.y - PAD)];
        [blocker setBackgroundColor:color];
        [overlay addSubview:blocker];
        ReleaseAndClear(blocker);
        
        //bottom
        blocker = [[UIView alloc] initWithFrame:CGRectMake(0.0, CGRectGetMaxY(croprect) + PAD,size.width,size.height - (CGRectGetMaxY(croprect) + PAD))];
        [blocker setBackgroundColor:color];
        [overlay addSubview:blocker];
        blocker.userInteractionEnabled = NO;
        ReleaseAndClear(blocker);
        
        //left
        CGFloat sideBlockerHeight = size.height - (size.height - (CGRectGetMaxY(croprect) + PAD) + (_croprect.origin.y - PAD));
        blocker = [[UIView alloc] initWithFrame:CGRectMake(0.0, CGRectGetMinY(croprect) - PAD,CGRectGetMinX(croprect) - PAD,sideBlockerHeight)];
        [blocker setBackgroundColor:color];
        [overlay addSubview:blocker];
        ReleaseAndClear(blocker);
        
        //right
        blocker = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(croprect) + PAD, CGRectGetMinY(croprect) - PAD,size.width - (CGRectGetMaxX(croprect) + PAD),sideBlockerHeight)];
        [blocker setBackgroundColor:color];
        [overlay addSubview:blocker];
        ReleaseAndClear(blocker);
        
    
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setBackgroundColor:[UIColor colorWithWhite:0.2 alpha:1.0]];
        [button setFrame:CGRectMake((self.view.frame.size.width - 66.0)/2, self.view.frame.size.height - 80.0, 66.0,66.0)];
        [button addTarget:self action:@selector(onTakePictureTap:) forControlEvents:UIControlEventTouchUpInside];
        [overlay addSubview:button];
        
        [picker setCameraOverlayView:overlay];
        ReleaseAndClear(overlay);
        
        [self presentViewController:picker animated:YES completion:nil];
        
        [self setPicker:picker];
        ReleaseAndClear(picker);
        
        //color = nil;
        */
    }
}

#pragma mark - Buttons

- (IBAction) choosePhoto: (id) sender
{
	if([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary])
	{
		_toolbar.alpha = 0.0;
		[self disableToolbarItems: kAllItems];

		UIImagePickerController* picker = [[UIImagePickerController alloc] init];
		picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
	}
}

#pragma mark Activity View

- (IBAction) performAction: (id) sender
{

    ALAssetsLibrary*	library = [[ALAssetsLibrary alloc] init];
    
    [library assetForURL: _latestProcessedImageURL
             resultBlock:^(ALAsset *asset) {
                 
                 ALAssetRepresentation *rep = [asset defaultRepresentation];
                 CGImageRef iref = [rep fullResolutionImage];
                 if (iref) {
                     UIImage *image = [UIImage imageWithCGImage:iref];
                     
                     
                     NSArray *activities = @[];
//                     NSURL *instagramURL = [NSURL URLWithString:@"instagram://location?id=1"];
//                     InstagramActivity *instagram = [[InstagramActivity alloc] init];
//                     [instagram setActivity:^{
//
//                         if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
//                            [self shareImageToInstagram];
//                         } else {
//                             [self dismissViewControllerAnimated:YES completion:^{
//                                 [self shareImageToInstagram];
//                             }];
//                         }
//                     }];
//
//                     if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
//                         activities = @[instagram];
//                     }
                     
                     NSString *shareText = @"Made with #ShakeItPhoto";
                     NSURL *shareURL = [NSURL URLWithString:@"http://www.momentpark.com/shakeitphoto"];
                     NSArray *activityItems = @[image, shareText, shareURL];
                     
                     UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
                     activityViewController.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll, UIActivityTypeAirDrop];
                     activityViewController.popoverPresentationController.barButtonItem = sender;
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [self presentViewController:activityViewController animated:YES completion:nil];
                     });
                 }
             }
            failureBlock:^(NSError *error) {
                NSLog(@"###---> _loadProcessedImageDataForURL failed - %@", [error description]);
            }];
}

- (void) shareImageToInstagram
{
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL])
    {
        
        ALAssetsLibrary*	library = [[ALAssetsLibrary alloc] init];
        [library assetForURL: _latestProcessedImageURL
                 resultBlock:^(ALAsset *asset) {
                     
                      ALAssetRepresentation *rep = [asset defaultRepresentation];
                     CGImageRef imageRef = [rep fullResolutionImage];
                     if (imageRef) {
                         
                         CGRect newRect   = CGRectIntegral(CGRectMake(0.0, 0.0, 640.0, 640.0));
                         CGRect scaleRect = newRect;
                         
                         scaleRect.size.height *= (CGFloat)CGImageGetHeight(imageRef)/(CGFloat)CGImageGetWidth(imageRef);
                         scaleRect.origin.y = newRect.size.height - scaleRect.size.height;
                         
                         //NSLog(@"###---> %f",(CGFloat)CGImageGetWidth(imageRef)/(CGFloat)CGImageGetHeight(imageRef));
                         // Build a context that's the same dimensions as the new size
                         CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                                     newRect.size.width,
                                                                     newRect.size.height,
                                                                     CGImageGetBitsPerComponent(imageRef),
                                                                     0,
                                                                     CGImageGetColorSpace(imageRef),
                                                                     CGImageGetBitmapInfo(imageRef));
                         
                         // Rotate and/or flip the image if required by its orientation
                         //CGContextConcatCTM(bitmap, transform);
                         
                         // Set the quality level to use when rescaling
                         CGContextSetInterpolationQuality(bitmap, kCGInterpolationHigh);
                         
                         CGContextSetFillColorWithColor(bitmap, UIColor.whiteColor.CGColor);
                         CGContextFillRect(bitmap, newRect);
                         // Draw into the context; this scales the image
                         CGContextDrawImage(bitmap, scaleRect, imageRef);
                         
                         // Get the resized image from the context and a UIImage
                         CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
                         
                         UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
                         
                         // Clean up
                         CGContextRelease(bitmap);
                         CGImageRelease(newImageRef);
                         
                         
                         [self presentImageInInstagram:newImage];
                         
                         /*
                         
                
                         const CGSize finalSize = CGSizeMake(640.0, 640.0);
                         UIImage *imagez = [UIImage imageWithCGImage:iref];
                         CGRect cropRect = CGRectMake(0.0, 0.0, finalSize.width,finalSize.height);
                         CGSize size     = finalSize;
                         BOOL scaleToFill = NO;
                         if (scaleToFill) {
                             size.height *= finalSize.height/imagez.size.width;
                         } else {
                             size.width *= finalSize.width/imagez.size.height;
                             cropRect.origin.x = (size.width - finalSize.width)/2;
                         }
                         
                         NSLog(@"###---> size %f %f",size.width,size.height);
                         UIImage *image = [imagez resizedImage:size interpolationQuality:kCGInterpolationDefault];
                         NSLog(@"###---> image size %f %f",image.size.width,image.size.height);
                         
                         CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
                         NSString *jpgPath   = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/test.igo"];
                         UIImage *img = [[UIImage alloc] initWithCGImage:imageRef];
                         
                         [UIImageJPEGRepresentation(img, 1.0) writeToFile:jpgPath atomically:YES];
                         
                         CGImageRelease(imageRef);
                        
                         ReleaseAndClear(img);
                         
                         NSURL *igImageHookFile = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@",jpgPath]];
                         
                         UIDocumentInteractionController *doc = [UIDocumentInteractionController interactionControllerWithURL:igImageHookFile];
                         
                         doc.delegate = self;
                         doc.annotation = @{@"InstagramCaption":@"Shake it Photo"};
                         doc.UTI = @"com.instagram.exclusivegram";
                         
                         [doc presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
                         [self setDoc:doc];
                          */
                     }
                 }
                failureBlock:^(NSError *error) {
                    NSLog(@"###---> _loadProcessedImageDataForURL failed - %@", [error description]);
                }];
                          
    } else {
        //DisplayAlert(@"Instagram not installed in this device!\nTo share image please install instagram.");
    }
}

-(void)presentImageInInstagram:(UIImage*)image {
    
    NSString *jpgPath   = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/test.igo"];
    [UIImageJPEGRepresentation(image, 1.0) writeToFile:jpgPath atomically:YES];
   
    NSURL *igImageHookFile = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@",jpgPath]];
    UIDocumentInteractionController *doc = [UIDocumentInteractionController interactionControllerWithURL:igImageHookFile];
    
    doc.delegate    = self;
    doc.annotation  = @{@"InstagramCaption":@"#ShakeItPhoto"};
    doc.UTI         = @"com.instagram.exclusivegram";
    
    [doc presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
    [self setDoc:doc];
    doc = nil;
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller
        willBeginSendingToApplication:(NSString *)application {
    NSLog(@"###---> Start!");
}

-(void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application
{
    NSLog(@"###---> Endg!");
}


- (IBAction) saveOriginal: (id) sender
{
    UISwitch*   what = (UISwitch*)sender;
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool: [what isOn] forKey: kBananaCameraSaveOriginalKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}


-(void)onSettingsDoneTap:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction) chooseOptions: (id) sender
{
    SettingsTableViewController *settings = [[SettingsTableViewController alloc] init];
    settings.title = @"Options";
    
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:settings];
    [nav setNavigationBarHidden:NO];
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(onSettingsDoneTap:)];
    settings.navigationItem.leftBarButtonItem = done;

    
    nav.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:nav animated:YES completion:^{
        
    }];
    
}

#pragma mark - SCNavigationControllerDelegate

//-(void)didTakePicture:(SCNavigationController *)navigationController image:(UIImage *)image {
//    
//    [self clearBackgroundImage];
//    navigationController.delegate = nil;
//}
//
//- (BOOL)willDismissNavigationController:(SCNavigationController *)navigatonController {
//    
//    [self setBackgroundImage];
//    return YES;
//}
//


#pragma mark - UIImagePickerControllerDelegate

- (void) imagePickerController: (UIImagePickerController*) picker didFinishPickingMediaWithInfo: (NSDictionary*) info
{
	[self clearBackgroundImage];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if(picker.sourceType == UIImagePickerControllerSourceTypeCamera &&
       [[UIImagePickerController class] respondsToSelector: @selector(isFlashAvailableForCameraDevice:)])
    {
        ApplicationDelegate().flashMode = picker.cameraFlashMode;
    }
}

- (void) imagePickerControllerDidCancel: (UIImagePickerController*) picker
{
	[self setBackgroundImage];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark
- (void) enableFuntionalToolbarItems {
    for(UIBarButtonItem* item in [self.toolbar items])
    {
        if(@selector(performAction:) == [item action] && _latestProcessedImageURL == nil) {
            item.enabled = NO;
        } else {
            item.enabled = YES;
        }
    }
}

- (void) disableToolbarItems: (uint) itemsToDisable
{
	if(itemsToDisable & kCapturePhotoItem)
	{
		[self _capturePhotoBarButtonItem].enabled = NO;
	}
	
	if(itemsToDisable & kPickPhotoItem)
	{
		[self _pickPhotoBarButtonItem].enabled = NO;
	}
	
	if(itemsToDisable & kSettingsItem)
	{
		[self _settingsBarButtonItem].enabled = NO;
	}
	
	if(itemsToDisable & kActionItem)
	{
		[self _actionBarButtonItem].enabled = NO;
	}
}

- (UIBarButtonItem*) _pickPhotoBarButtonItem
{
	UIBarButtonItem*	result = nil;
	
	for(UIBarButtonItem* item in [self.toolbar items])
	{
		if(@selector(choosePhoto:) == [item action])
		{
			result = item;
			break;
		}
	}
	
	return result;
}

- (UIBarButtonItem*) _capturePhotoBarButtonItem
{
	UIBarButtonItem*	result = nil;
	
	for(UIBarButtonItem* item in [self.toolbar items])
	{
		if(@selector(capturePhoto:) == [item action])
		{
			result = item;
			break;
		}
	}
	
	return result;
}

- (UIBarButtonItem*) _actionBarButtonItem
{
	UIBarButtonItem*	result = nil;
	
	for(UIBarButtonItem* item in [self.toolbar items])
	{
		if(@selector(performAction:) == [item action])
		{
			result = item;
			break;
		}
	}
	
	return result;
}

- (UIBarButtonItem*) _settingsBarButtonItem
{
	UIBarButtonItem*	result = nil;
	
	for(UIBarButtonItem* item in [self.toolbar items])
	{
		if(@selector(chooseOptions:) == [item action])
		{
			result = item;
			break;
		}
	}
	
	return result;
}

-(UIBarButtonItem*)barButtonItemWithIcon:(unichar)icon action:(SEL)action {
    
    
    UIButton *label = [UIButton buttonWithType:UIButtonTypeCustom];
    [label setFrame:CGRectMake(0.0, 0.0, 30.0, 30.0)];
    [label setTitle:[NSString stringWithFormat:@"%C",icon] forState:UIControlStateNormal];
    [label setTitleColor:_toolbar.tintColor forState:UIControlStateNormal];
    label.titleLabel.font = [UIFont fontWithName:@"FontAwesome" size:25.0];
    [label addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *b2 = [[UIBarButtonItem alloc] initWithCustomView:label];
    
    return b2;
    
    /*
    UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithTitle: [NSString stringWithFormat:@"%C",icon]
                                      style: UIBarButtonItemStylePlain
                                                               target: self
                                     action: action] autorelease];
    
    [button setBackgroundVerticalPositionAdjustment:100.0 forBarMetrics:UIBarMetricsDefault];

    
                           
    [button setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"FontAwesome" size:26.0],
                                     NSForegroundColorAttributeName: _toolbar.tintColor
                                                                } forState:UIControlStateNormal];*/
    
    
    
    //return button;
}

-(UIBarButtonItem*)barButtonItemWithSystemItem:(UIBarButtonSystemItem)item action:(SEL)action {
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:item target:self action:action];

    return button;
}

- (void) setToolbarItems
{
    UIBarButtonItem*    flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil];
    

    UIBarButtonItem* actionButton = [self barButtonItemWithSystemItem:UIBarButtonSystemItemAction action:@selector(performAction:)];
    UIBarButtonItem* infoButton   = [self barButtonItemWithIcon:0xf013 action:@selector(chooseOptions:)];
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    space.width = 20;

    NSMutableArray *items = [NSMutableArray arrayWithObjects:space,actionButton,flexibleSpace,infoButton,space, nil];
    
	if([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera] == YES)
	{
        UIBarButtonItem*    cameraButton = [self barButtonItemWithSystemItem:UIBarButtonSystemItemCamera action:@selector(capturePhoto:)];
        [items insertObject:flexibleSpace atIndex:3];
        [items insertObject:cameraButton atIndex:3];
    }
    
    if([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary] ||
       [UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeSavedPhotosAlbum])
    {
        UIBarButtonItem*    photoButton = [self barButtonItemWithSystemItem:UIBarButtonSystemItemAdd action:@selector(choosePhoto:)];
        [items insertObject:flexibleSpace atIndex:3];
        [items insertObject:photoButton atIndex:3];
    }
    
    [self.toolbar setItems: items animated: NO];
}

#pragma mark -
#pragma mark Touch Support

- (void) touchesBegan: (NSSet*) touches withEvent: (UIEvent*) event
{
}

- (void) touchesMoved: (NSSet*) touches withEvent: (UIEvent*) event
{
}

- (void) touchesEnded: (NSSet*) touches withEvent: (UIEvent*) event
{
    
    if(!_welcomeMode)
    {
        CGFloat             alpha;
        CFTimeInterval      duration;
        
        if(_toolbar.alpha == 0.0)
        {
            alpha = 1.0;
            duration = 0.3;
        }
        else 
        {
            alpha = 0.0;
            duration = 0.3;
        }
        
        [UIView animateWithDuration:duration animations:^{
           _toolbar.alpha = alpha;
        }];
    }
}

- (void) touchesCancelled: (NSSet*) touches withEvent: (UIEvent*) event
{    
}

#pragma mark -
#pragma mark Animation Support

- (void) showWelcomeView
{
	if(_welcomeView)
	{
        
        //[_welcomeView setFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
        
        _welcomeView.backgroundColor = kBackgroundColor;
        _welcomeView.center = self.view.center;
        
		UIView*  rootView = [self.view superview];
        [rootView insertSubview: self.welcomeView aboveSubview: self.view];
		_welcomeMode = YES;
	}
}

- (void) disposeOfWelcomeView
{
    _welcomeMode = NO;
    
    if(_welcomeView)
    {
        [_welcomeView removeFromSuperview];
        _welcomeView = nil;
    }
}

- (IBAction) introVideo:(id)sender {
    NSURL *url = [NSURL URLWithString:kBananaCameraIntroVideoURL];
    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction) acknowledgeWelcome: (id) sender
{
    [UIView animateWithDuration:0.33 animations:^{
        
        self.welcomeView.alpha = 0.0;
        
    } completion:^(BOOL finished) {
        self.welcomeView.alpha = 0.0;
        [self disposeOfWelcomeView];
        
        if([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
            [self capturePhoto: nil];
        } else {
            [self choosePhoto: nil];
        }
    }];
}

- (void) playSoundEffect: (NSString*) soundFile
{
    NSString*   soundEffectPath = [[NSBundle mainBundle] pathForResource: [soundFile stringByDeletingPathExtension] ofType: [soundFile pathExtension]];
    _soundEffect = [[BananaCameraSoundEffect alloc] initWithContentsOfFile: soundEffectPath];
    [_soundEffect play];
}

#pragma mark -
#pragma mark Abstract Methods

- (NSString*) defaultPhotoName
{
	return @"A Great BananaCamera Photo";
}

- (void) setBackgroundImage
{
}

- (void) clearBackgroundImage
{
}

- (void) applicationWillEnterForeground
{
	[self setBackgroundImage];
}

-(void)applicationWillResignActive {
    
}

- (void) applicationDidEnterBackground
{
	[self clearBackgroundImage];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger) tableView: (UITableView*) table numberOfRowsInSection: (NSInteger) section
{
	return 0;
}

- (UITableViewCell*) tableView: (UITableView*) tableView cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
	return nil;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (CGFloat) tableView: (UITableView*) tableView heightForHeaderInSection: (NSInteger) section
{
	CGFloat	height = 26.0;
	
	if(section == 0)
	{
		height = 30.0;
	}
	
	return height;
}


- (NSString*) _mimeTypeForUTI: (NSString*) uti
{
	NSString*	mimeType = @"";
	
	if([uti isEqualToString: @"public.jpeg"])
	{
		mimeType = @"image/jpeg";
	}
	else if([uti isEqualToString: @"public.png"])
	{
		mimeType = @"image/png";
	}
	
	return mimeType;
}

- (NSString*) _createTempFileNameInDirectory: (NSString*) directory extension: (NSString*) ext
{
    NSString*   templateStr = [NSString stringWithFormat:@"%@/image-XXXXX", directory];
    char        template[templateStr.length + 1];
    
    strcpy(template, [templateStr cStringUsingEncoding: NSASCIIStringEncoding]);
    char*       filename = mktemp(template);
    
    if(filename == NULL)
    {
        NSLog(@"###---> Could not create file in directory %@", directory);
        return nil;
    }

    NSString* result = [NSString stringWithCString: filename encoding: NSASCIIStringEncoding];
    result = [result stringByAppendingPathExtension: ext];
    return result;
}

#pragma mark -
#pragma mark Notifications

- (void) imageProcessorWroteOriginalImageToLibrary: (NSNotification*) notification
{
	NSDictionary*	userInfo = [notification userInfo];
	NSURL*			imagePath = nil;
	NSError*		error = nil;
	
	imagePath = (NSURL*)[userInfo objectForKey: @"url"];
	error = (NSError*)[userInfo objectForKey: @"error"];
	
	if(imagePath)
	{
		//NSLog(@"###---> Did write original image to photo library - %@", [imagePath absoluteString]);
	}
	else if(error)
	{
		NSLog(@"###---> Error writing original image written to photo library - %@", [error description]);
	}
}

- (void) imageProcessorWroteProcessedImageToLibrary: (NSNotification*) notification
{
	NSDictionary*	userInfo = [notification userInfo];
	NSURL*			imagePath = nil;
	NSError*		error = nil;
	
	imagePath = (NSURL*)[userInfo objectForKey: @"url"];
	error = (NSError*)[userInfo objectForKey: @"error"];
    
	if(imagePath)
	{
		//NSLog(@"###---> Did write processed image to photo library - %@", [imagePath absoluteString]);
		_latestProcessedImageURL = imagePath;        
    } else {
        _latestProcessedImageURL = nil;
    }
    [self enableFuntionalToolbarItems];
	if(error)
	{
		NSLog(@"###---> Error writing processed image written to photo library - %@", [error description]);
	}
}

@end

void BananaCameraAudioSessionInterruptionListener(BananaCameraViewController* viewController, UInt32 inInterruptionState)
{
	// no-op
}

