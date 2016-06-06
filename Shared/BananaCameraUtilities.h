//
//  BananaCameraUtilities.h
//
//  Copyright 2010 Banana Camera Company. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <mach/mach_time.h>
#import "BananaCameraAppDelegate.h"

void LogTiming(NSString* message, uint64_t startTime, uint64_t endTime);

NS_INLINE uint64_t StartTiming()
{
    return mach_absolute_time();
}

NS_INLINE void EndTiming(NSString* message, uint64_t startTime)
{
    LogTiming(message, startTime, mach_absolute_time());
}

// Release an object and set it to nil

#define ReleaseAndClear( object ) { if (object != nil) { [object release]; object = nil; } }

// CFRelease an object and set it to NULL

#define CFReleaseAndClear( object ) { if (object) { CFRelease(object); object = NULL; } }

// Geometry functions

CGRect CenterRectOverRect(CGRect a, CGRect b);
CGSize FitSizeWithSize(CGSize rectToFit, CGSize rectToFitInto);
CGSize FitSizeWithSize2(CGSize sizeToFit, CGSize sizeToFitInto);
CGFloat RoundEven(CGFloat a);

// Color functions

CGColorRef CreateDeviceGrayColor(CGFloat w, CGFloat a);
CGColorRef CreateDeviceRGBColor(CGFloat r, CGFloat g, CGFloat b, CGFloat a);


///* RGBA - use this if CGImageAlphaInfo == kCGImageAlphaPremultipliedLast
#define ALPHA_COMPONENT(pixel)      (unsigned char)(*pixel >> 24)
#define BLUE_COMPONENT(pixel)       (unsigned char)(*pixel >> 16)
#define GREEN_COMPONENT(pixel)      (unsigned char)(*pixel >> 8)
#define RED_COMPONENT(pixel)        (unsigned char)(*pixel >> 0)

#define SET_ALPHA_COMPONENT(pixel, value)      *pixel = (*pixel & 0x00FFFFFF) | ((unsigned long)value << 24)
#define SET_BLUE_COMPONENT(pixel, value)       *pixel = (*pixel & 0xFF00FFFF) | ((unsigned long)value << 16)
#define SET_GREEN_COMPONENT(pixel, value)      *pixel = (*pixel & 0xFFFF00FF) | ((unsigned long)value << 8)
#define SET_RED_COMPONENT(pixel, value)        *pixel = (*pixel & 0xFFFFFF00) | ((unsigned long)value << 0)
//*/

/*// ARGB use this if CGImageAlphaInfo == kCGImageAlphaPremultipliedFirst

#define BLUE_COMPONENT(pixel)		(unsigned char)(*pixel >> 24)
#define GREEN_COMPONENT(pixel)      (unsigned char)(*pixel >> 16)
#define RED_COMPONENT(pixel)		(unsigned char)(*pixel >> 8)
#define ALPHA_COMPONENT(pixel)      (unsigned char)(*pixel >> 0)

#define SET_BLUE_COMPONENT(pixel, value)      *pixel = (*pixel & 0x00FFFFFF) | ((unsigned long)value << 24)
#define SET_GREEN_COMPONENT(pixel, value)       *pixel = (*pixel & 0xFF00FFFF) | ((unsigned long)value << 16)
#define SET_RED_COMPONENT(pixel, value)      *pixel = (*pixel & 0xFFFF00FF) | ((unsigned long)value << 8)
#define SET_ALPHA_COMPONENT(pixel, value)        *pixel = (*pixel & 0xFFFFFF00) | ((unsigned long)value << 0)
*/

//#define DEBUG_TIMING
#ifdef DEBUG_TIMING
    #define START_TIMING(name)          uint64_t eieio ## name = StartTiming();
    #define END_TIMING(name)            EndTiming(@#name, eieio ## name);
#else
    #define START_TIMING(name)
    #define END_TIMING(name)     
#endif

NS_INLINE BananaCameraAppDelegate* ApplicationDelegate()
{
    return (BananaCameraAppDelegate*) [UIApplication sharedApplication].delegate;
}

NS_INLINE BOOL IsRunningInSimulator()
{
    return [[UIDevice currentDevice].model isEqualToString: @"iPhone Simulator"];
}

