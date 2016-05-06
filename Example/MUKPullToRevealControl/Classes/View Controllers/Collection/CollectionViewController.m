//
//  CollectionViewController.m
//  PullToRefresh
//
//  Created by Marco on 18/08/15.
//  Copyright (c) 2015 MeLive. All rights reserved.
//

#import "CollectionViewController.h"
#import "MUKCirclePullToRefreshControl.h"
#import "Action.h"
#import "CollectionViewCell.h"

@interface CollectionViewController ()
@property (nonatomic, copy) NSArray *actions;
@property (nonatomic) NSUInteger emptyItems;
@property (nonatomic, weak) MUKPullToRevealControl *pullToRevealControl;
@end

@implementation CollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    MUKPullToRevealControl *const pullToRevealControl = [[MUKCirclePullToRefreshControl alloc] init];
    [self.collectionView addSubview:pullToRevealControl];
    self.pullToRevealControl = pullToRevealControl;
    
    self.actions = [Action standardSetWithPullToRevealView:pullToRevealControl navigationController:self.navigationController];
    self.emptyItems = 100;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.pullToRevealControl.originalTopInset = self.topLayoutGuide.length;
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.actions.count + self.emptyItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewCell *const cell = (CollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithWhite:0.95f alpha:1.0f];
    
    if (indexPath.item < self.actions.count) {
        Action *const action = self.actions[indexPath.item];
        cell.textLabel.text = action.title;
    }
    else {
        cell.textLabel.text = [NSString stringWithFormat:@"%li", (long)indexPath.item];
    }
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.item < self.actions.count;
}

// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.item < self.actions.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item < self.actions.count) {
        Action *const action = self.actions[indexPath.item];
        action.action();
    }
    
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

#pragma mark - <UICollectionViewDelegateFlowLayout>

static CGFloat const kInteritemSpacing = 2.0f;

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSUInteger const kItemsPerRow = 2;
    CGFloat const availableWidth = CGRectGetWidth(collectionView.frame) - (kItemsPerRow + 1) * kInteritemSpacing;
    return CGSizeMake(floorf(availableWidth/kItemsPerRow), 44.0f);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return kInteritemSpacing;
}

@end
