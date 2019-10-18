//
//  MUKPullToRevealControlScrollViewObserver.m
//  
//
//  Created by Marco Muccinelli on 02/08/2019.
//

#import "MUKPullToRevealControlScrollViewObserver.h"
#import <MUKSignal/MUKSignal.h>

static void *const kKVOContext = (void *)&kKVOContext;

@interface MUKPullToRevealControlScrollViewObserver ()
@property (nonatomic) BOOL isObserving;
@property (nonatomic, readonly, nullable) UIScrollView *scrollView;
@end

@implementation MUKPullToRevealControlScrollViewObserver
@dynamic scrollView;

- (void)dealloc {
    [self stop];
}

- (instancetype)initWithDelegate:(id<MUKPullToRevealControlScrollViewObserverDelegate>)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
    }
    
    return self;
}

#pragma mark - Accessors

- (UIScrollView *)scrollView {
    return [self.delegate scrollViewForScrollViewObserver:self];
}

#pragma mark - Methods

- (void)start {
    if (!self.isObserving) {
        [self.scrollView addObserver:self forKeyPath:NSStringFromSelector(@selector(contentInset)) options:NSKeyValueObservingOptionNew context:kKVOContext];
        [self.scrollView addObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset)) options:NSKeyValueObservingOptionNew context:kKVOContext];
        self.isObserving = YES;
    }
}

- (void)stop {
    if (self.isObserving) {
        [self.scrollView removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentInset)) context:kKVOContext];
        [self.scrollView removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset)) context:kKVOContext];
        self.isObserving = NO;
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context != &kKVOContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }

    if (object == self.scrollView) {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(contentInset))]) {
            [self didChangeContentInset];
        }
        else if ([keyPath isEqualToString:NSStringFromSelector(@selector(contentOffset))]) {
            [self didChangeContentOffset];
        }
    }
}

#pragma mark - Private — Observations

- (void)didChangeContentInset {
    UIEdgeInsets const newInset = self.scrollView.contentInset;
            
    if (self.loggingEnabled) {
        NSLog(@"New inset = %@", NSStringFromUIEdgeInsets(newInset));
    }
    
    [self.delegate scrollViewObserver:self didObserveNewContentInset:newInset];
}

- (void)didChangeContentOffset {
    CGPoint const newOffset = self.scrollView.contentOffset;
    
    if (self.loggingEnabled) {
        NSLog(@"New offset = %@", NSStringFromCGPoint(newOffset));
    }
    
    [self.delegate scrollViewObserver:self didObserveNewContentOffset:newOffset];
}

@end
