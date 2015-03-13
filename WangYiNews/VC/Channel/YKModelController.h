//
//  ModelController.h
//  test
//
//  Created by ming on 15/3/4.
//  Copyright (c) 2015年 yooke. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YKDataViewController;

@interface YKModelController : NSObject <UIPageViewControllerDataSource>

- (YKDataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (NSUInteger)indexOfViewController:(YKDataViewController *)viewController;

@end

