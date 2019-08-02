//
//  MUKPullToRevealControlFrameLayouter.h
//  
//
//  Created by Marco Muccinelli on 02/08/2019.
//

#import <Foundation/Foundation.h>
#import <MUKPullToRevealControl/MUKPullToRevealControl.h>

NS_ASSUME_NONNULL_BEGIN

@class MUKPullToRevealControlFrameLayouter;
@protocol MUKPullToRevealControlFrameLayouterDelegate <NSObject>
@required
- (CGFloat)scrollViewPulledHeightForFrameLayouter:(MUKPullToRevealControlFrameLayouter *)layouter;
@end

@interface MUKPullToRevealControlFrameLayouter : NSObject
@property (nonatomic, readonly, weak) UIScrollView *scrollView;
@property (nonatomic, readonly, weak) MUKPullToRevealControl *control;
@property (nonatomic) BOOL loggingEnabled;
@property (nonatomic) UIOffset offset;
@property (nonatomic, weak) id<MUKPullToRevealControlFrameLayouterDelegate> delegate;

- (instancetype)initWithScrollView:(UIScrollView *)scrollView control:(MUKPullToRevealControl *)control NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

- (void)start;
- (void)stop;

- (void)updateFrame;
- (void)updateContentViewFrame;
@end

NS_ASSUME_NONNULL_END