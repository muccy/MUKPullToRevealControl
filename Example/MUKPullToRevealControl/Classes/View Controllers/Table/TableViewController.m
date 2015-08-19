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

@interface TableViewController ()
@property (nonatomic, copy) NSArray *actions;
@property (nonatomic) NSUInteger emptyRows;
@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    MUKPullToRevealControl *const pullToRevealControl = [[MUKCirclePullToRefreshControl alloc] init];
    [self.tableView addSubview:pullToRevealControl];
    
    self.emptyRows = 100;
    self.actions = [Action standardSetWithPullToRevealView:pullToRevealControl navigationController:self.navigationController];
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

@end
