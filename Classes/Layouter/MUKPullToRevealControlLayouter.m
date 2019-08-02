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
        _insetLayouter = [[MUKPullToRevealControlContentInsetLayouter alloc] initWithScrollView:scrollView control:control];
        _frameLayouter = [[MUKPullToRevealControlFrameLayouter alloc] initWithScrollView:scrollView control:control];
        _touchesTracker = [[MUKPullToRevealControlTouchesTracker alloc] initWithLoggingEnabled:NO];
    }
    
    return self;
}

#pragma mark - Accessors



#pragma mark - Methods

- (void)start {
    [self.insetLayouter start];
    [self.frameLayouter start];
    self.touchesTracker.delegate = self;
    
    
    
    
    [self updateFrameInScrollView:scrollView];
    [self updateContentViewFrameInScrollView:scrollView];
    
    self.control.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [self updateUserIsTouchingScrollView:scrollView];
    [self observeScrollViewContentInset:scrollView];
    [self observeScrollViewContentOffset:scrollView];
}

- (void)stop {
    [self.insetLayouter stop];
    [self.frameLayouter stop];
    self.touchesTracker.delegate = nil;
    
    
    
    
    UIScrollView *const oldScrollView = (UIScrollView *)self.superview;
    [self unobserveScrollView:oldScrollView];
    [self updateUserIsTouchingScrollView:nil];
    
    if (!self.ignoresOriginalTopInset) {
        [self setContentInset:self.originalContentInset toScrollView:oldScrollView];
    }
}

#pragma mark - <MUKPullToRevealControlTouchesTrackerDelegate>

- (void)touchesTrackerDidChangeValue:(MUKPullToRevealControlTouchesTracker *)tracker
{
    if (!tracker.userIsTouching) {
        if (self.revealState == MUKPullToRevealControlStatePulled) {
        #if DEBUG_LOG_USER_STATES
                NSLog(@"Reveal state = Revealed");
        #endif
                self.revealState = MUKPullToRevealControlStateRevealed;
                
                [UIView animateWithDuration:0.4 animations:^{
                    UIScrollView *const scrollView = self.scrollView;
                    [self updateContentInsetForContentOffsetChangeInScrollView:scrollView];
                    [self updateFrameInScrollView:scrollView];
                    [self updateContentViewFrameInScrollView:scrollView];
                }];
                
                // Trigger control state
                [self sendActionsForControlEvents:UIControlEventValueChanged];
            }
            
            // Consume job postponed after touch
            if (self.jobAfterUserTouch) {
                [self consumeJobAfterTouch];
            }
    }
}

@end
