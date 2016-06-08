//
//  BananaCameraViewController.h
//
//  Copyright 2010 Banana Camera Company. All rights reserved.
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
														 UITableViewDelegate,
														 UITableViewDataSource,
													     UIWebViewDelegate,
														 UINavigationBarDelegate,
														 UIActionSheetDelegate,
														 MFMailComposeViewControllerDelegate>

{
	@private
    BOOL						_welcomeMode;
	BananaCameraSoundEffect*	_soundEffect;
    UIToolbar*					_toolbar;	
	UIView*						_welcomeView;

	UIView*						_optionsView;
	UITableView*				_optionsTableView;
	UIWebView*					_moreInfoWebView;
	UIWebView*					_socialWebView;
    UITableViewCell*			_keepOriginalCell;
    UITableViewCell*			_infoCell;
    UITableViewCell*			_communityCell;
	UINavigationBar*			_optionsNavigationBar;
	
	NSURL*						_latestProcessedImageURL;
}

@property (nonatomic,assign) CGRect croprect;
@property (nonatomic,strong) UIImagePickerController* picker;

@property(nonatomic,retain) IBOutlet UITableViewCell*    keepOriginalCell;
@property(nonatomic,retain) IBOutlet UITableViewCell*    infoCell;
@property(nonatomic,retain) IBOutlet UITableViewCell*    communityCell;
@property(nonatomic,retain) IBOutlet UINavigationBar*    optionsNavigationBar;
@property(nonatomic,retain) IBOutlet UITableView*		 optionsTableView;

@property(nonatomic, retain) IBOutlet UIView*		welcomeView;
@property(nonatomic, retain) IBOutlet UIView*		optionsView;
@property(nonatomic,retain) IBOutlet UIToolbar*     toolbar;
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
- (IBAction) community: (id) sender;
- (IBAction) moreInfo: (id) sender;
- (IBAction) handleDone: (id) sender;

- (void) instagramPhoto: (id) sender;
- (void) emailPhoto: (id) sender;

- (void) showWelcomeView;
- (void) disposeOfWelcomeView;
- (IBAction) acknowledgeWelcome: (id) sender;

- (void) playSoundEffect: (NSString*) soundFile;

- (void) setupOptions;

- (void) presentGrowlNotification: (NSString*) message;

- (IBAction) saveOriginal: (id) sender;

- (void) applicationWillResignActive;
- (void) applicationWillEnterForeground;
- (void) applicationDidEnterBackground;

- (void) imageProcessorWroteOriginalImageToLibrary: (NSNotification*) notification;
- (void) imageProcessorWroteProcessedImageToLibrary: (NSNotification*) notification;

- (NSString*) defaultPhotoName;

@end