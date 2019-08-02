//
//  MUKPullToRevealControlCoverTransition.m
//  
//
//  Created by Marco Muccinelli on 02/08/2019.
//

#import "MUKPullToRevealControlCoverTransition.h"

@implementation MUKPullToRevealControlCoverTransition

+ (BOOL)isValidFromState:(MUKPullToRevealControlState)state {
    return state == MUKPullToRevealControlStateRevealed;
}

- (void)start {
    UIScrollView *const scrollView = self.scrollView;
    UIEdgeInsets const newInset = [self coveredInsetsOfScrollView:scrollView];

    self.revealState = MUKPullToRevealControlStateCovered;
    [UIView animateWithDuration:animated ? 0.4 : 0.0 animations:^{
        [self setContentInset:newInset toScrollView:scrollView];
        [self updateFrameInScrollView:scrollView];
        [self updateContentViewFrameInScrollView:scrollView];
    }];
    
    CGFloat const yOffsetAfterRunningScroll = scrollView.contentOffset.y + self.runningScroll.contentOffset.y;
    
    CGFloat scrollThreshold;
    if (@available(iOS 11, *)) {
        scrollThreshold = -scrollView.safeAreaInsets.top;
    }
    else {
        scrollThreshold = -scrollView.contentInset.top;
    }
    
    BOOL const shouldScroll = yOffsetAfterRunningScroll < scrollThreshold;
    if (shouldScroll) {
        CGPoint contentOffset = scrollView.contentOffset;
        contentOffset.y = -newInset.top;
        
        if (@available(iOS 11, *)) {
            contentOffset.y -= scrollView.safeAreaInsets.top;
        }

        MUKPullToRevealControlScroll *const scroll = [[MUKPullToRevealControlScroll alloc] initWithName:@"cover" contentOffset:contentOffset animated:animated loggingEnabled:DEBUG_LOG_SCROLLS completionHandler:nil];
        
        if (self.userIsTouchingScrollView) {
            // Postpone
            __weak typeof(self) weakSelf = self;
            __weak __typeof__(scrollView) weakScrollView = scrollView;

            [self addJobAfterUserTouch:^{
                __strong __typeof(weakSelf) strongSelf = weakSelf;
                __strong __typeof__(weakScrollView) strongScrollView = weakScrollView;

                if (strongSelf.revealState == MUKPullToRevealControlStateCovered)
                {
                    [strongSelf performScroll:scroll onScrollView:strongScrollView];
                }
            }];
        }
        else {
            [self performScroll:scroll onScrollView:scrollView];
        }
    } // if shouldScroll
}

@end
