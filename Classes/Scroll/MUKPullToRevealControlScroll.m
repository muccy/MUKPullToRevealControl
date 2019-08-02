//
//  MUKPullToRevealControlScroll.m
//  
//
//  Created by Marco Muccinelli on 02/08/2019.
//

#import "MUKPullToRevealControlScroll.h"

@implementation MUKPullToRevealControlScroll
- (instancetype)initWithName:(NSString *)name contentOffset:(CGPoint)contentOffset animated:(BOOL)animated loggingEnabled:(BOOL)loggingEnabled completionHandler:(void (^ _Nullable)(BOOL))completionHandler
{
    self = [super init];
    if (self) {
        _name = name;
        _contentOffset = contentOffset;
        _animated = animated;
        _loggingEnabled = loggingEnabled;
        _completionHandler = [completionHandler copy];
    }
    
    return self;
}

- (void)performOnScrollView:(nonnull UIScrollView *)scrollView {
    if (self.loggingEnabled) {
        NSLog(@"Performing scroll to y = %f", self.contentOffset.y);
    }
    
    [scrollView setContentOffset:self.contentOffset animated:self.animated];
    
    // Watchdog
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        
        if (strongSelf) {
            if (strongSelf.loggingEnabled) {
                NSLog(@"Watchdog is cancelling running scroll to y = %f", strongSelf.contentOffset.y);
            }
            
            [strongSelf didCompleteAsFinished:NO];
        }
    });
}

#pragma mark - Private

- (void)didCompleteAsFinished:(BOOL)finished {
    if (self.completionHandler) {
        self.completionHandler(finished);
    }
    
    if (self.loggingEnabled) {
        NSLog(@"Completed scroll to y = %f (finished = %@)", self.contentOffset.y, finished ? @"Y" : @"N");
    }
}

@end
