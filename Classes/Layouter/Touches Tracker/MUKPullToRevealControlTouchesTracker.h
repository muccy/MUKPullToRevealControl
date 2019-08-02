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
@property (nonatomic, readwrite) BOOL userIsTouching;
@property (nonatomic, readonly) BOOL loggingEnabled;
@property (nonatomic, weak) id<MUKPullToRevealControlTouchesTrackerDelegate> delegate;

- (instancetype)initWithLoggingEnabled:(BOOL)loggingEnabled NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
