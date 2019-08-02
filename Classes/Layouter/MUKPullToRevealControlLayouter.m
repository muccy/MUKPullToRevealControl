//
//  MUKPullToRefreshControlLayouter.m
//  
//
//  Created by Marco Muccinelli on 02/08/2019.
//

#import "MUKPullToRevealControlLayouter.h"

@implementation MUKPullToRevealControlLayouter

- (instancetype)initWithScrollView:(UIScrollView *)scrollView control:(MUKPullToRevealControl *)control
{
    self = [super init];
    if (self) {
        _scrollView = scrollView;
        _control = control;
        _originalContentInset = scrollView.contentInset;
    }
    
    return self;
}

- (void)start {
    [self updateFrameInScrollView:scrollView];
    [self updateContentViewFrameInScrollView:scrollView];
    
    self.control.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [self updateUserIsTouchingScrollView:scrollView];
    [self observeScrollViewContentInset:scrollView];
    [self observeScrollViewContentOffset:scrollView];
}

- (void)stop {
    
}

@end
