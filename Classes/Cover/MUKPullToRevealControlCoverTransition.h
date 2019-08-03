//
//  MUKPullToRevealControlCoverTransition.h
//  
//
//  Created by Marco Muccinelli on 02/08/2019.
//

#import <Foundation/Foundation.h>
#import <MUKPullToRevealControl/MUKPullToRevealControlLayouter.h>
#import <MUKPullToRevealControl/MUKPullToRevealControl.h>

NS_ASSUME_NONNULL_BEGIN

@class MUKPullToRevealControlCoverTransition;
@protocol MUKPullToRevealControlCoverTransitionDelegate <NSObject>
@required
- (void)coverTransitionIsReadyToChangeControlState:(MUKPullToRevealControlCoverTransition *)transition;
- (void)coverTransition:(MUKPullToRevealControlCoverTransition *)transition needsToPostponeAfterUserTouchJob:(dispatch_block_t)job;
@end

@interface MUKPullToRevealControlCoverTransition : NSObject
@property (nonatomic, readonly) MUKPullToRevealControlLayouter *layouter;
@property (nonatomic, readonly, weak) MUKPullToRevealControl *control;
@property (nonatomic, readonly) BOOL animated;
@property (nonatomic, weak) id<MUKPullToRevealControlCoverTransitionDelegate> delegate;

- (instancetype)initWithLayouter:(MUKPullToRevealControlLayouter *)layouter control:(MUKPullToRevealControl *)control animated:(BOOL)animated NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@property (nonatomic, readonly) BOOL canStart;
- (void)start;
@end

NS_ASSUME_NONNULL_END
