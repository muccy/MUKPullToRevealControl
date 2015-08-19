//
//  ScrollViewController.m
//  PullToRefresh
//
//  Created by Marco on 18/08/15.
//  Copyright (c) 2015 MeLive. All rights reserved.
//

#import "ScrollViewController.h"
#import "MUKCirclePullToRefreshControl.h"
#import "Action.h"

@interface ScrollViewController ()
@property (nonatomic, copy) NSArray *actions;
@property (nonatomic, copy) NSArray *buttons;
@property (nonatomic, weak) MUKPullToRevealControl *pullToRevealControl;
@end

@implementation ScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    MUKPullToRevealControl *const pullToRevealControl = [[MUKCirclePullToRefreshControl alloc] init];
    [self.scrollView addSubview:pullToRevealControl];
    self.pullToRevealControl = pullToRevealControl;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.buttons) {
        self.actions = [Action standardSetWithPullToRevealView:self.pullToRevealControl navigationController:self.navigationController];
        [self insertButtonsForActions:self.actions];
        
        self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetMaxY([self.buttons.lastObject frame]));
    }
}

#pragma mark - Private

- (void)insertButtonsForActions:(NSArray *__nonnull)actions {
    NSMutableArray *buttons = [NSMutableArray arrayWithCapacity:actions.count];
    
    [actions enumerateObjectsUsingBlock:^(Action *action, NSUInteger idx, BOOL *stop)
    {
        UIButton *const button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setTitle:action.title forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.scrollView addSubview:button];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        
        // Keep centered
        [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
        
        // Vertical spacing
        static CGFloat const kVerticalSpacing = 30.0f;
        UIButton *const lastButton = buttons.lastObject;
        
        if (lastButton) {
            [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:lastButton attribute:NSLayoutAttributeBottom multiplier:1.0f constant:kVerticalSpacing]];
        }
        else {
            [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeTop multiplier:1.0f constant:self.scrollView.layoutMargins.top + kVerticalSpacing]];
        }
        
        // Keep track
        [buttons addObject:button];
    }];
    
    self.buttons = buttons;
}

- (void)buttonPressed:(UIButton *)button {
    NSUInteger const idx = [self.buttons indexOfObject:button];
    
    if (idx < self.actions.count) {
        Action *const action = self.actions[idx];
        action.action();
    }
}

@end
