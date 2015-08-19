//
//  WebViewController.h
//  PullToRefresh
//
//  Created by Marco on 18/08/15.
//  Copyright (c) 2015 MeLive. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <UIWebViewDelegate>
@property (nonatomic, weak) IBOutlet UIWebView *webView;
@end
