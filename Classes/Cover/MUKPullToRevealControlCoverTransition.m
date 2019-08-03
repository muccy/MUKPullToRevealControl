//
//  MUKPullToRevealControlCoverTransition.m
//  
//
//  Created by Marco Muccinelli on 02/08/2019.
//

#import "MUKPullToRevealControlCoverTransition.h"

@implementation MUKPullToRevealControlCoverTransition

- (instancetype)initWithLayouter:(MUKPullToRevealControlLayouter *)layouter control:(MUKPullToRevealControl *)control animated:(BOOL)animated
{
    self = [super init];
    if (self) {
        _layouter = layouter;
        _control = control;
        _animated = animated;
    }
    
    return self;
}

#pragma mark - Methods

- (BOOL)canStart {
    return self.control.revealState == MUKPullToRevealControlStateRevealed;
}

- (void)start {
    UIEdgeInsets const newInset = self.layouter.insetLayouter.covered;
    
    [self.delegate coverTransitionIsReadyToChangeControlState:self];

    [UIView animateWithDuration:self.animated ? 0.4 : 0.0 animations:^{
        [self updateLayoutWithNewInset:newInset];
    }];
    
    if (self.shouldScroll) {
        CGPoint contentOffset = [self contentOffsetWithNewInset:newInset];

        MUKPullToRevealControlScroll *const scroll = [[MUKPullToRevealControlScroll alloc] initWithName:@"cover" contentOffset:contentOffset animated:self.animated completionHandler:nil];
        
        if (self.shouldPostponeScroll) {
            // Postpone
            __weak typeof(self) weakSelf = self;

            dispatch_block_t const job = ^{
                __strong __typeof(weakSelf) strongSelf = weakSelf;

                if (strongSelf.control.revealState == MUKPullToRevealControlStateCovered)
                {
                    [strongSelf.layouter.scrollRunner startScroll:scroll];
                }
            };
            
            [self.delegate coverTransition:self needsToPostponeAfterUserTouchJob:[job copy]];
        }
        else {
            [self.layouter.scrollRunner startScroll:scroll];
        }
    } // if shouldScroll
}

#pragma mark - Private

- (void)updateLayoutWithNewInset:(UIEdgeInsets)newInset {
    [self.layouter.insetLayouter updateContentInset:newInset];
    [self.layouter.frameLayouter updateFrame];
    [self.layouter.frameLayouter updateContentViewFrame];
}

- (CGFloat)YOffsetAfterRunningScroll {
    return self.layouter.scrollView.contentOffset.y + self.layouter.scrollRunner.currentScroll.contentOffset.y;
}

- (CGFloat)scrollThreshold {
    if (@available(iOS 11, *)) {
        return -self.layouter.scrollView.safeAreaInsets.top;
    }
    else {
        return -self.layouter.scrollView.contentInset.top;
    }
}

- (BOOL)shouldScroll {
    return self.YOffsetAfterRunningScroll < self.scrollThreshold;
}

- (CGPoint)contentOffsetWithNewInset:(UIEdgeInsets)newInset {
    CGPoint contentOffset = self.layouter.scrollView.contentOffset;
    contentOffset.y = -newInset.top;
    
    if (@available(iOS 11, *)) {
        contentOffset.y -= self.layouter.scrollView.safeAreaInsets.top;
    }
    
    return contentOffset;
}

- (BOOL)shouldPostponeScroll {
    return self.layouter.touchesTracker.userIsTouching;
}

@end
