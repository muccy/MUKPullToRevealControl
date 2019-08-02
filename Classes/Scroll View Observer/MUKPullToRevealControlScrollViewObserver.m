//
//  MUKPullToRevealControlScrollViewObserver.m
//  
//
//  Created by Marco Muccinelli on 02/08/2019.
//

#import "MUKPullToRevealControlScrollViewObserver.h"
#import <MUKSignal/MUKSignal.h>

@interface MUKPullToRevealControlScrollViewObserver ()
@property (nonatomic, readwrite, nullable) MUKSignalObservation<MUKKVOSignal *> *contentInsetObservation, *contentOffsetObservation;
@end

@implementation MUKPullToRevealControlScrollViewObserver

- (void)dealloc {
    [self stop];
}

- (instancetype)initWithScrollView:(UIScrollView *)scrollView {
    self = [super init];
    if (self) {
        _scrollView = scrollView;
    }
    
    return self;
}

#pragma mark - Methods

- (void)start {
    [self startObservingContentInset];
    [self startObservingContentOffset];
}

- (void)stop {
    self.contentInsetObservation = nil;
    self.contentOffsetObservation = nil;
}

#pragma mark - Private — Observations

- (void)startObservingContentInset {
    MUKKVOSignal *const signal = [[MUKKVOSignal alloc] initWithObject:self.scrollView keyPath:NSStringFromSelector(@selector(contentInset))];
    self.contentInsetObservation = [MUKSignalObservation observationWithSignal:signal token:[signal subscribeWithTarget:self action:@selector(didChangeContentInset:)]];
}

- (void)startObservingContentOffset {
    MUKKVOSignal *const signal = [[MUKKVOSignal alloc] initWithObject:self.scrollView keyPath:NSStringFromSelector(@selector(contentOffset))];
    self.contentOffsetObservation = [MUKSignalObservation observationWithSignal:signal token:[signal subscribeWithTarget:self action:@selector(didChangeContentOffset:)]];
}

- (void)didChangeContentInset:(nonnull MUKKVOSignalChange<NSNumber *> *)change
{
    UIEdgeInsets const newInset = change.value.UIEdgeInsetsValue;
            
    if (self.loggingEnabled) {
        NSLog(@"New inset = %@", NSStringFromUIEdgeInsets(newInset));
    }
    
    [self.delegate scrollViewObserver:self didObserveNewContentInset:newInset];
}

- (void)didChangeContentOffset:(nonnull MUKKVOSignalChange<NSNumber *> *)change
{
    CGPoint const newOffset = change.value.CGPointValue;
    
    if (self.loggingEnabled) {
        NSLog(@"New offset = %@", NSStringFromCGPoint(newOffset));
    }
    
    [self.delegate scrollViewObserver:self didObserveNewContentOffset:newOffset];
}

@end
