//
//  Action.h
//  PullToRefresh
//
//  Created by Marco on 17/08/15.
//  Copyright (c) 2015 MeLive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MUKPullToRevealControl;
@interface Action : NSObject
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) void (^action)(void);

- (instancetype)initWithTitle:(NSString *)title action:(void (^)(void))action NS_DESIGNATED_INITIALIZER;

+ (NSArray *)standardSetWithPullToRevealView:(MUKPullToRevealControl *)pullToRevealControl navigationController:(UINavigationController *)navigationController;
@end

NS_ASSUME_NONNULL_END
