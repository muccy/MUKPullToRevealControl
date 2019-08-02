//
//  MUKPullToRevealControlTouchesTracker.h
//  
//
//  Created by Marco Muccinelli on 02/08/2019.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MUKPullToRevealControlTouchesTracker;
@protocol MUKPullToRevealControlTouchesTrackerDelegate <NSObject>
@required
- (void)touchesTrackerDidChangeValue:(MUKPullToRevealControlTouchesTracker *)tracker;
@end

@interface MUKPullToRevealControlTouchesTracker : NSObject
@property (nonatomic, readonly, weak) UIScrollView *scrollView;
@property (nonatomic) BOOL userIsTouching;
@property (nonatomic) BOOL loggingEnabled;
@property (nonatomic, weak) id<MUKPullToRevealControlTouchesTrackerDelegate> delegate;

- (instancetype)initWithScrollView:(UIScrollView *)scrollView NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

- (void)start;
- (void)stop;

- (void)update;
@end

NS_ASSUME_NONNULL_END
