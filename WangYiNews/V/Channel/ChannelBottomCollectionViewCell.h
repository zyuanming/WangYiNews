//
//  ChannelBottomCollectionViewCell.h
//  yooke
//
//  Created by ming on 15/3/6.
//  Copyright (c) 2015年 mdby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChannelItem.h"

@class ChannelBottomCollectionViewCell;

@protocol ChannelBottomCollectionViewCellDelegate <NSObject>

- (void)collectionCell:(ChannelBottomCollectionViewCell *)collectionCell didClickAddAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface ChannelBottomCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) id<ChannelBottomCollectionViewCellDelegate> cellDelegate;
@property (weak, nonatomic) IBOutlet UILabel *channelNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *addChannelButton;
@property (weak, nonatomic) IBOutlet UIView *separatorLineView;

+ (UINib *)nib;

- (void)configureCellWithData:(ChannelItem *)item inCollectionView:(UICollectionView *)collectionView;

@end
