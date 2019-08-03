//
//  MUKPullToRevealControlScrollRunner.m
//  
//
//  Created by Marco Muccinelli on 02/08/2019.
//

#import "MUKPullToRevealControlScrollRunner.h"

@interface MUKPullToRevealControlScrollRunner ()
@property (nonatomic, readwrite, nullable) MUKPullToRevealControlScroll *currentScroll;
@end

@implementation MUKPullToRevealControlScrollRunner

- (instancetype)initWithScrollView:(UIScrollView *)scrollView {
    self = [super init];
    if (self) {
        _scrollView = scrollView;
    }
    
    return self;
}

#pragma mark - Methods

- (void)startScroll:(MUKPullToRevealControlScroll *)scroll {
    [self forceRunningScrollCompletion];
    
    if (self.loggingEnabled) {
        NSLog(@"Performing scroll to y = %f", scroll.contentOffset.y);
    }
    
    self.currentScroll = scroll;
    
    // -setContentOffset:animated: is not reliable. For example, in iOS 13b5 it does not work
    // in UITableView, using animation
    // @see: https://stackoverflow.com/a/54920445
    NSTimeInterval const duration = scroll.animated ? 0.3 : 0.0;
    [UIView animateWithDuration:duration animations:^{
        [self.scrollView setContentOffset:scroll.contentOffset animated:NO];
    }];
    
    // Watchdog
    __weak typeof(self) weakSelf = self;
    __weak typeof(scroll) weakScroll = scroll;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((duration + 0.05) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        __strong __typeof(weakScroll) strongScroll = weakScroll;
        if (strongScroll) {
            [strongSelf didFireWatchdogForScroll:strongScroll];
        }
    });
}

- (void)completeCurrentScrollForNewContentOffset:(CGPoint)newOffset {
    if (self.currentScroll) {
        if (CGPointEqualToPoint(self.currentScroll.contentOffset, newOffset))
        {
            [self didCompleteScroll:self.currentScroll finished:YES];
        }
    }
}

#pragma mark - Private

- (void)didFireWatchdogForScroll:(nonnull MUKPullToRevealControlScroll *)scroll
{
    if ([scroll isEqual:self.currentScroll]) {
        if (self.loggingEnabled) {
            NSLog(@"Watchdog is cancelling running scroll to y = %f", scroll.contentOffset.y);
        }
        
        [self didCompleteScroll:scroll finished:NO];
    }
}

- (void)didCompleteScroll:(MUKPullToRevealControlScroll *__nonnull)scroll finished:(BOOL)finished
{
    if ([scroll isEqual:self.currentScroll]) {
        self.currentScroll = nil;
    }
    
    if (scroll.completionHandler) {
        scroll.completionHandler(finished);
    }
    
    if (self.loggingEnabled) {
        NSLog(@"Completed scroll to y = %f (finished = %@)", scroll.contentOffset.y, finished ? @"Y" : @"N");
    }
}

- (void)forceRunningScrollCompletion {
    if (self.currentScroll) {
        [self didCompleteScroll:self.currentScroll finished:NO];
    }
}

@end
