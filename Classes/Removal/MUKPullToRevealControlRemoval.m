//
//  MUKPullToRevealControlRemoval.m
//  
//
//  Created by Marco Muccinelli on 02/08/2019.
//

#import "MUKPullToRevealControlRemoval.h"

@implementation MUKPullToRevealControlRemoval

- (instancetype)initWithSuperview:(UIView *)superview layouter:(MUKPullToRevealControlLayouter *)layouter
{
    self = [super init];
    if (self) {
        _superview = superview;
        _layouter = layouter;
    }
    
    return self;
}

- (BOOL)canStart {
    return [self.superview isKindOfClass:UIScrollView.class];
}

- (void)start {
    [self.layouter stop];
}

@end
