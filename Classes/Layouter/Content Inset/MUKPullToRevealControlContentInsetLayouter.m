//
//  MUKPullToRevealControlContentInsetLayouter.m
//  
//
//  Created by Marco Muccinelli on 02/08/2019.
//

#import "MUKPullToRevealControlContentInsetLayouter.h"

@interface MUKPullToRevealControlContentInsetLayouter ()
@property (nonatomic, readwrite) BOOL isUpdatingContentInset;
@end

@implementation MUKPullToRevealControlContentInsetLayouter
@dynamic ignoresOriginal;
@dynamic originalTop;
@dynamic revealed, covered;

- (instancetype)initWithScrollView:(UIScrollView *)scrollView control:(MUKPullToRevealControl *)control
{
    self = [super init];
    if (self) {
        _scrollView = scrollView;
        _control = control;
        _first = scrollView.contentInset;
        _original = _first;
    }
    
    return self;
}

#pragma mark - Accessors

- (BOOL)ignoresOriginal {
    if (@available(iOS 11, *)) {
        return YES;
    }
    else {
        return NO;
    }
}

- (CGFloat)originalTopInset {
    return self.original.top;
}

- (void)setOriginalTop:(CGFloat)originalTopInset {
    self.original = ({
        UIEdgeInsets inset = self.original;
        inset.top = originalTopInset;
        inset;
    });
    
    if (!self.ignoresOriginal) {
        if (self.revealStateAffectsContentInset) {
            [self updateContentInsetForContentOffsetChangeInScrollView:self.scrollView];
        }
        else if (![self contentInsetRespectsCoveredRevealState]) {
            // Useful when reveal/cover is performed out of screen (e.g.: in a previous
            // view controller on a navigation stack). This check ensures top inset
            // is respected also in covered state.
            UIEdgeInsets inset = self.scrollView.contentInset;
            inset.top = originalTopInset;
            [self updateContentInset:inset];
        }
    }
}

- (UIEdgeInsets)revealed {
    UIEdgeInsets inset;
    
    if (@available(iOS 11, *)) {
        inset = self.scrollView.safeAreaInsets;
        inset.top = self.control.revealHeight;
    }
    else {
        inset = self.original;
        inset.top += self.control.revealHeight;
    }
    
    return inset;
}

- (UIEdgeInsets)covered {
    UIEdgeInsets inset;
    
    if (@available(iOS 11, *)) {
        inset = self.scrollView.safeAreaInsets;
        inset.top = 0.0f;
    }
    else {
        inset = self.original;
    }
    
    return inset;
}

- (BOOL)revealStateAffectsContentInset {
    return self.control.revealState == MUKPullToRevealControlStateRevealed;
}

#pragma mark - Methods

- (void)start {
    
}

- (void)stop {
    if (!self.ignoresOriginal) {
        [self updateContentInset:self.original];
    }
}

- (void)updateContentInset:(UIEdgeInsets)contentInset {
    if (!UIEdgeInsetsEqualToEdgeInsets(self.scrollView.contentInset, contentInset)) {
        self.isUpdatingContentInset = YES;
        self.scrollView.contentInset = contentInset;
        self.isUpdatingContentInset = NO;
    }
}

- (void)updateContentInsetForContentOffsetChange {
    if (!self.isUpdatingContentInset) {
        UIEdgeInsets inset = self.scrollView.contentInset;
        inset.top = ({
            CGFloat top;
            CGFloat const topThreshold = self.referenceInsets.top;

            if (-self.scrollView.contentOffset.y > topThreshold) {
                // Top inset shrinks in order to follow scroll
                CGFloat offset;
                if (@available(iOS 11, *)) {
                    offset = -topThreshold;
                }
                else {
                    offset = 0.0f;
                }
                
                top = -self.scrollView.contentOffset.y + offset;
            }
            else if (@available(iOS 11, *)) {
                // Top inset no more shrinking to follow scroll
                top = 0.0f;
            }
            else {
                // Top inset no more shrinking to follow scroll
                top = self.original.top;
            }
            
            // Cap top inset
            CGFloat extensionCap;
            if (@available(iOS 11, *)) {
                extensionCap = self.control.revealHeight;
            }
            else {
                extensionCap = self.control.revealHeight + self.original.top;
            }
            
            if (top > extensionCap) {
                top = extensionCap;
            }
            
            top;
        });
        
        [self updateContentInset:inset];
    }
}

#pragma mark - Private

- (BOOL)contentInsetRespectsCoveredRevealState {
    return self.control.revealState == MUKPullToRevealControlStateCovered && self.scrollView.contentInset.top == self.original.top;
}

- (UIEdgeInsets)referenceInsets {
    if (@available(iOS 11, *)) {
        return self.scrollView.safeAreaInsets;
    }
    else {
        return self.original;
    }
}

@end
