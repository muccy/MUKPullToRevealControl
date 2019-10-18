//
//  MUKPullToRefreshControlLayouter.h
//  
//
//  Created by Marco Muccinelli on 02/08/2019.
//

#import <Foundation/Foundation.h>
#import <MUKPullToRevealControl/MUKPullToRevealControl.h>
#import <MUKPullToRevealControl/MUKPullToRevealControlContentInsetLayouter.h>
#import <MUKPullToRevealControl/MUKPullToRevealControlFrameLayouter.h>
#import <MUKPullToRevealControl/MUKPullToRevealControlTouchesTracker.h>
#import <MUKPullToRevealControl/MUKPullToRevealControlScrollRunner.h>

NS_ASSUME_NONNULL_BEGIN

@class MUKPullToRevealControlLayouter;
@protocol MUKPullToRevealControlLayouterDelegate <NSObject>
@required
- (void)layouter:(MUKPullToRevealControlLayouter *)layouter didChangePulledHeight:(CGFloat)pulledHeight;
- (void)layouter:(MUKPullToRevealControlLayouter *)layouter didRecognizeUserTouchLeadingToState:(MUKPullToRevealControlState)state;
- (void)layouterNeedsToSendControlActions:(MUKPullToRevealControlLayouter *)layouter;
- (void)layouterDidConsumeUserTouch:(MUKPullToRevealControlLayouter *)layouter;
@end

@interface MUKPullToRevealControlLayouter : NSObject <MUKPullToRevealControlTouchesTrackerDelegate, MUKPullToRevealControlFrameLayouterDelegate>
@property (nonatomic, readonly, weak) UIScrollView *scrollView;
@property (nonatomic, readonly, weak) MUKPullToRevealControl *control;
@property (nonatomic, readonly) MUKPullToRevealControlContentInsetLayouter *insetLayouter;
@property (nonatomic, readonly) MUKPullToRevealControlFrameLayouter *frameLayouter;
@property (nonatomic, readonly) MUKPullToRevealControlTouchesTracker *touchesTracker;
@property (nonatomic, readonly) MUKPullToRevealControlScrollRunner *scrollRunner;
@property (nonatomic, weak) id<MUKPullToRevealControlLayouterDelegate> delegate;

- (instancetype)initWithScrollView:(UIScrollView *)scrollView control:(MUKPullToRevealControl *)control NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

/// Starts layout and observations
- (void)start;
/// Stop layout and observations
/// @warning You must call this method if you have called -start before! It is important due KVO observations
- (void)stop;
@end

NS_ASSUME_NONNULL_END
