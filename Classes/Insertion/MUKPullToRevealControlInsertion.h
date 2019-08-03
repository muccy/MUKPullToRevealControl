//
//  MUKPullToRevealControlInsertion.h
//  
//
//  Created by Marco Muccinelli on 02/08/2019.
//

#import <Foundation/Foundation.h>
#import <MUKPullToRevealControl/MUKPullToRevealControl.h>
#import <MUKPullToRevealControl/MUKPullToRevealControlLayouter.h>

NS_ASSUME_NONNULL_BEGIN

@interface MUKPullToRevealControlInsertion : NSObject
@property (nonatomic, readonly, nullable) UIView *superview;
@property (nonatomic, readonly) MUKPullToRevealControl *control;

- (instancetype)initWithControl:(MUKPullToRevealControl *)control superview:(nullable UIView *)superview NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@property (nonatomic, readonly) BOOL canStart;
- (MUKPullToRevealControlLayouter *)start;
@end

NS_ASSUME_NONNULL_END
