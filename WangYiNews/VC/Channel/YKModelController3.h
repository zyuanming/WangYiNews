//
//  YKModelController3.h
//  yooke
//
//  Created by ming on 15/3/5.
//  Copyright (c) 2015年 mdby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNPageViewController.h"

@interface YKModelController3 : NSObject <MNPageViewControllerDataSource>

@property (copy, nonatomic) NSArray *channelList;

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (NSUInteger)indexOfViewController:(UIViewController *)viewController;

@end
