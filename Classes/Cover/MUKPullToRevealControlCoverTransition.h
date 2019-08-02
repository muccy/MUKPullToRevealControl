//
//  MUKPullToRevealControlCoverTransition.h
//  
//
//  Created by Marco Muccinelli on 02/08/2019.
//

#import <Foundation/Foundation.h>
#import <MUKPullToRevealControl/MUKPullToRevealControl.h>

NS_ASSUME_NONNULL_BEGIN

@interface MUKPullToRevealControlCoverTransition : NSObject
+ (BOOL)isValidFromState:(MUKPullToRevealControlState)state;

@end

NS_ASSUME_NONNULL_END
