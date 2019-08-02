//
//  MUKPullToRevealControlRevealTransition.m
//  
//
//  Created by Marco Muccinelli on 02/08/2019.
//

#import "MUKPullToRevealControlRevealTransition.h"

@implementation MUKPullToRevealControlRevealTransition

+ (BOOL)isValidFromState:(MUKPullToRevealControlState)state {
    return state != MUKPullToRevealControlStateRevealed;
}

- (void)start {
    UIEdgeInsets const newInset = self.layouter.insetLayouter.revealed;

    __weak typeof(self) weakSelf = self;

    if ([self shouldScrollWithNewInset:newInset]) {
        CGPoint contentOffset = [self contentOffsetWithNewInset:newInset];
        
        MUKPullToRevealControlScroll *const scroll = [[MUKPullToRevealControlScroll alloc] initWithName:@"reveal" contentOffset:contentOffset animated:animated loggingEnabled:DEBUG_LOG_SCROLLS completionHandler:^(BOOL finished)
        {
            if (finished) {
               update();
            }
        }];
        
        [self performScroll:scroll onScrollView:scrollView];
    }
    else {
        update();
        
        if (@available(iOS 11, *)) {
            // Don't wait first user scroll in order to adjust insets
            [self updateContentInsetForContentOffsetChangeInScrollView:scrollView];
        }
    }
    
}

#pragma mark - Private

- (void)updateLayoutWithNewInset:(UIEdgeInsets)newInset {
    [self.layouter.insetLayouter updateContentInset:newInset];
    [self.layouter.frameLayouter updateFrame];
    [self.layouter.frameLayouter updateContentViewFrame];
}

- (CGRect)boundsAfterScrollWithNewInset:(UIEdgeInsets)newInset {
    CGRect rect = self.layouter.scrollView.bounds;
    rect.origin.y += self.layouter.scrollView.contentInset.top - newInset.top;
    return rect;
}

- (CGRect)potentialFrame {
    CGRect potentialFrame = self.layouter.control.frame;
    potentialFrame.size.height = self.layouter.control.revealHeight;
    return potentialFrame;
}

- (BOOL)shouldScrollWithNewInset:(UIEdgeInsets)newInset {
    CGRect const boundsAfterScroll = [self boundsAfterScrollWithNewInset:newInset];
    CGRect potentialFrame = self.potentialFrame;
    return CGRectIntersectsRect(potentialFrame, boundsAfterScroll);
}

- (CGPoint)contentOffsetWithNewInset:(UIEdgeInsets)newInset {
    UIScrollView *const scrollView = self.layouter.scrollView;
    CGPoint contentOffset = scrollView.contentOffset;
    
    if (@available(iOS 11, *)) {
        contentOffset.y = -newInset.top - scrollView.safeAreaInsets.top;
    }
    else {
        contentOffset.y = -newInset.top;
    }
    
    return contentOffset;
}

@end
