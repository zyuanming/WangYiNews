//
//  RootTopScrollView.h
//  motan
//
//  Created by Ming on 5/26/14.
//  Copyright (c) 2014 mdby. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MBPagesContainerTopBar;

@protocol MBPagesContainerTopBarDelegate <NSObject>

- (void)itemAtIndex:(NSUInteger)index didSelectInPagesContainerTopBar:(MBPagesContainerTopBar *)bar;

@end

@interface MBPagesContainerTopBar : UIView
{
}

@property (nonatomic, weak) id<MBPagesContainerTopBarDelegate> delegate;
@property (nonatomic, strong) UIImage                   *backgroundImage;
@property (nonatomic, strong) UIColor                   *itemTitleColor;
@property (nonatomic, strong) NSArray                   *itemTitles;
@property (nonatomic, strong) UIFont                    *font;
@property (nonatomic, strong, readonly) NSArray         *itemViews;
@property (nonatomic, strong, readonly) UIScrollView    *scrollView;
@property (nonatomic, assign) CGFloat                   pagesContainerTopBarItemsOffset;

- (CGPoint)centerForSelectedItemAtIndex:(NSUInteger)index;
- (CGPoint)contentOffsetForSelectedItemAtIndex:(NSUInteger)index;
- (void)scrollToCenter:(NSUInteger)index;

@end
