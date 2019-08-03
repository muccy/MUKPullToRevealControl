//
//  MUKPullToRevealControlInsertion.m
//  
//
//  Created by Marco Muccinelli on 02/08/2019.
//

#import "MUKPullToRevealControlInsertion.h"

@implementation MUKPullToRevealControlInsertion

- (instancetype)initWithControl:(MUKPullToRevealControl *)control superview:(UIView *)superview
{
    self = [super init];
    if (self) {
        _superview = superview;
        _control = control;
    }
    
    return self;
}

- (BOOL)canStart {
    return [self.superview isKindOfClass:UIScrollView.class];
}

- (MUKPullToRevealControlLayouter *)start {
    UIScrollView *const scrollView = (UIScrollView *)self.superview;
    
    MUKPullToRevealControlLayouter *const layouter = [[MUKPullToRevealControlLayouter alloc] initWithScrollView:scrollView control:self.control];    
    return layouter;
}

@end
