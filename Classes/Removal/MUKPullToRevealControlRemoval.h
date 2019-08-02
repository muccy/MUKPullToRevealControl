//
//  MUKPullToRevealControlRemoval.h
//  
//
//  Created by Marco Muccinelli on 02/08/2019.
//

#import <Foundation/Foundation.h>
#import <MUKPullToRevealControl/MUKPullToRevealControlLayouter.h>

NS_ASSUME_NONNULL_BEGIN

@interface MUKPullToRevealControlRemoval : NSObject
@property (nonatomic, readonly, nullable) UIView *superview;
@property (nonatomic, readonly, nullable) MUKPullToRevealControlLayouter *layouter;

- (instancetype)initWithSuperview:(nullable UIView *)superview layouter:(nullable MUKPullToRevealControlLayouter *)layouter NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@property (nonatomic, readonly) BOOL canStart;
- (void)start;
@end

NS_ASSUME_NONNULL_END
