//
//  MUKPullToRevealControlScrollRunner.h
//  
//
//  Created by Marco Muccinelli on 02/08/2019.
//

#import <Foundation/Foundation.h>
#import <MUKPullToRevealControl/MUKPullToRevealControlScroll.h>

NS_ASSUME_NONNULL_BEGIN

@interface MUKPullToRevealControlScrollRunner : NSObject
@property (nonatomic, readonly, weak) UIScrollView *scrollView;
@property (nonatomic, readonly, nullable) MUKPullToRevealControlScroll *currentScroll;
@property (nonatomic) BOOL loggingEnabled;

- (instancetype)initWithScrollView:(UIScrollView *)scrollView NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

- (void)startScroll:(MUKPullToRevealControlScroll *)scroll;
- (void)completeCurrentScrollForNewContentOffset:(CGPoint)newOffset;
@end

NS_ASSUME_NONNULL_END
