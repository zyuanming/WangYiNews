//
//  ChannelHeaderCollectionReusableView.m
//  yooke
//
//  Created by ming on 15/3/6.
//  Copyright (c) 2015年 mdby. All rights reserved.
//

#import "ChannelHeaderCollectionReusableView.h"
#import "ColorConst.h"

@implementation ChannelHeaderCollectionReusableView

- (void)awakeFromNib {
    // Initialization code
    self.backgroundColor = kColorCommonViewBg;
}

+ (UINib *)nib
{
    return [UINib nibWithNibName:@"ChannelHeaderCollectionReusableView" bundle:nil];
}

@end
