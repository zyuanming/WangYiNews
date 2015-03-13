//
//  YKModelController3.m
//  yooke
//
//  Created by ming on 15/3/5.
//  Copyright (c) 2015年 mdby. All rights reserved.
//

#import "YKModelController3.h"
#import "YKDataViewController.h"
#import "ChannelItem.h"

/*
 A controller object that manages a simple model -- a collection of month names.
 
 The controller serves as the data source for the page view controller; it therefore implements pageViewController:viewControllerBeforeViewController: and pageViewController:viewControllerAfterViewController:.
 It also implements a custom method, viewControllerAtIndex: which is useful in the implementation of the data source methods, and in the initial configuration of the application.
 
 There is no need to actually create view controllers for each page in advance -- indeed doing so incurs unnecessary overhead. Given the data model, these methods create, configure, and return a new view controller on demand.
 */


@interface YKModelController3 ()

@property (nonatomic, copy) NSArray *titleArray;

@end

@implementation YKModelController3

- (instancetype)init {
    self = [super init];
    if (self) {
        // Create the data model.
    }
    return self;
}

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard {
    // Return the data view controller for the given index.
    if (([self.channelList count] == 0) || (index >= [self.channelList count])) {
        return nil;
    }
    
    YKDataViewController *viewController = [[YKDataViewController alloc]init];
    viewController.title = self.titleArray[index];
    viewController.dataObject = self.titleArray[index];
    return viewController;
}

- (NSUInteger)indexOfViewController:(YKDataViewController *)viewController {
    // Return the index of the given data view controller.
    // For simplicity, this implementation uses a static array of model objects and the view controller stores the model object; you can therefore use the model object to identify the index.
    return [self.titleArray indexOfObject:viewController.title];
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)mn_pageViewController:(MNPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(YKDataViewController *)viewController];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

- (UIViewController *)mn_pageViewController:(MNPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(YKDataViewController *)viewController];
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.channelList count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

- (void)setChannelList:(NSArray *)channelList
{
    if (_channelList != channelList) {
        _channelList = channelList;
        
        NSMutableArray *tmpArray = [NSMutableArray array];
        for (ChannelItem *item in _channelList) {
            [tmpArray addObject:item.channelName];
        }
        self.titleArray = [NSArray arrayWithArray:tmpArray];
    }
}

@end
