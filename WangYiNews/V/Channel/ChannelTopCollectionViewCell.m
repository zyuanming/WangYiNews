//
//  ChannelTopCollectionViewCell.m
//  yooke
//
//  Created by ming on 15/3/6.
//  Copyright (c) 2015年 mdby. All rights reserved.
//

#import "ChannelTopCollectionViewCell.h"
#import "ColorConst.h"

@implementation ChannelTopCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
    self.channelNameLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.channelNameLabel.layer.borderWidth = 1;
}


#pragma mark - Override

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    if (!self.userInteractionEnabled) {
        return;
    }
    if (highlighted) {
        self.channelNameLabel.layer.borderColor = kColorChannelHighlightColor.CGColor;
    } else {
        self.channelNameLabel.layer.borderColor = kColorCommonBorderColor.CGColor;
    }
}

+ (UINib *)nib
{
    return [UINib nibWithNibName:@"ChannelTopCollectionViewCell" bundle:nil];
}

@end
