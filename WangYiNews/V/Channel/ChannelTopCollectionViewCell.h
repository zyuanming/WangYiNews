//
//  ChannelTopCollectionViewCell.h
//  yooke
//
//  Created by ming on 15/3/6.
//  Copyright (c) 2015年 mdby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChannelTopCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *channelNameLabel;

+ (UINib *)nib;

@end
