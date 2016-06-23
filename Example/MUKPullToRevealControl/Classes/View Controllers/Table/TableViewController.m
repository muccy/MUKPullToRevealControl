//
//  TableViewController.m
//  PullToRefresh
//
//  Created by Marco on 15/08/15.
//  Copyright (c) 2015 MeLive. All rights reserved.
//

#import "TableViewController.h"
#import "MUKCirclePullToRefreshControl.h"
#import "Action.h"

#define DEBUG_FAST_COVER        0
#define DEBUG_OPAQUE_NAV_BAR    0

@interface TableViewController ()
@property (nonatomic, copy) NSArray *actions;
@property (nonatomic) NSUInteger emptyRows;
@property (nonatomic, weak) MUKPullToRevealControl *pullToRevealControl;
@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
#if DEBUG_OPAQUE_NAV_BAR
    self.navigationController.navigationBar.barTintColor = [UIColor lightGrayColor];
    self.navigationController.navigationBar.translucent = NO;
#endif
    
    MUKPullToRevealControl *const pullToRevealControl = [[MUKCirclePullToRefreshControl alloc] init];
    [pullToRevealControl addTarget:self action:@selector(pullToRevealControlTriggered:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:pullToRevealControl];
    self.pullToRevealControl = pullToRevealControl;
    
    self.emptyRows = 100;
    self.actions = [Action standardSetWithPullToRevealView:pullToRevealControl navigationController:self.navigationController];
}

- (void)pullToRevealControlTriggered:(MUKPullToRevealControl *)pullToRevealControl
{
#if DEBUG_FAST_COVER
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [pullToRevealControl coverAnimated:YES];
    });
#endif
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.pullToRevealControl.originalTopInset = self.topLayoutGuide.length;
}

#pragma mark - Table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.actions.count + self.emptyRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *const cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    if (indexPath.row < self.actions.count) {
        Action *const action = self.actions[indexPath.row];
        cell.textLabel.text = action.title;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    else {
        cell.textLabel.text = [NSString stringWithFormat:@"%li", (long)indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.actions.count) {
        Action *const action = self.actions[indexPath.row];
        action.action();
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Section Header";
}

@end
