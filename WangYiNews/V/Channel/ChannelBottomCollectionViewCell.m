//
//  ChannelBottomCollectionViewCell.m
//  yooke
//
//  Created by ming on 15/3/6.
//  Copyright (c) 2015年 mdby. All rights reserved.
//

#import "ChannelBottomCollectionViewCell.h"
#import "ColorConst.h"

@interface ChannelBottomCollectionViewCell()

@property (nonatomic, weak) UICollectionView *collectionView;

@end

@implementation ChannelBottomCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
    [self initUI];
    [self.addChannelButton addTarget:self action:@selector(addButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
}

+ (UINib *)nib
{
    return [UINib nibWithNibName:@"ChannelBottomCollectionViewCell" bundle:nil];
}

- (void)initUI
{
    _separatorLineView.backgroundColor = kColorCommonViewBg;
    [_addChannelButton setImage:[UIImage imageNamed:@"channel_add"] forState:UIControlStateNormal];
}

- (void)configureCellWithData:(ChannelItem *)item inCollectionView:(UICollectionView *)collectionView
{
    self.collectionView = collectionView;
    self.channelNameLabel.text = item.channelName;
}


#pragma mark - Action

- (void)addButtonDidClicked:(id)sender
{
    if ([self.cellDelegate conformsToProtocol:@protocol(ChannelBottomCollectionViewCellDelegate)]) {
        [self.cellDelegate collectionCell:self didClickAddAtIndexPath:[self.collectionView indexPathForCell:self]];
    }
}

@end
