//
//  BananaCameraConstants.h
//
//  Copyright Banana Camera Company 2010. All rights reserved.
//

// Defines

#define	kRetinaDisplayWidth		640
#define	kRetinaDisplayHeight	960
#define	kNormalDisplayWidth		320
#define	kNormalDisplayHeight	480

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

 
// Platforms

extern NSString* const      kPlatformIPhone2G;
extern NSString* const      kPlatformIPhone3G;
extern NSString* const      kPlatformIPhone3GS;
extern NSString* const      kPlatformIPhone4;
extern NSString* const      kPlatformIPodTouch1G;
extern NSString* const      kPlatformIPodTouch2G;
extern NSString* const      kPlatformIPodTouch3G;
extern NSString* const      kPlatformIPad;

// Keys

extern NSString* const      kBananaCameraFirstLaunchKey;
extern NSString* const		kBananaCameraSaveOriginalKey;


// Defaults


// Notifications

// @"error" => NSError
// @"url" => NSURL

extern NSString* const	kDidWriteOriginalImageToPhotoLibraryNotification;
extern NSString* const	kDidWriteProcessedImageToPhotoLibraryNotification;

// Misc

// URLs

extern NSString* const		kBananaCameraMoreAppsURL;
extern NSString* const		kBananaCameraSocialURL;
extern NSString* const		kBananaCameraCompanyURL;
extern NSString* const      kBananaCameraIntroVideoURL;

