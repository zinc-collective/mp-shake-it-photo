//
//  BananaCameraAppDelegate.h
//
//  Copyright 2020 Zinc Collective, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kBackgroundColor [UIColor colorWithRed:(24.0/255.0) green:(22.0/255.0) blue:(31.0/255.0) alpha:1.0]

@class BananaCameraViewController;
@class CLLocationManager;

@interface BananaCameraAppDelegate : NSObject <UIApplicationDelegate>
{
	@private
    UIWindow*					_window;
    BananaCameraViewController*	_viewController;
	CLLocationManager*			_locationManager;
	BOOL						_backgroundTasksSupported;
	BOOL						_inBackground;
	NSMutableArray*				_imagesToProcess;
	NSMutableArray*				_imagesToProcessFlags;
    
    UIImagePickerControllerCameraFlashMode  _flashMode;
}

@property (nonatomic, strong) IBOutlet UIWindow*	window;
@property (nonatomic, strong) IBOutlet BananaCameraViewController*	viewController;
@property (nonatomic, readonly) BOOL backgroundTasksSupported;
@property (nonatomic, readonly) BOOL inBackground;
@property (nonatomic, strong) IBOutlet CLLocationManager* locationManager;

@property(nonatomic, assign) UIImagePickerControllerCameraFlashMode flashMode;


- (NSString*) platform;
- (NSString*) createGUID;
- (NSString*) createUniqueImagePath;

- (NSString*) applicationName;
- (NSString*) applicationURL;

- (void) addImageToProcess: (UIImage*) image imageFlags: (BOOL) flags;
- (NSUInteger) imagesToProcess;
- (NSString*) nextImageToProcess: (BOOL*) outFlags;

@end

