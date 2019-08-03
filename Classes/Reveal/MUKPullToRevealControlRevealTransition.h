//
//  MUKPullToRevealControlRevealTransition.h
//  
//
//  Created by Marco Muccinelli on 02/08/2019.
//

#import <Foundation/Foundation.h>
#import <MUKPullToRevealControl/MUKPullToRevealControlLayouter.h>

NS_ASSUME_NONNULL_BEGIN

@class MUKPullToRevealControlRevealTransition;
@protocol MUKPullToRevealControlRevealTransitionDelegate <NSObject>
@required
- (void)revealTransitionIsReadyToChangeControlState:(MUKPullToRevealControlRevealTransition *)transition;
@end

@interface MUKPullToRevealControlRevealTransition : NSObject
@property (nonatomic, readonly) MUKPullToRevealControlLayouter *layouter;
@property (nonatomic, readonly) BOOL animated;
@property (nonatomic, weak) id<MUKPullToRevealControlRevealTransitionDelegate> delegate;

+ (BOOL)isValidFromState:(MUKPullToRevealControlState)state;

- (instancetype)initWithLayouter:(MUKPullToRevealControlLayouter *)layouter animated:(BOOL)animated NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

- (void)start;
@end

NS_ASSUME_NONNULL_END
