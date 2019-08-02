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
- (void)scrollViewObserver:(MUKPullToRevealControlScrollViewObserver *)observer didObserveNewContentInset:(UIEdgeInsets)newInset;
- (void)scrollViewObserver:(MUKPullToRevealControlScrollViewObserver *)observer didObserveNewContentOffset:(CGPoint)newOffset;
@end

@interface MUKPullToRevealControlScrollViewObserver : NSObject
@property (nonatomic, readonly, weak) UIScrollView *scrollView;
@property (nonatomic) BOOL loggingEnabled;
@property (nonatomic, weak) id<MUKPullToRevealControlScrollViewObserverDelegate> delegate;

- (instancetype)initWithScrollView:(UIScrollView *)scrollView NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

- (void)start;
- (void)stop;
@end

NS_ASSUME_NONNULL_END
