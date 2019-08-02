//
//  MUKPullToRevealControlTouchesTracker.m
//  
//
//  Created by Marco Muccinelli on 02/08/2019.
//

#import "MUKPullToRevealControlTouchesTracker.h"

@implementation MUKPullToRevealControlTouchesTracker

- (instancetype)initWithLoggingEnabled:(BOOL)loggingEnabled {
    self = [super init];
    if (self) {
        _loggingEnabled = loggingEnabled;
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

@end
