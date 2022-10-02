//
//  BananaCameraAppDelegate.m
//
//  Copyright 2020 Zinc Collective, LLC. All rights reserved.
//

#import "BananaCameraAppDelegate.h"
#import "BananaCameraViewController.h"
#import "BananaCameraConstants.h"
#import "BananaCameraUtilities.h"
#import <CoreLocation/CoreLocation.h>
#import <MessageUI/MessageUI.h>
#include <sys/types.h>
#include <sys/sysctl.h>

@interface BananaCameraAppDelegate(Private)
- (void) _addImagePath: (NSString*) path imageFlags: (BOOL) flags;
@end

@implementation BananaCameraAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize locationManager = _locationManager;
@synthesize backgroundTasksSupported = _backgroundTasksSupported;
@synthesize inBackground = _inBackground;
@synthesize flashMode = _flashMode;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL) application: (UIApplication*) application didFinishLaunchingWithOptions: (NSDictionary*) launchOptions
{
    // Check for background task support
	
	UIDevice* device = [UIDevice currentDevice];
	if([device respondsToSelector: @selector(isMultitaskingSupported)])
	{
		_backgroundTasksSupported = device.multitaskingSupported;
	}
	
    self.flashMode = UIImagePickerControllerCameraFlashModeOff;
    

	// Hide the status bar
	
    [application setStatusBarHidden: YES];
    [application setStatusBarStyle:UIStatusBarStyleDefault];

    
	// Create the window and views
	
    [_window setBackgroundColor:kBackgroundColor];
    [_window setRootViewController:_viewController];
    [_window makeKeyAndVisible];

	
	
	// Turn off locations
	if([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera] == YES)
	{
		self.locationManager = [[CLLocationManager alloc] init];
		[self.locationManager startUpdatingLocation];
	}
	
    return YES;
}


- (void) applicationWillResignActive: (UIApplication*) application 
{
    [self.viewController applicationWillResignActive];
}

- (void) applicationDidEnterBackground: (UIApplication*) application
{
	_inBackground = YES;
	[self.viewController applicationDidEnterBackground];
}

- (void) applicationWillEnterForeground: (UIApplication*) application
{
	//_inBackground = NO;
	//[self.viewController applicationWillEnterForeground];
    
    
}

- (void) applicationDidBecomeActive: (UIApplication*) application
{
    _inBackground = NO;
    [self.viewController applicationWillEnterForeground];
   
    
}

- (void) applicationWillTerminate: (UIApplication*) application
{
}


#pragma mark -
#pragma mark Memory management

- (void) applicationDidReceiveMemoryWarning: (UIApplication*) application
{
}


- (NSString*) platform
{
	size_t	size;
	sysctlbyname("hw.machine", NULL, &size, NULL, 0);
	
	char*	machine = (char*)malloc(size);
	sysctlbyname("hw.machine", machine, &size, NULL, 0);
	
	NSString* platform = [NSString stringWithCString: machine encoding: NSASCIIStringEncoding];
	free(machine);
	
	return platform;
}

- (NSString*) createGUID
{
	CFUUIDRef	guid = CFUUIDCreate(NULL);
	CFStringRef guidString = CFUUIDCreateString(NULL, guid);
	
	CFRelease(guid);
	
	return (__bridge NSString*)guidString;
}

- (NSString*) createUniqueImagePath
{
	NSString*		guid = [self createGUID];
	NSString*		fileName = [NSString stringWithFormat: @"%@_%@.jpg", [self applicationName], guid];
	NSString*		imagePath = [NSTemporaryDirectory() stringByAppendingPathComponent: fileName];
	
	return imagePath;
}

#pragma mark -
#pragma mark Image Processing

- (void) addImageToProcess: (UIImage*) image imageFlags: (BOOL) flags
{
	// Make sure we hold onto the image until everything is done.
	
	UIImage*		originalImage = image;
	NSString*		imagePath     = [self createUniqueImagePath];
	
	if(self.backgroundTasksSupported)
	{
		__block UIBackgroundTaskIdentifier	bkgndTaskIdent = UIBackgroundTaskInvalid;
		UIApplication*						app = [UIApplication sharedApplication];
		
		bkgndTaskIdent = [app beginBackgroundTaskWithExpirationHandler:^{
			dispatch_async(dispatch_get_main_queue(), ^{
				if(bkgndTaskIdent != UIBackgroundTaskInvalid)
				{
					[[UIApplication sharedApplication] endBackgroundTask: bkgndTaskIdent];
					bkgndTaskIdent = UIBackgroundTaskInvalid;
				}
			});
		}];
		
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			
			// Write the image to be processed to temporary storage
			
			NSData*	jpegRep = UIImageJPEGRepresentation(originalImage, 1.0);
			if(jpegRep)
			{
				[jpegRep writeToFile: imagePath atomically: NO];
				[self _addImagePath: imagePath imageFlags: flags];
			}
			else 
			{
				NSLog(@"Unable to get JPEG representation from original image. Could be low memory issue");
			}
			
		});		
	}
	else
	{
		// < 4.0 support
		NSData*	jpegRep = UIImageJPEGRepresentation(originalImage, 1.0);
		if(jpegRep)
		{
			[jpegRep writeToFile: imagePath atomically: NO];
			[self _addImagePath: imagePath imageFlags: flags];
		}
		
	}
}

- (void) _addImagePath: (NSString*) path imageFlags: (BOOL) flags
{
	@synchronized(_imagesToProcess)
	{
		[_imagesToProcess addObject: path];
		
		@synchronized(_imagesToProcessFlags)
		{
			[_imagesToProcessFlags addObject: [NSNumber numberWithBool: flags]];
		}		
	}
}

- (NSString*) nextImageToProcess: (BOOL*) outFlags
{
	NSString*	result = nil;
	
	if([self imagesToProcess] > 0)
	{
		@synchronized(_imagesToProcess)
		{
			result = [_imagesToProcess objectAtIndex: 0];
			[_imagesToProcess removeObjectAtIndex: 0];
			
			@synchronized(_imagesToProcessFlags)
			{
				NSNumber*	flags = [_imagesToProcessFlags objectAtIndex: 0];
				[_imagesToProcessFlags removeObjectAtIndex: 0];
				
				if(outFlags)
				{
					*outFlags = [flags boolValue];
				}
                
			}
		}
	}
	
    return result;
}

- (NSUInteger) imagesToProcess
{
	NSUInteger	number = [_imagesToProcess count];
	//NSLog(@"imagesToProcess - %d", number);
	return number;
}


#pragma mark -


- (NSString*) applicationName
{
	return @"";
}

- (NSString*) applicationURL
{
	return @"";
}

@end
