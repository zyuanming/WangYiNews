//
//  MBPagesContainerViewController.h
//  motan
//
//  Created by Ming on 6/12/14.
//  Copyright (c) 2014 mdby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBPagesContainerTopBar.h"

//@class MBPagesContainerViewController2;
//
//@protocol YKPagesContainerViewControllerDataSource <NSObject>
//
//- (UIViewController *)pageViewController:(MBPagesContainerViewController2 *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController;
//
//- (UIViewController *)pageViewController:(MBPagesContainerViewController2 *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController;
//
//@end

@interface MBPagesContainerViewController2 : UIViewController

@property (nonatomic, strong) UIPageViewController *pageViewController;

//@property (nonatomic, weak) id<YKPagesContainerViewControllerDataSource> dataSource;

/**
 *  指定顶部的导航栏是否放在Navigation bar 上面
 */
@property (assign, nonatomic, setter = setTopBarInNavigationBar:) BOOL isTopBarInNavigationBar;

@property (assign, nonatomic) BOOL canChangePageIndicatorSize;

@property (assign, nonatomic) BOOL canChangePageIndicatorTextColor;

@property (strong, nonatomic) MBPagesContainerTopBar *topBar;

@property (assign, nonatomic) CGFloat topBarItemsOffset;

@property (strong, nonatomic) UIView *pageIndicatorView;

@property (strong, nonatomic) NSArray *titles;

/**
 An index of the selected view controller.
 */
@property (assign, nonatomic) NSUInteger selectedIndex;

/**
 A hight of the top bar. Every time this value is changed, view objects for all the view controllers are resized.
 This is 44. by default.
 */
@property (assign, nonatomic) NSUInteger topBarHeight;

/**
 An optional image page for the page indicator view
 This is {22., 9.} by default.
 */
@property (strong, nonatomic) UIImage *pageIndicatorImage;

/**
 An optional background image of the top bar.
 */
@property (strong, nonatomic) UIImage *topBarBackgroundImage;

/**
 A background color of the top bar.
 This is black by default.
 */
@property (strong, nonatomic) UIColor *topBarBackgroundColor;

/**
 A font for all the buttons displayed in the top bar.
 This is system font of sixe 12. by default.
 */
@property (strong, nonatomic) UIFont *topBarItemLabelsFont;

/**
 A color of the selected view titles displayed on the top bar.
 This is white by default.
 */
@property (strong, nonatomic) UIColor *selectedPageItemTitleColor;

/**
 Changes 'selectedIndex' property value and navigates to the newly selected view controller
 @param selectedIndex This mathod throws exeption if selectedIndex is out of range of the 'viewControllers' array
 @param animated Defines whether to present the corresponding view controller animated
 @discussion If 'animated' is YES and the newly selected view is not "the closest neighbor" of the previous selected view, all the intermediate views will be skipped for the sake of nice animation
 */
- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated;

/**
 Makes sure that view objects for all the view controllers are properly resized to fit the container bounds after device orientation was changed
 */
- (void)updateLayoutForNewOrientation:(UIInterfaceOrientation)orientation;

@end
