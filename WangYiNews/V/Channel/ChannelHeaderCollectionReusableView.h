//
//  ChannelHeaderCollectionReusableView.h
//  yooke
//
//  Created by ming on 15/3/6.
//  Copyright (c) 2015年 mdby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChannelHeaderCollectionReusableView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UILabel *leftLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;

+ (UINib *)nib;

@end
