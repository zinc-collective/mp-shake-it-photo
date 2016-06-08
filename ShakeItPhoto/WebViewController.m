//
//  WebViewController.m
//  BananaCamera
//
//  Created by Isaac Ruiz on 9/28/14.
//
//

#import "WebViewController.h"

@interface WebViewController () <UIWebViewDelegate>

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIWebView *webview = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
    webview.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    webview.delegate = self;
    [self.view addSubview:webview];
    
    [webview loadRequest:[NSURLRequest requestWithURL:self.url]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    NSLog(@"request %@ %li",request.URL.absoluteString,(long)navigationType);
    if ([request.URL.scheme isEqualToString:@"itms-apps"]) {
        //[[UIApplication sharedApplication] canOpenURL:myAppURL]) {
        //[[UIApplication sharedApplication] openURL:myAppURL];
        NSLog(@"blocking redirect");
        return NO;
    }
   NSString *requestedURL = [[request URL] absoluteString];
    if([requestedURL rangeOfString:@"itms"].location==0) {
        return NO;
    }
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
