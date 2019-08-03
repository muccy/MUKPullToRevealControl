//
//  MUKPullToRevealControlTouchesTracker.m
//  
//
//  Created by Marco Muccinelli on 02/08/2019.
//

#import "MUKPullToRevealControlTouchesTracker.h"

@implementation MUKPullToRevealControlTouchesTracker

- (instancetype)initWithScrollView:(UIScrollView *)scrollView {
    self = [super init];
    if (self) {
        _scrollView = scrollView;
    }
    
    return self;
}

#pragma mark - Accessors

- (void)setUserIsTouching:(BOOL)userIsTouching {
    if (userIsTouching != _userIsTouching) {
        _userIsTouching = userIsTouching;
            
        if (self.loggingEnabled) {
            NSLog(@"User is touching scroll view? %@", userIsTouching ? @"Y" : @"N");
        }
            
        [self.delegate touchesTrackerDidChangeValue:self];
    }
}

#pragma mark - Methods

- (void)start {
    [self update];
}

- (void)stop {
    self.userIsTouching = NO;
}

- (void)update {
    BOOL const userIsTouchingScrollView = self.scrollView.isDragging || self.scrollView.isTracking;
    
    if (userIsTouchingScrollView != self.userIsTouching) {
        self.userIsTouching = userIsTouchingScrollView;
    }
}

@end
