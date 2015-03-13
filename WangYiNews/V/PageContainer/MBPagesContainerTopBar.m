//
//  RootTopScrollView.m
//  motan
//
//  Created by Ming on 5/26/14.
//  Copyright (c) 2014 mdby. All rights reserved.
//

#import "MBPagesContainerTopBar.h"

@interface MBPagesContainerTopBar()

@property (nonatomic, strong) UIImageView       *backgroundImageView;
@property (nonatomic, strong) UIScrollView      *scrollView;
@property (nonatomic, strong) NSArray           *itemViews;

@end

@implementation MBPagesContainerTopBar


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.scrollsToTop = NO;
        _scrollView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.scrollView];
        
        UIImageView *shadowImageView = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_scrollView.frame)-6, CGRectGetMinY(_scrollView.frame), 6, CGRectGetHeight(_scrollView.frame))];
        UIImage *shadowImage = [[UIImage imageNamed:@"nav_shadow"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 12, 1, 1)];
        shadowImageView.image = shadowImage;
        [self addSubview:shadowImageView];

        _pagesContainerTopBarItemsOffset = 25.0;
        _font = [UIFont systemFontOfSize:18];
        _itemTitleColor = [UIColor whiteColor];
        
    }
    return self;
}


#pragma mark - Public

- (CGPoint)centerForSelectedItemAtIndex:(NSUInteger)index
{
    CGPoint center = ((UIView *)self.itemViews[index]).center;
    return center;
}

- (CGPoint)contentOffsetForSelectedItemAtIndex:(NSUInteger)index
{
    if (self.itemViews.count < index || self.itemViews.count == 1) {
        return CGPointZero;
    } else {
        CGFloat totalOffset = self.scrollView.contentSize.width - CGRectGetWidth(self.scrollView.frame);
        return CGPointMake(index * totalOffset / (self.itemViews.count - 1), 0.);
    }
}

- (CGRect)contentCenterRectForSelectedItemAtIndex:(NSInteger)index
{
    if (self.itemViews.count < index || self.itemViews.count == 1) {
        return CGRectZero;
    } else {
        CGPoint center = [self centerForSelectedItemAtIndex:index];
        return CGRectMake(center.x - CGRectGetWidth(self.scrollView.frame) / 2.0,
                          0,
                          CGRectGetWidth(self.scrollView.frame),
                          CGRectGetHeight(self.scrollView.frame));
    }
}

- (void)scrollToCenter:(NSUInteger)index
{
    [self.scrollView scrollRectToVisible:[self contentCenterRectForSelectedItemAtIndex:index] animated:YES];
}

- (void)setItemTitleColor:(UIColor *)itemTitleColor
{
    if (![_itemTitleColor isEqual:itemTitleColor]) {
        _itemTitleColor = itemTitleColor;
        for (UIButton *button in self.itemViews) {
            [button setTitleColor:itemTitleColor forState:UIControlStateNormal];
        }
    }
}

- (void)setPagesContainerTopBarItemsOffset:(CGFloat)pagesContainerTopBarItemsOffset
{
    _pagesContainerTopBarItemsOffset = pagesContainerTopBarItemsOffset;
    [self setNeedsLayout];
}


#pragma mark * Overwritten setters

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    self.backgroundImageView.image = backgroundImage;
}

- (void)setItemTitles:(NSArray *)itemTitles
{
    if (_itemTitles != itemTitles) {
        _itemTitles = itemTitles;
        NSMutableArray *mutableItemViews = [NSMutableArray arrayWithCapacity:itemTitles.count];
        
        for ( UIView *view in self.scrollView.subviews) {
            [view removeFromSuperview];
        }
        
        for (NSUInteger i = 0; i < itemTitles.count; i++) {
            
            UIButton *itemView = [UIButton buttonWithType:UIButtonTypeCustom];
            [itemView addTarget:self action:@selector(itemViewTapped:) forControlEvents:UIControlEventTouchUpInside];
            itemView.titleLabel.font = self.font;
            [itemView setTitleColor:self.itemTitleColor forState:UIControlStateNormal];
            itemView.backgroundColor = [UIColor clearColor];
            [itemView setTitle:itemTitles[i] forState:UIControlStateNormal];
            [self.scrollView addSubview:itemView];
            
            [mutableItemViews addObject:itemView];
        }
        self.itemViews = [NSArray arrayWithArray:mutableItemViews];
        [self layoutItemViews];
    }
}

- (void)setFont:(UIFont *)font
{
    if (![_font isEqual:font]) {
        _font = font;
        for (UIButton *itemView in self.itemViews) {
            [itemView.titleLabel setFont:font];
        }
    }
}


#pragma mark - Private

- (void)itemViewTapped:(UIButton *)sender
{
    [self.delegate itemAtIndex:[self.itemViews indexOfObject:sender] didSelectInPagesContainerTopBar:self];
}

- (void)layoutItemViews
{
    CGFloat x = _pagesContainerTopBarItemsOffset;
    for (NSUInteger i = 0; i < self.itemViews.count; i++) {
        CGFloat width = [self.itemTitles[i] sizeWithFont:self.font].width;
        UIView *itemView = self.itemViews[i];
        itemView.frame = CGRectMake(x, 0., width, CGRectGetHeight(self.frame));
        x += width + _pagesContainerTopBarItemsOffset;
    }
    self.scrollView.contentSize = CGSizeMake(x, CGRectGetHeight(self.scrollView.frame));
    CGRect frame = self.scrollView.frame;
//    if (CGRectGetWidth(self.frame) > x) {
//        // 如果头部的标签过少，则居中滚动条
//        frame.origin.x = (CGRectGetWidth(self.frame) - x) / 2.;
//        frame.size.width = x;
//    } else {
        frame.origin.x = 0.;
        frame.size.width = CGRectGetWidth(self.frame);
//    }
    self.scrollView.frame = frame;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutItemViews];
}


#pragma mark * Lazy getters

- (UIImageView *)backgroundImageView
{
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self insertSubview:_backgroundImageView belowSubview:self.scrollView];
    }
    return _backgroundImageView;
}

@end
