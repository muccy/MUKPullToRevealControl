//
//  MUKPullToRevealControlContentInsetLayouter.h
//  
//
//  Created by Marco Muccinelli on 02/08/2019.
//

#import <Foundation/Foundation.h>
#import <MUKPullToRevealControl/MUKPullToRevealControl.h>

NS_ASSUME_NONNULL_BEGIN

@interface MUKPullToRevealControlContentInsetLayouter : NSObject
@property (nonatomic, readonly, weak) UIScrollView *scrollView;
@property (nonatomic, readonly, weak) MUKPullToRevealControl *control;
@property (nonatomic, readonly) UIEdgeInsets first, revealed, covered;
@property (nonatomic, readwrite) UIEdgeInsets original;

@property (nonatomic, readonly) BOOL ignoresOriginal, revealStateAffectsContentInset;
@property (nonatomic) CGFloat originalTop;

- (instancetype)initWithScrollView:(UIScrollView *)scrollView control:(MUKPullToRevealControl *)control NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

- (void)start;
- (void)stop;

- (void)updateContentInset:(UIEdgeInsets)insets;
- (void)updateContentInsetForContentOffsetChange;
@end

NS_ASSUME_NONNULL_END
