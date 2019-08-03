//
//  MUKPullToRevealControlScroll.m
//  
//
//  Created by Marco Muccinelli on 02/08/2019.
//

#import "MUKPullToRevealControlScroll.h"

@implementation MUKPullToRevealControlScroll
- (instancetype)initWithName:(NSString *)name contentOffset:(CGPoint)contentOffset animated:(BOOL)animated completionHandler:(void (^ _Nullable)(BOOL))completionHandler
{
    self = [super init];
    if (self) {
        _name = name;
        _contentOffset = contentOffset;
        _animated = animated;
        _completionHandler = [completionHandler copy];
    }
    
    return self;
}

@end
