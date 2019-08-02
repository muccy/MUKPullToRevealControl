//
//  MUKPullToRevealControlRevealTransition.h
//  
//
//  Created by Marco Muccinelli on 02/08/2019.
//

#import <Foundation/Foundation.h>
#import <MUKPullToRevealControl/MUKPullToRevealControl.h>
#import <MUKPullToRevealControl/MUKPullToRevealControlLayouter.h>

NS_ASSUME_NONNULL_BEGIN

@interface MUKPullToRevealControlRevealTransition : NSObject
@property (nonatomic, readonly) MUKPullToRevealControlLayouter *layouter;

+ (BOOL)isValidFromState:(MUKPullToRevealControlState)state;
@end

NS_ASSUME_NONNULL_END
