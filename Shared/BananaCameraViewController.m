//
//  BananaCameraViewController.m
//
//  Copyright 2010 Banana Camera Company. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "BananaCameraViewController.h"
#import "BananaCameraAppDelegate.h"
#import "BananaCameraUtilities.h"
#import "BananaCameraSoundEffect.h"
#import "BananaCameraConstants.h"
#import "BananaCameraGrowlView.h"
#import "NSObject+DDExtensions.h"
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
- (void) _loadProcessedImageDataForURL: (NSURL*) url forDestination: (NSString*) destination;
- (void) _emailPhoto: (NSData*) photoData  ofType: (NSString*) uti;
- (void) _facebookPhoto: (NSData*) photoData  ofType: (NSString*) uti;
- (void) _instagramPhoto: (NSData*) photoData  ofType: (NSString*) uti;
- (NSString*) _mimeTypeForUTI: (NSString*) uti;
- (void) _postPhotoToFacebookAlbum: (NSString*) albumID;
- (NSString*) _createTempFileNameInDirectory: (NSString*) directory extension: (NSString*) ext;

@end

void BananaCameraAudioSessionInterruptionListener(BananaCameraViewController* viewController, UInt32 inInterruptionState);

@implementation BananaCameraViewController

@synthesize toolbar = _toolbar;
@synthesize welcomeView = _welcomeView;
@synthesize optionsView = _optionsView;
@synthesize keepOriginalCell = _keepOriginalCell;
@synthesize infoCell = _infoCell;
@synthesize communityCell = _communityCell;
@synthesize optionsNavigationBar = _optionsNavigationBar;
@synthesize optionsTableView = _optionsTableView;
@synthesize croprect = _croprect;
@synthesize picker = _picker;

- (void) dealloc 
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];

	[_optionsView removeFromSuperview];
	ReleaseAndClear(_optionsView);

	[_welcomeView removeFromSuperview];
	ReleaseAndClear(_welcomeView);
	ReleaseAndClear(_soundEffect);		// maybe move this to subclasses?
	
    [super dealloc];
}

- (void) viewDidLoad
{
	//NSLog(@"viewDidLoad");

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
    [_toolbar setTintColor:[UIColor colorWithWhite:0.3333 alpha:1.0]];
    
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
	//NSLog(@"viewDidUnload");
	
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
	NSLog(@"didReceiveMemoryWarning");

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
    
//    NSLog(@"preview rect %@",NSStringFromCGRect(previewRect));
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

-(void)onTakePictureTap:(id)sender {
    [self.picker takePicture];
}

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

    ALAssetsLibrary*	library = [[[ALAssetsLibrary alloc] init] autorelease];
    
    [library assetForURL: _latestProcessedImageURL
             resultBlock:^(ALAsset *asset) {
                 
                 ALAssetRepresentation *rep = [asset defaultRepresentation];
                 CGImageRef iref = [rep fullResolutionImage];
                 if (iref) {
                     UIImage *image = [UIImage imageWithCGImage:iref];
                     
                     
                     NSMutableArray *array = [[NSMutableArray alloc] init];
                     
                     NSURL *instagramURL = [NSURL URLWithString:@"instagram://location?id=1"];
                     if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
                         InstagramActivity *ac = [[InstagramActivity alloc] init];
                         [ac setActivity:^{
                             
                             if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
                                [self shareImageToInstagram];
                             } else {
                                 [self dismissViewControllerAnimated:YES completion:^{
                                     [self shareImageToInstagram];
                                 }];
                             }
                         }];
                         [array addObject:ac];
                         [ac release];
                     }
                     
                     UIActivityViewController *activityViewController =
                     [[[UIActivityViewController alloc] initWithActivityItems:@[image,@"#ShakeItPhoto"]
                                                        applicationActivities:array] autorelease];
                     
                     [array release];
                     
                     activityViewController.excludedActivityTypes = @[UIActivityTypeAirDrop,
                                                                      UIActivityTypeAssignToContact,
                                                                      UIActivityTypeCopyToPasteboard,
                                                                      UIActivityTypePrint,
                                                                      UIActivityTypeSaveToCameraRoll];
                     
                     [self presentViewController:activityViewController
                                        animated:YES
                                      completion:^{
                                          // ...
                                      }];
                     
                     [image retain];
                 }
             }
            failureBlock:^(NSError *error) {
                NSLog(@"_loadProcessedImageDataForURL failed - %@", [error description]);
            }];
}

- (void) shareImageToInstagram
{
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL])
    {
        
        ALAssetsLibrary*	library = [[[ALAssetsLibrary alloc] init] autorelease];
        [library assetForURL: _latestProcessedImageURL
                 resultBlock:^(ALAsset *asset) {
                     
                      ALAssetRepresentation *rep = [asset defaultRepresentation];
                     CGImageRef imageRef = [rep fullResolutionImage];
                     if (imageRef) {
                         
                         CGRect newRect   = CGRectIntegral(CGRectMake(0.0, 0.0, 640.0, 640.0));
                         CGRect scaleRect = newRect;
                         
                         BOOL makeSquare = [[NSUserDefaults standardUserDefaults] boolForKey: kShakeItPhotoMakeSquareKey];
                         
                         if (makeSquare) {
                             scaleRect.size.width *= (CGFloat)CGImageGetWidth(imageRef)/(CGFloat)CGImageGetHeight(imageRef);
                             scaleRect.origin.x    = (newRect.size.width - scaleRect.size.width)/2;
                         } else {
                             scaleRect.size.height *= (CGFloat)CGImageGetHeight(imageRef)/(CGFloat)CGImageGetWidth(imageRef);
                             scaleRect.origin.y = newRect.size.height - scaleRect.size.height;
                         }
                         
                         //NSLog(@"%f",(CGFloat)CGImageGetWidth(imageRef)/(CGFloat)CGImageGetHeight(imageRef));
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
                         
                         NSLog(@"size %f %f",size.width,size.height);
                         UIImage *image = [imagez resizedImage:size interpolationQuality:kCGInterpolationDefault];
                         NSLog(@"image size %f %f",image.size.width,image.size.height);
                         
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
                    NSLog(@"_loadProcessedImageDataForURL failed - %@", [error description]);
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
    NSLog(@"Start!");
}

-(void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application
{
    NSLog(@"Endg!");
}


- (IBAction) saveOriginal: (id) sender
{
    UISwitch*   what = (UISwitch*)sender;
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool: [what isOn] forKey: kBananaCameraSaveOriginalKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction) moreInfo: (id) sender
{
	if(!_moreInfoWebView)
	{
		_moreInfoWebView = [[UIWebView alloc] initWithFrame: CGRectZero];
		_moreInfoWebView.scalesPageToFit = YES;
		_moreInfoWebView.delegate = self;
		
		// Webview frame is the full size of the screen - the height of the navigation bar.
		
		CGRect			webViewFrame = self.optionsTableView.frame;
		webViewFrame.origin.x += webViewFrame.size.width;
		webViewFrame.origin.y += self.optionsNavigationBar.frame.size.height;
		webViewFrame.size.height -= self.optionsNavigationBar.frame.size.height;
		_moreInfoWebView.frame = webViewFrame;
	}		
	
	// Insert the webview as a sibling of the options view (below it - to ensure that it's also below the navigation bar)
	
	[self.optionsView.superview insertSubview: _moreInfoWebView aboveSubview: self.optionsView];
	
	// Calculate the final (animatable) frames
	
	CGRect			newWebViewFrame = _moreInfoWebView.frame;
	newWebViewFrame.origin.x -= CGRectGetWidth(newWebViewFrame);
	
	// Animate them into place.
    
    [UIView animateWithDuration:0.4 animations:^{
      _moreInfoWebView.frame = newWebViewFrame;
    }];
	
    _moreInfoWebView.backgroundColor = [UIColor clearColor];
	[_moreInfoWebView loadRequest: [NSURLRequest requestWithURL: [NSURL URLWithString: kBananaCameraMoreAppsURL]]];
	
	UINavigationItem*	navItem = [[[UINavigationItem alloc] initWithTitle: @"More Apps"] autorelease];
	[self.optionsNavigationBar pushNavigationItem: navItem animated: YES];
}


- (IBAction) community: (id) sender
{
	if(!_socialWebView)
	{
		_socialWebView = [[UIWebView alloc] initWithFrame: CGRectZero];
		_socialWebView.scalesPageToFit = YES;
		_socialWebView.delegate = self;
		
		// Webview frame is the full size of the screen - the height of the navigation bar.
		
		CGRect			webViewFrame = self.optionsTableView.frame;
		webViewFrame.origin.x += webViewFrame.size.width;
		webViewFrame.origin.y += self.optionsNavigationBar.frame.size.height;
		webViewFrame.size.height -= self.optionsNavigationBar.frame.size.height;
		_socialWebView.frame = webViewFrame;
	}		
	
	// Insert the webview as a sibling of the options view (below it - to ensure that it's also below the navigation bar)
	
	[self.optionsView.superview insertSubview: _socialWebView aboveSubview: self.optionsView];
	
	// Calculate the final (animatable) frames
	
	CGRect			newWebViewFrame = _socialWebView.frame;
	newWebViewFrame.origin.x -= CGRectGetWidth(newWebViewFrame);
	
	// Animate them into place.
	
    [UIView animateWithDuration:0.4 animations:^{
        _socialWebView.frame = newWebViewFrame;
    }];
	
	
	_socialWebView.backgroundColor = [UIColor clearColor];
	[_socialWebView loadRequest: [NSURLRequest requestWithURL: [NSURL URLWithString: kBananaCameraSocialURL]]];
	
	UINavigationItem*	navItem = [[[UINavigationItem alloc] initWithTitle: @"Community"] autorelease];
	[self.optionsNavigationBar pushNavigationItem: navItem animated: YES];
}

- (IBAction) handleDone: (id) sender
{
    [self chooseOptions: nil];
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
    
    [settings release];
    [nav release];
}

- (void) setupOptions
{
	NSUserDefaults*     defaults = [NSUserDefaults standardUserDefaults];
	UISwitch*           aSwitch;
		
	aSwitch = (UISwitch*)[_keepOriginalCell.contentView viewWithTag: 1];
	[aSwitch setOn: [defaults boolForKey: kBananaCameraSaveOriginalKey] animated: YES];
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
    
    _picker.delegate = nil;
    ReleaseAndClear(_picker);
}

- (void) imagePickerControllerDidCancel: (UIImagePickerController*) picker
{
	[self setBackgroundImage];
    [self dismissViewControllerAnimated:YES completion:nil];
    [picker release];
}

#pragma mark

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

- (void) enableToolbarItems: (uint) itemsToEnable
{
	if(itemsToEnable & kCapturePhotoItem)
	{
		[self _capturePhotoBarButtonItem].enabled = YES;
	}
	
	if(itemsToEnable & kPickPhotoItem)
	{
		[self _pickPhotoBarButtonItem].enabled = YES;
	}

	if(itemsToEnable & kSettingsItem)
	{
		[self _settingsBarButtonItem].enabled = YES;
	}

	if(itemsToEnable & kActionItem)
	{
		[self _actionBarButtonItem].enabled = YES;
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
    
    
    UIButton *label = [[UIButton buttonWithType:UIButtonTypeCustom] autorelease];
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
    UIBarButtonItem*    flexibleSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil] autorelease];
    

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
		ReleaseAndClear(_welcomeView);
    }
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
	ReleaseAndClear(_soundEffect);
    
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
    
	if([self.optionsView superview] != nil)
	{
		[self chooseOptions: nil];
	}
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

#pragma mark -
#pragma mark UINavigationBarDelegate

- (BOOL) navigationBar: (UINavigationBar*) navigationBar shouldPopItem: (UINavigationItem*) item
{
	if([item.title isEqualToString: @"More Apps"])
	{
		// Calculate the final (animatable) frames
		
		CGRect			newWebViewFrame = _moreInfoWebView.frame;
		newWebViewFrame.origin.x += CGRectGetWidth(newWebViewFrame);
		
		// Animate them into place.
        [UIView animateWithDuration:0.4 animations:^{
            _moreInfoWebView.frame = newWebViewFrame;
        }];
        
	} else if([item.title isEqualToString: @"Community"]) {
		// Calculate the final (animatable) frames
		
		CGRect			newWebViewFrame = _socialWebView.frame;
		newWebViewFrame.origin.x += CGRectGetWidth(newWebViewFrame);
		
        [UIView animateWithDuration:0.4 animations:^{
            _socialWebView.frame = newWebViewFrame;
        }];
	}
	return YES;
}

- (void) actionSheet: (UIActionSheet*) actionSheet didDismissWithButtonIndex: (NSInteger) buttonIndex
{
	if(ApplicationDelegate().canSendMail == NO)
	{
		buttonIndex += 1;
	}
	
	/* Email = 0, Facebook = 1, Instagram = 2 */
	
	switch(buttonIndex)
	{
		case 0:
			[self emailPhoto: nil];
			break;
		case 1:
			[self facebookPhoto: nil];
			break;
        case 2:
            [self instagramPhoto: nil];
		default:
			break;
	}
}

#pragma mark -
#pragma mark Facebook

- (void) facebookPhoto: (id) sender
{
	NSArray*	permissions = [NSArray arrayWithObjects: @"user_photos", @"publish_stream", @"read_stream", @"offline_access", nil];
	Facebook*	fbSession = [ApplicationDelegate() facebookSession];
	
	if(![fbSession isSessionValid])
	{
		[fbSession authorize: permissions delegate: self];
	}
	else 
	{
		[self fbDidLogin];
	}

}

- (void) fbDidLogin
{
	[[ApplicationDelegate() facebookSession] requestWithGraphPath: @"me/albums" andDelegate: self];
}

- (void) fbDidNotLogin: (BOOL) cancelled
{
}

- (void) fbDidLogout
{
}

- (void) request: (FBRequest*) request didFailWithError: (NSError*) error
{
	NSLog(@"FBRequest failed: %@", [error description]);
}

- (void) request: (FBRequest*) request didLoad: (id) result
{
	NSString*	method = [request.url lastPathComponent];
	
	if([method isEqualToString: @"albums"])
	{
		if([result isKindOfClass: [NSDictionary class]])
		{
			NSString*		albumID = [result objectForKey: @"id"];
			
			if(!albumID)
			{
				NSDictionary*	albums = (NSDictionary*)[result objectForKey: @"data"];
				
				for(NSDictionary* album in albums)
				{
					if([[album objectForKey: @"name"] isEqualToString: @"My ShakeItPhoto Photos"])
					{
						albumID = [album objectForKey: @"id"];
					}
				}
				
				if(albumID == nil)
				{
					NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys: @"My ShakeItPhoto Photos", @"name",
												   @"Photos created by the iPhone app - ShakeItPhoto", @"description",
												   @"everyone", @"visible", nil];
					
					[[ApplicationDelegate() facebookSession] requestWithGraphPath: @"me/albums" 
																		andParams: params
																	andHttpMethod: @"POST"
																	  andDelegate: self];
				}
			}
			
			if(albumID) 
			{
				[self _postPhotoToFacebookAlbum: albumID];
			}
		}
	}  
	else if([method isEqualToString: @"photo"])
	{
	}
}

- (void) _postPhotoToFacebookAlbum: (NSString*) albumID
{
	[self presentGrowlNotification: @"Sending your photo to Facebook"];
	
	ReleaseAndClear(_facebookAlbumID);
	_facebookAlbumID = [albumID retain];
	
	[self _loadProcessedImageDataForURL: _latestProcessedImageURL forDestination: @"facebook"];
}

#pragma mark -
#pragma mark Instagraming

- (void) instagramPhoto: (id) sender
{
	if(_latestProcessedImageURL)
	{
		[self _loadProcessedImageDataForURL: _latestProcessedImageURL forDestination: @"instagram"];
    }
    
}


#pragma mark -
#pragma mark Emailing

- (void) emailPhoto: (id) sender
{
	if(_latestProcessedImageURL)
	{
		[self _loadProcessedImageDataForURL: _latestProcessedImageURL forDestination: @"email"];
    }
}

- (void) mailComposeController: (MFMailComposeViewController*) controller didFinishWithResult: (MFMailComposeResult) result error: (NSError*) error 
{
    [self dismissViewControllerAnimated:YES completion:^{
        if(result == MFMailComposeResultSent)
        {
            [self presentGrowlNotification: @"Emailing your photo"];
        }
    }];
}

- (void) presentGrowlNotification: (NSString*) message
{
	CGRect					notificationFrame = CGRectMake(0, 0, 280, 60);
	BananaCameraGrowlView*	view = [[BananaCameraGrowlView alloc] initWithFrame: notificationFrame];
	[view beginNotificationInViewController: self withNotification: message];
}


- (void) _loadProcessedImageDataForURL: (NSURL*) url forDestination: (NSString*) destination
{
	if(NSStringFromClass([ALAssetsLibrary class]) && url)
	{
		ALAssetsLibrary*	library = [[ALAssetsLibrary alloc] init];
		
		[library assetForURL: url 
				 resultBlock:^(ALAsset *asset) {
					 ALAssetRepresentation*	rep = [asset defaultRepresentation];
					 long long				size = [rep size];
					 uint8_t*				buffer = (uint8_t*)malloc(size);
					 
					 if(buffer)
					 {
						 NSError*	error = nil;
						 NSUInteger numBytes = 0;
						 numBytes = [rep getBytes: buffer fromOffset: 0 length: size error: &error];
						 
						 if(numBytes > 0 && !error)
						 {
							 NSData*	data = [[NSData alloc] initWithBytesNoCopy: buffer length: size];
							 
							 if([destination isEqualToString: @"email"])
							 {
								 [[self dd_invokeOnMainThread] _emailPhoto: data ofType: [rep UTI]];
							 }
							 else if([destination isEqualToString: @"facebook"])
							 {
								 [[self dd_invokeOnMainThread] _facebookPhoto: data ofType: [rep UTI]];
							 }
							 else if([destination isEqualToString: @"instagram"])
							 {
								 [[self dd_invokeOnMainThread] _instagramPhoto: data ofType: [rep UTI]];
							 }
							 else
							 {
								 NSLog(@"Unknown destination for processed image");
							 }
							 
						 }
						 else if(error) 
						 {
							 NSLog(@"ALAssetRepresentation -getBytes::: failed - %@", [error description]);
							 free(buffer);
						 }
					 }
					 
				 }
				failureBlock:^(NSError *error) {
					NSLog(@"_loadProcessedImageDataForURL failed - %@", [error description]);
				}];
		
		[library release];
	}
	else if(url && [url isFileURL])
	{
		NSError*	error = nil;
		NSData*		data = [[NSData alloc] initWithContentsOfURL: url options: NSDataReadingMapped error: &error];
		NSString*	path = [[url path] lowercaseString];
		NSString*	uti = nil;
		
		if([[path pathExtension] isEqualToString: @"png"])
		{
			uti = @"public.png";
		}
		else if([[path pathExtension] isEqualToString: @"jpg"] || [[path pathExtension] isEqualToString: @"jpeg"])
		{
			uti = @"public.jpeg";
		}
		
		if(data && !error)
		{
			if([destination isEqualToString: @"email"])
			{
				[self _emailPhoto: data ofType: uti];
			}
			else if([destination isEqualToString: @"facebook"])
			{
				[self _facebookPhoto: data ofType: uti];
			}
			else 
			{
				NSLog(@"Unknown destination for processed image");
			}
		}
		else if(error)
		{
			NSLog(@"Unable to load processed image: %@", [error description]);
		}
	}
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
        NSLog(@"Could not create file in directory %@", directory);
        return nil;
    }

    NSString* result = [NSString stringWithCString: filename encoding: NSASCIIStringEncoding];
    result = [result stringByAppendingPathExtension: ext];
    return result;
}

- (void) _instagramPhoto: (NSData*) photoData  ofType: (NSString*) uti
{
    NSArray*    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString*   documentsDirectory = [paths objectAtIndex: 0];
    
    NSString*   photoPath = [self _createTempFileNameInDirectory: documentsDirectory extension: @"ig"];
    if(photoPath)
    {
        NSLog(@"%@", photoPath);
        [photoData writeToFile: photoPath atomically: NO];
        
        UIDocumentInteractionController*    ic = [UIDocumentInteractionController interactionControllerWithURL: [NSURL fileURLWithPath: photoPath]];
        if(ic)
        {
            ic.delegate = self;
            ic.UTI = @"com.instagram.exclusivegram";
            [ic presentOpenInMenuFromBarButtonItem: [self _actionBarButtonItem] animated: YES];
        }
    }
}

- (void) _facebookPhoto: (NSData*) photoData  ofType: (NSString*) uti
{
	if(_facebookAlbumID && photoData)
	{
		UIImage*				imageRep = [[UIImage alloc] initWithData: photoData];
		NSString*				photoName = [self defaultPhotoName];
		NSMutableDictionary*	params = [NSMutableDictionary dictionaryWithObjectsAndKeys: imageRep, @"data", photoName, @"message", nil];

		[[ApplicationDelegate() facebookSession] requestWithGraphPath: [NSString stringWithFormat: @"%@/photos", _facebookAlbumID]
															andParams: params
														andHttpMethod: @"POST"
														  andDelegate: self];

		[imageRep release];
		[photoData release];
	}
}

- (void) _emailPhoto: (NSData*) photoData ofType: (NSString*) uti;
{
	if(photoData)
	{
        MFMailComposeViewController* picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        
        [picker setSubject: @""];
        [picker addAttachmentData: photoData 
						 mimeType: [self _mimeTypeForUTI: uti] 
						 fileName: [NSString stringWithFormat: @"%@ Photo", ApplicationDelegate().applicationName]];
        
        // Fill out the email body text
		NSString* emailBody = [NSString stringWithFormat: @"Taken with <a href=\"%@\"><em>%@</em></a>", ApplicationDelegate().applicationURL, ApplicationDelegate().applicationName];
        [picker setMessageBody: emailBody isHTML: YES];
        
        [self presentViewController:picker animated:YES completion:nil];
        [picker release];
		
		[photoData release];
    }
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
		//NSLog(@"Did write original image to photo library - %@", [imagePath absoluteString]);
	}
	else if(error)
	{
		NSLog(@"Error writing original image written to photo library - %@", [error description]);
	}
}

- (void) imageProcessorWroteProcessedImageToLibrary: (NSNotification*) notification
{
	ReleaseAndClear(_latestProcessedImageURL);
	
	NSDictionary*	userInfo = [notification userInfo];
	NSURL*			imagePath = nil;
	NSError*		error = nil;
	
	imagePath = (NSURL*)[userInfo objectForKey: @"url"];
	error = (NSError*)[userInfo objectForKey: @"error"];
	
	if(imagePath)
	{
		//NSLog(@"Did write processed image to photo library - %@", [imagePath absoluteString]);
		
		_latestProcessedImageURL = [imagePath retain];
		[self _actionBarButtonItem].enabled = YES;
	}
	else if(error)
	{
		NSLog(@"Error writing processed image written to photo library - %@", [error description]);
	}
	
	[self enableToolbarItems: kAllItems];
}

- (IBAction) resetFacebook: (id) sender
{
	Facebook*	fbSession = [ApplicationDelegate() facebookSession];
	[fbSession logout: self];
}

@end

void BananaCameraAudioSessionInterruptionListener(BananaCameraViewController* viewController, UInt32 inInterruptionState)
{
	// no-op
}

