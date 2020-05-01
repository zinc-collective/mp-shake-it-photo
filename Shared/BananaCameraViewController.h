//
//  BananaCameraViewController.h
//
//  Copyright 2020 Zinc Collective, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@class BananaCameraSoundEffect;

enum ToolbarItems 
{
	kCapturePhotoItem = (1 << 0),
	kPickPhotoItem = (1 << 1),
	kSettingsItem = (1 << 2),
	kActionItem = (1 << 3),
	kAllItems = (kCapturePhotoItem | kPickPhotoItem | kSettingsItem | kActionItem)
};

@interface BananaCameraViewController : UIViewController<UINavigationControllerDelegate, 
														 UIImagePickerControllerDelegate,
                                                         UIDocumentInteractionControllerDelegate,
													     UIWebViewDelegate,
														 UIActionSheetDelegate,
														 MFMailComposeViewControllerDelegate>

{
	@private
    BOOL						_welcomeMode;
	BananaCameraSoundEffect*	_soundEffect;
    UIToolbar*					_toolbar;	
	UIView*						_welcomeView;

	NSURL*						_latestProcessedImageURL;
}

@property (nonatomic,assign) CGRect croprect;


@property(nonatomic, strong) IBOutlet UIView*		welcomeView;
@property(nonatomic,strong) IBOutlet UIToolbar*     toolbar;
@property(nonatomic,strong) UINavigationController *settingsNavigationController;

@property (nonatomic,strong) UIDocumentInteractionController *doc;

- (void) setBackgroundImage;
- (void) clearBackgroundImage;
- (void) setToolbarItems;

- (void) disableToolbarItems: (uint) itemsToDisable;
- (void) enableToolbarItems: (uint) itemsToEnable;

- (IBAction) capturePhoto: (id) sender;
- (IBAction) choosePhoto: (id) sender;
- (IBAction) performAction: (id) sender;
- (IBAction) chooseOptions: (id) sender;

- (void) showWelcomeView;
- (void) disposeOfWelcomeView;
- (IBAction) acknowledgeWelcome: (id) sender;
- (IBAction)introVideo:(id)sender;

- (void) playSoundEffect: (NSString*) soundFile;

- (IBAction) saveOriginal: (id) sender;

- (void) applicationWillResignActive;
- (void) applicationWillEnterForeground;
- (void) applicationDidEnterBackground;

- (void) imageProcessorWroteOriginalImageToLibrary: (NSNotification*) notification;
- (void) imageProcessorWroteProcessedImageToLibrary: (NSNotification*) notification;

- (NSString*) defaultPhotoName;

@end