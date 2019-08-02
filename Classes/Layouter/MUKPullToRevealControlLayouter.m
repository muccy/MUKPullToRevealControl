//
//  MUKPullToRefreshControlLayouter.m
//  
//
//  Created by Marco Muccinelli on 02/08/2019.
//

#import "MUKPullToRevealControlLayouter.h"
#import "MUKPullToRevealControlScrollViewObserver.h"

@interface MUKPullToRevealControlLayouter () <MUKPullToRevealControlScrollViewObserverDelegate>
@property (nonatomic, readonly, nonnull) MUKPullToRevealControlScrollViewObserver *observer;
@end

@implementation MUKPullToRevealControlLayouter

- (void)dealloc {
    [self stop];
}

- (instancetype)initWithScrollView:(UIScrollView *)scrollView control:(MUKPullToRevealControl *)control
{
    self = [super init];
    if (self) {
        _scrollView = scrollView;
        _control = control;
        _insetLayouter = [[MUKPullToRevealControlContentInsetLayouter alloc] initWithScrollView:scrollView control:control];
        _frameLayouter = [[MUKPullToRevealControlFrameLayouter alloc] initWithScrollView:scrollView control:control];
        _touchesTracker = [[MUKPullToRevealControlTouchesTracker alloc] initWithScrollView:scrollView];
        _observer = [[MUKPullToRevealControlScrollViewObserver alloc] initWithScrollView:scrollView];
    }
    
    return self;
}

#pragma mark - Accessors



#pragma mark - Methods

- (void)start {
    [self.frameLayouter start];
    self.control.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    self.touchesTracker.delegate = self;
    [self.touchesTracker start];
    
    [self.insetLayouter start];
    
    self.observer.delegate = self;
    [self.observer start];
}

- (void)stop {
    [self.insetLayouter stop];
    [self.frameLayouter stop];
    
    [self.touchesTracker stop];
    self.touchesTracker.delegate = nil;
    
    [self.observer stop];
    self.observer.delegate = nil;
}

#pragma mark - Private

- (CGFloat)scrollViewPulledHeight {
    CGFloat pulledHeight = -self.scrollView.contentOffset.y;
    
    if (@available(iOS 11, *)) {
        pulledHeight -= self.scrollView.adjustedContentInset.top;
    }
    else {
        pulledHeight -= self.scrollView.contentInset.top;
    }
    
    return pulledHeight;
}

- (void)notifyPulledHeightDidChangeInCaseOfUserInteraction {
    if (self.scrollView.isTracking || self.scrollView.isDragging || self.scrollView.isDecelerating)
    {
        CGFloat const pulledHeight = self.scrollViewPulledHeight;
        [self.delegate layouter:self didChangePulledHeight:pulledHeight];
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

#pragma mark - <MUKPullToRevealControlFrameLayouterDelegate>

- (CGFloat)scrollViewPulledHeightForFrameLayouter:(MUKPullToRevealControlFrameLayouter *)layouter
{
    return self.scrollViewPulledHeight;
}

#pragma mark - <MUKPullToRevealControlScrollViewObserverDelegate>

- (void)scrollViewObserver:(MUKPullToRevealControlScrollViewObserver *)observer didObserveNewContentOffset:(CGPoint)newOffset
{
    // Resize
    [self.frameLayouter updateFrame];
    [self.frameLayouter updateContentViewFrame];
    
    // Update user is touching
    [self.touchesTracker update];
    
    // TODO: Manage manual scrolling completion
    if (strongSelf.runningScroll) {
        if (CGPointEqualToPoint(strongSelf.runningScroll.contentOffset, newOffset))
        {
            [strongSelf didCompleteScroll:strongSelf.runningScroll finished:YES];
        }
    }
    
    if (self.insetLayouter.revealStateAffectsContentInset) {
        // This helps to place table sections headers better
        [self.insetLayouter updateContentInsetForContentOffsetChange];
    }
    else {
        // Keep track
        self.insetLayouter.original = self.scrollView.contentInset;
    }
    
    [self notifyPulledHeightDidChangeInCaseOfUserInteraction];
}

- (void)scrollViewObserver:(MUKPullToRevealControlScrollViewObserver *)observer didObserveNewContentInset:(UIEdgeInsets)newInset
{
    if (!self.insetLayouter.revealStateAffectsContentInset) {
        // Keep track when not affected by reveal state
        self.insetLayouter.original = newInset;
    }
    
    [self.frameLayouter updateFrame];
    [self.frameLayouter updateContentViewFrame];
}

@end
