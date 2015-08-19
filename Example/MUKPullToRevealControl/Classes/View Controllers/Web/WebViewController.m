//
//  WebViewController.m
//  PullToRefresh
//
//  Created by Marco on 18/08/15.
//  Copyright (c) 2015 MeLive. All rights reserved.
//

#import "WebViewController.h"
#import "MUKCirclePullToRefreshControl.h"

@interface WebViewController ()
@property (nonatomic, weak) MUKPullToRevealControl *pullToRevealControl;
@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    MUKPullToRevealControl *const pullToRevealControl = [[MUKCirclePullToRefreshControl alloc] init];
    [pullToRevealControl addTarget:self action:@selector(pullToRevealControlTriggered:) forControlEvents:UIControlEventValueChanged];
    [self.webView.scrollView addSubview:pullToRevealControl];
    self.pullToRevealControl = pullToRevealControl;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.webView.request) {
        NSURL *const URL = [NSURL URLWithString:@"https://www.apple.com"];
        NSURLRequest *const request = [NSURLRequest requestWithURL:URL];
        [self.webView loadRequest:request];
    }
}

- (void)pullToRevealControlTriggered:(MUKPullToRevealControl *)pullToRevealControl
{
    [self.webView reload];
}

#pragma mark - <UIWebViewDelegate>

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.pullToRevealControl revealAnimated:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.pullToRevealControl coverAnimated:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self.pullToRevealControl coverAnimated:YES];
}

@end
