//
//  InstagramActivity.m
//  BananaCamera
//
//  Created by Isaac Ruiz on 2/12/15.
//
//

#import "InstagramActivity.h"
#import "BananaCameraConstants.h"

@implementation InstagramActivity

+(UIActivityCategory)activityCategory {
    return UIActivityCategoryShare;
}

- (NSString *)activityType
{
    return @"bananacamera.instagram";
}

- (NSString *)activityTitle
{
    return @"Open in Instagram";
}

- (UIImage *)activityImage
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        return [UIImage imageNamed:@"Instagram8"];
    } else {
        return [UIImage imageNamed:@"Instagram7"];
    }
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    NSLog(@"%s %@",__FUNCTION__,activityItems);
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    NSLog(@"%s %@",__FUNCTION__,activityItems);
}

- (UIViewController *)activityViewController
{
    NSLog(@"%s",__FUNCTION__);
    return nil;
}

- (void)performActivity
{
    if(_activity != nil) {
        _activity();
    }
    [self activityDidFinish:YES];
}

@end
