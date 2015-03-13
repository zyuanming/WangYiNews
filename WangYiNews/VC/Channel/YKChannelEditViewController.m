//
//  YKChannelEditViewController.m
//  yooke
//
//  Created by ming on 15/3/2.
//  Copyright (c) 2015年 mdby. All rights reserved.
//

#import "YKChannelEditViewController.h"
#import "ChannelEditLayout.h"
#import "UICollectionView+Draggable.h"
#import "ChannelHeaderCollectionReusableView.h"
#import "ChannelTopCollectionViewCell.h"
#import "ChannelBottomCollectionViewCell.h"
#import "UICollectionViewDataSource_Draggable.h"
#import "ChannelItem.h"
#import "ColorConst.h"

static NSString * const ChannelHeaderCollectionReusableViewIdentifier = @"ChannelHeaderCollectionReusableView";
static NSString * const ChannelTopCollectionViewCellIdentifier = @"ChannelTopCollectionViewCell";
static NSString * const ChannelBottomCollectionViewCellIdentifier = @"ChannelBottomCollectionViewCell";

@interface YKChannelEditViewController ()<UICollectionViewDataSource_Draggable, UICollectionViewDelegateFlowLayout, ChannelBottomCollectionViewCellDelegate>

@property (nonatomic, strong) NSMutableArray *channelData;

@end

@implementation YKChannelEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:[[ChannelEditLayout alloc]init]];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.draggable = YES;
    
    [self.collectionView registerNib:[ChannelBottomCollectionViewCell nib] forCellWithReuseIdentifier:ChannelBottomCollectionViewCellIdentifier];
    [self.collectionView registerNib:[ChannelTopCollectionViewCell nib] forCellWithReuseIdentifier:ChannelTopCollectionViewCellIdentifier];
    [self.collectionView registerNib:[ChannelHeaderCollectionReusableView nib] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:ChannelHeaderCollectionReusableViewIdentifier];
    
    [self.view addSubview:self.collectionView];
    
    NSData *tmpData = [[NSUserDefaults standardUserDefaults] objectForKey:UsingChannelListCacheKey];
    NSMutableArray *tmpArray1 = [[NSKeyedUnarchiver unarchiveObjectWithData:tmpData] mutableCopy];
    tmpData = [[NSUserDefaults standardUserDefaults] objectForKey:LeftChannelListCacheKey];
    NSMutableArray *tmpArray2 = [[NSKeyedUnarchiver unarchiveObjectWithData:tmpData] mutableCopy];

    self.channelData = [NSMutableArray array];
    [self.channelData addObject:tmpArray1];
    [self.channelData addObject:tmpArray2];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger count = [self.channelData[section] count];
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *channelList = self.channelData[indexPath.section];
    ChannelItem *item = channelList[indexPath.item];
    if (indexPath.section == 0) {
        ChannelTopCollectionViewCell *topCell = [collectionView dequeueReusableCellWithReuseIdentifier:ChannelTopCollectionViewCellIdentifier
                                                                                          forIndexPath:indexPath];
        if (indexPath.item == 0) {
            topCell.userInteractionEnabled = NO;
            topCell.channelNameLabel.textColor = [UIColor lightGrayColor];
            topCell.channelNameLabel.layer.borderColor = kColorCommonViewBg.CGColor;
        } else {
            topCell.channelNameLabel.textColor = [UIColor darkGrayColor];
            topCell.channelNameLabel.layer.borderColor = kColorCommonBorderColor.CGColor;
        }
        topCell.channelNameLabel.text = item.channelName;
        return topCell;
    } else {
        ChannelBottomCollectionViewCell *bottomCell = [collectionView dequeueReusableCellWithReuseIdentifier:ChannelBottomCollectionViewCellIdentifier
                                                                                                forIndexPath:indexPath];
        [bottomCell configureCellWithData:item inCollectionView:collectionView];
        bottomCell.cellDelegate = self;
        return bottomCell;
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    ChannelHeaderCollectionReusableView *supplementaryView;
    if ([kind isEqual:UICollectionElementKindSectionHeader]) {
        supplementaryView =[collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                              withReuseIdentifier:ChannelHeaderCollectionReusableViewIdentifier
                                                                     forIndexPath:indexPath];
    }
    return supplementaryView;
}


#pragma mark - UICollectionViewDelegateFlowLayout

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    if (section == 0) {
        return 8;
    } else {
        return 0;
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if (section == 0) {
        return UIEdgeInsetsMake(8, 8, 8, 8);
    } else {
        return UIEdgeInsetsMake(0, 8, 0, 8);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return CGSizeMake(70, 35);
    } else {
        UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionViewLayout;
        return CGSizeMake(CGRectGetWidth(self.view.frame)-flowLayout.sectionInset.left-flowLayout.sectionInset.right, 50.0);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return CGSizeZero;
    } else {
        UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionViewLayout;
        return CGSizeMake(CGRectGetWidth(self.view.frame)-flowLayout.sectionInset.left-flowLayout.sectionInset.right, SectionViewHeight);
    }
}


#pragma mark - UICollectionViewDataSource_Draggable

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSMutableArray *data1 = [self.channelData objectAtIndex:fromIndexPath.section];
    NSMutableArray *data2 = [self.channelData objectAtIndex:toIndexPath.section];
    id index = [data1 objectAtIndex:fromIndexPath.item];
    
    [data1 removeObjectAtIndex:fromIndexPath.item];
    [data2 insertObject:index atIndex:toIndexPath.item];
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 || indexPath.item == 0) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    if (toIndexPath.item == 0) {
        return NO;
    }
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != 0) {
        return;
    }

    NSIndexPath *targetIndexPath = [NSIndexPath indexPathForItem:0 inSection:1];
    [self collectionView:collectionView moveItemAtIndexPath:indexPath toIndexPath:targetIndexPath];
    [self.collectionView performBatchUpdates:^{
        [self.collectionView moveItemAtIndexPath:indexPath toIndexPath:targetIndexPath];

    } completion:NULL];
    [self.collectionView reloadItemsAtIndexPaths:@[targetIndexPath]];
}


#pragma mark - ChannelBottomCollectionViewCellDelegate

- (void)collectionCell:(ChannelBottomCollectionViewCell *)collectionCell didClickAddAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *targetIndexPath = [NSIndexPath indexPathForItem:[self.channelData[0] count] inSection:0];
    [self collectionView:self.collectionView moveItemAtIndexPath:indexPath toIndexPath:targetIndexPath];
    [self.collectionView performBatchUpdates:^{
        [self.collectionView moveItemAtIndexPath:indexPath toIndexPath:targetIndexPath];
    } completion:NULL];
    [self.collectionView reloadItemsAtIndexPaths:@[targetIndexPath]];
}


#pragma mark -

- (NSArray *)getSelectedChannel
{
    return [NSArray arrayWithArray:self.channelData[0]];
}


@end
