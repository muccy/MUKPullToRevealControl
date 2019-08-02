//
//  MUKPullToRefreshControlLayouter.h
//  
//
//  Created by Marco Muccinelli on 02/08/2019.
//

#import <Foundation/Foundation.h>
#import <MUKPullToRevealControl/MUKPullToRevealControl.h>
#import <MUKPullToRevealControl/MUKPullToRevealControlContentInsetLayouter.h>
#import <MUKPullToRevealControl/MUKPullToRevealControlTouchesTracker.h>

NS_ASSUME_NONNULL_BEGIN

@interface MUKPullToRevealControlLayouter : NSObject <MUKPullToRevealControlTouchesTrackerDelegate>
@property (nonatomic, readonly, weak) UIScrollView *scrollView;
@property (nonatomic, readonly, weak) MUKPullToRevealControl *control;
@property (nonatomic, readonly) MUKPullToRevealControlContentInsetLayouter *insetLayouter;
@property (nonatomic, readonly) MUKPullToRevealControlTouchesTracker *touchesTracker;

- (instancetype)initWithScrollView:(UIScrollView *)scrollView control:(MUKPullToRevealControl *)control NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

- (void)start;
- (void)stop;
@end

NS_ASSUME_NONNULL_END
