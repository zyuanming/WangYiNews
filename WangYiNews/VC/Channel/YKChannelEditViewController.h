//
//  YKChannelEditViewController.h
//  yooke
//
//  Created by ming on 15/3/2.
//  Copyright (c) 2015年 mdby. All rights reserved.
//

#import <UIKit/UIKit.h>

static const CGFloat SectionViewHeight = 35.;
extern NSString * const UsingChannelListCacheKey;
extern NSString * const LeftChannelListCacheKey;

@interface YKChannelEditViewController : UIViewController

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong, readonly) NSArray *selectedChannels;

@end
