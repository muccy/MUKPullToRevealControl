//
//  MUKPullToRevealControlScrollViewObserver.h
//  
//
//  Created by Marco Muccinelli on 02/08/2019.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MUKPullToRevealControlScrollViewObserver;
@protocol MUKPullToRevealControlScrollViewObserverDelegate <NSObject>
@required
- (nullable UIScrollView *)scrollViewForScrollViewObserver:(MUKPullToRevealControlScrollViewObserver *)observer; // I don't want to maintain a weak reference in KVO context
- (void)scrollViewObserver:(MUKPullToRevealControlScrollViewObserver *)observer didObserveNewContentInset:(UIEdgeInsets)newInset;
- (void)scrollViewObserver:(MUKPullToRevealControlScrollViewObserver *)observer didObserveNewContentOffset:(CGPoint)newOffset;
@end

@interface MUKPullToRevealControlScrollViewObserver : NSObject
@property (nonatomic) BOOL loggingEnabled;
@property (nonatomic, readonly, weak) id<MUKPullToRevealControlScrollViewObserverDelegate> delegate;

- (instancetype)initWithDelegate:(id<MUKPullToRevealControlScrollViewObserverDelegate>)delegate NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

- (void)start;
/// @warning You must call this method if you have called -start before! It is important due KVO observations
- (void)stop;
@end

NS_ASSUME_NONNULL_END
