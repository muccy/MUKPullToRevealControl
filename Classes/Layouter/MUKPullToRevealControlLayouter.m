//
//  MUKPullToRefreshControlLayouter.m
//  
//
//  Created by Marco Muccinelli on 02/08/2019.
//

#import "MUKPullToRevealControlLayouter.h"

@interface MUKPullToRevealControlLayouter ()
@end

@implementation MUKPullToRevealControlLayouter


- (instancetype)initWithScrollView:(UIScrollView *)scrollView control:(MUKPullToRevealControl *)control
{
    self = [super init];
    if (self) {
        _scrollView = scrollView;
        _control = control;
        _insetLayouter = [[MUKPullToRevealControlContentInsetLayouter alloc] initWithScrollView:scrollView];
    }
    
    return self;
}

#pragma mark - Accessors



#pragma mark - Methods

- (void)start {
    [self updateFrameInScrollView:scrollView];
    [self updateContentViewFrameInScrollView:scrollView];
    
    self.control.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [self updateUserIsTouchingScrollView:scrollView];
    [self observeScrollViewContentInset:scrollView];
    [self observeScrollViewContentOffset:scrollView];
}

- (void)stop {
    UIScrollView *const oldScrollView = (UIScrollView *)self.superview;
    [self unobserveScrollView:oldScrollView];
    [self updateUserIsTouchingScrollView:nil];
    
    if (!self.ignoresOriginalTopInset) {
        [self setContentInset:self.originalContentInset toScrollView:oldScrollView];
    }
}

@end
