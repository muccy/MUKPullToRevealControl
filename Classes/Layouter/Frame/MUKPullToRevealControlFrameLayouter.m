//
//  MUKPullToRevealControlFrameLayouter.m
//  
//
//  Created by Marco Muccinelli on 02/08/2019.
//

#import "MUKPullToRevealControlFrameLayouter.h"

@implementation MUKPullToRevealControlFrameLayouter

- (instancetype)initWithScrollView:(UIScrollView *)scrollView control:(MUKPullToRevealControl *)control
{
    self = [super init];
    if (self) {
        _scrollView = scrollView;
        _control = control;
    }
    
    return self;
}

#pragma mark - Accessors

- (void)setOffset:(UIOffset)offset {
    if (!UIOffsetEqualToOffset(offset, _offset)) {
        _offset = offset;
        [self updateFrameInScrollView:scrollView];
    }
}

#pragma mark - Methods

- (void)start {
    
}

- (void)stop {
    
}

@end
