//
//  Action.m
//  PullToRefresh
//
//  Created by Marco on 17/08/15.
//  Copyright (c) 2015 MeLive. All rights reserved.
//

#import "Action.h"
#import "MUKPullToRevealControl.h"

@implementation Action

- (instancetype)initWithTitle:(NSString * __nonnull)title action:(void (^ __nonnull)(void))action
{
    self = [super init];
    if (self) {
        _title = [title copy];
        _action = [action copy];
    }
    
    return self;
}

+ (NSArray * __nonnull)standardSetWithPullToRevealView:(MUKPullToRevealControl * __nonnull)pullToRevealControl navigationController:(id)navigationController
{
    NSMutableArray *actions = [NSMutableArray array];
    
    Action *action = [[Action alloc] initWithTitle:@"Reveal" action:^{
        [pullToRevealControl revealAnimated:YES];
    }];
    [actions addObject:action];
    
    action = [[Action alloc] initWithTitle:@"Reveal (no animation)" action:^{
        [pullToRevealControl revealAnimated:NO];
    }];
    [actions addObject:action];
    
    action = [[Action alloc] initWithTitle:@"Cover" action:^{
        [pullToRevealControl coverAnimated:YES];
    }];
    [actions addObject:action];
    
    action = [[Action alloc] initWithTitle:@"Cover (no animation)" action:^{
        [pullToRevealControl coverAnimated:NO];
    }];
    [actions addObject:action];
    
    action = [[Action alloc] initWithTitle:@"Reveal after 3 s" action:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [pullToRevealControl revealAnimated:YES];
        });
    }];
    [actions addObject:action];
    
    action = [[Action alloc] initWithTitle:@"Cover after 3 s" action:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [pullToRevealControl coverAnimated:YES];
        });
    }];
    [actions addObject:action];
    
    action = [[Action alloc] initWithTitle:@"Reveal-cover quickly" action:^{
        [pullToRevealControl revealAnimated:YES];
        [pullToRevealControl coverAnimated:YES];
    }];
    [actions addObject:action];
    
    action = [[Action alloc] initWithTitle:@"Show navigation bar" action:^{
        [navigationController setNavigationBarHidden:NO animated:YES];
    }];
    [actions addObject:action];
    
    action = [[Action alloc] initWithTitle:@"Hide navigation bar" action:^{
        [navigationController setNavigationBarHidden:YES animated:YES];
    }];
    [actions addObject:action];
    
    return [actions copy];
}

- (instancetype)init {
    return [self initWithTitle:@"" action:nil];
}

@end
