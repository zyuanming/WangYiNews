//
//  MBPagesContainerViewController.m
//  motan
//
//  Created by Ming on 6/12/14.
//  Copyright (c) 2014 mdby. All rights reserved.
//

#import "MBPagesContainerViewController.h"
#import "MBPagesContainerTopBar.h"
#import "MBPageIndicatorView.h"
#import "ColorConst.h"

#define PageIndicatorViewHeight 2.0

@interface MBPagesContainerViewController () <MBPagesContainerTopBarDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (assign, nonatomic) UIScrollView *observingScrollView;
@property (          assign, nonatomic) BOOL shouldObserveContentOffset;
@property (readonly, assign, nonatomic) CGFloat scrollWidth;
@property (readonly, assign, nonatomic) CGFloat scrollHeight;

- (void)layoutSubviews;
- (void)startObservingContentOffsetForScrollView:(UIScrollView *)scrollView;
- (void)stopObservingContentOffset;

@end


@implementation MBPagesContainerViewController

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        [self setUp];
        _isTopBarInNavigationBar = YES;
        _canChangePageIndicatorSize = YES;
        _canChangePageIndicatorTextColor = YES;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)setUp
{
    _topBarItemsOffset = 10.0;
    _topBarHeight = 30.;
    _topBarBackgroundColor = [UIColor whiteColor];
    _topBarItemLabelsFont = [UIFont systemFontOfSize:18];
    self.selectedPageItemTitleColor = kColorCommonTintColor;
}

#pragma mark - View life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.shouldObserveContentOffset = YES;
    
    self.topBar = [[MBPagesContainerTopBar alloc] initWithFrame:CGRectMake(0.,
                                                                           0.,
                                                                           CGRectGetWidth(self.view.frame),
                                                                           self.topBarHeight)];
    self.topBar.pagesContainerTopBarItemsOffset = _topBarItemsOffset;
    self.topBar.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    self.topBar.itemTitleColor = [UIColor grayColor];
    self.topBar.delegate = self;
    if (self.parentViewController.navigationController && _isTopBarInNavigationBar) {
        _topBarHeight = 0;
    } else {
        [self.view addSubview:self.topBar];
    }
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.,
                                                                      self.topBarHeight,
                                                                      CGRectGetWidth(self.view.frame),
                                                                      CGRectGetHeight(self.view.frame) - self.topBarHeight)];
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.scrollView];
    [self startObservingContentOffsetForScrollView:self.scrollView];
    
    self.topBar.backgroundColor = self.topBarBackgroundColor;
}

- (void)viewWillLayoutSubviews
{
    [self layoutSubviews];
}

- (void)dealloc
{
    [self stopObservingContentOffset];
}

#pragma mark - Public

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated
{
    NSAssert(selectedIndex < self.viewControllers.count, @"selectedIndex should belong within the range of the view controllers array");
    UIButton *previosSelectdItem = self.topBar.itemViews[self.selectedIndex];
    UIButton *nextSelectdItem = self.topBar.itemViews[selectedIndex];
    if (labs(self.selectedIndex - selectedIndex) <= 1) {
        [self.scrollView setContentOffset:CGPointMake(selectedIndex * self.scrollWidth, 0.) animated:animated];
        if (selectedIndex == _selectedIndex) {
            self.pageIndicatorView.center = CGPointMake([self.topBar centerForSelectedItemAtIndex:selectedIndex].x,
                                                        [self pageIndicatorCenterY]);
        }
        if (_canChangePageIndicatorTextColor) {
            [UIView animateWithDuration:(animated) ? 0.3 : 0. delay:0. options:UIViewAnimationOptionBeginFromCurrentState animations:^
             {
                 [previosSelectdItem setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                 [nextSelectdItem setTitleColor:self.selectedPageItemTitleColor forState:UIControlStateNormal];
             } completion:nil];
        }

    } else {
        // This means we should "jump" over at least one view controller
        self.shouldObserveContentOffset = NO;
        BOOL scrollingRight = (selectedIndex > self.selectedIndex);
        UIViewController *leftViewController = self.viewControllers[MIN(self.selectedIndex, selectedIndex)];
        UIViewController *rightViewController = self.viewControllers[MAX(self.selectedIndex, selectedIndex)];
        leftViewController.view.frame = CGRectMake(0., 0., self.scrollWidth, self.scrollHeight);
        rightViewController.view.frame = CGRectMake(self.scrollWidth, 0., self.scrollWidth, self.scrollHeight);
        self.scrollView.contentSize = CGSizeMake(2 * self.scrollWidth, self.scrollHeight);
        
        CGPoint targetOffset;
        if (scrollingRight) {
            self.scrollView.contentOffset = CGPointZero;
            targetOffset = CGPointMake(self.scrollWidth, 0.);
        } else {
            self.scrollView.contentOffset = CGPointMake(self.scrollWidth, 0.);
            targetOffset = CGPointZero;
        }
        [self.scrollView setContentOffset:targetOffset animated:YES];
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            if (_canChangePageIndicatorSize) {
                CGRect pageIndicatorFrame = self.pageIndicatorView.frame;
                UIButton *nextSelectedItem = self.topBar.itemViews[selectedIndex];
                pageIndicatorFrame.size.width = CGRectGetWidth(nextSelectedItem.frame);
                self.pageIndicatorView.frame = pageIndicatorFrame;
            }
            self.pageIndicatorView.center = CGPointMake([self.topBar centerForSelectedItemAtIndex:selectedIndex].x,
                                                        [self pageIndicatorCenterY]);
            self.topBar.scrollView.contentOffset = [self.topBar contentOffsetForSelectedItemAtIndex:selectedIndex];
            if (_canChangePageIndicatorTextColor) {
                [previosSelectdItem setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                [nextSelectdItem setTitleColor:self.selectedPageItemTitleColor forState:UIControlStateNormal];
            }
        } completion:^(BOOL finished) {
            for (NSUInteger i = 0; i < self.viewControllers.count; i++) {
                UIViewController *viewController = self.viewControllers[i];
                viewController.view.frame = CGRectMake(i * self.scrollWidth, 0., self.scrollWidth, self.scrollHeight);
                [self.scrollView addSubview:viewController.view];
            }
            self.scrollView.contentSize = CGSizeMake(self.scrollWidth * self.viewControllers.count, self.scrollHeight);
            [self.scrollView setContentOffset:CGPointMake(selectedIndex * self.scrollWidth, 0.) animated:NO];
            self.shouldObserveContentOffset = YES;
        }];
    }
    _selectedIndex = selectedIndex;
}

- (void)updateLayoutForNewOrientation:(UIInterfaceOrientation)orientation
{
    [self layoutSubviews];
}

#pragma mark * Overwritten setters

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    [self setSelectedIndex:selectedIndex animated:NO];
}

- (void)setSelectedPageItemTitleColor:(UIColor *)selectedPageItemTitleColor
{
    if (![_selectedPageItemTitleColor isEqual:selectedPageItemTitleColor]) {
        _selectedPageItemTitleColor = selectedPageItemTitleColor;
        [self.topBar.itemViews[self.selectedIndex] setTitleColor:selectedPageItemTitleColor forState:UIControlStateNormal];
    }
}

- (void)setTopBarBackgroundColor:(UIColor *)topBarBackgroundColor
{
    if (_topBarBackgroundColor != topBarBackgroundColor) {
        _topBarBackgroundColor = topBarBackgroundColor;
        
        self.topBar.backgroundColor = topBarBackgroundColor;
    }
}

- (void)setTopBarBackgroundImage:(UIImage *)topBarBackgroundImage
{
    self.topBar.backgroundImage = topBarBackgroundImage;
}

- (void)setTopBarHeight:(NSUInteger)topBarHeight
{
    if (_topBarHeight != topBarHeight) {
        _topBarHeight = topBarHeight;
        [self layoutSubviews];
    }
}

- (void)setTopBarItemLabelsFont:(UIFont *)font
{
    self.topBar.font = font;
}

- (void)setViewControllers:(NSArray *)viewControllers
{
    if (_viewControllers != viewControllers) {
        _viewControllers = viewControllers;
        self.topBar.itemTitles = [viewControllers valueForKey:@"title"];
        
        for (UIView *subView in self.scrollView.subviews) {
            [subView removeFromSuperview];
        }
        
        for (UIViewController *viewController in viewControllers) {
            viewController.view.frame = CGRectMake(0., 0., CGRectGetWidth(self.scrollView.frame), self.scrollHeight);
            [self.scrollView addSubview:viewController.view];
            [self addChildViewController:viewController];
        }
        [self layoutSubviews];
        self.selectedIndex = 0;
        self.pageIndicatorView.center = CGPointMake([self.topBar centerForSelectedItemAtIndex:self.selectedIndex].x,
                                                    [self pageIndicatorCenterY]);
    }
}

- (void)setPageIndicatorImage:(UIImage *)pageIndicatorImage
{
    if (_pageIndicatorImage != pageIndicatorImage) {
        _pageIndicatorImage = pageIndicatorImage;

        if ((pageIndicatorImage && [self.pageIndicatorView isKindOfClass:[MBPageIndicatorView class]])
            || (!pageIndicatorImage && [self.pageIndicatorView isKindOfClass:[UIImageView class]])) {
            [self.pageIndicatorView removeFromSuperview];
            self.pageIndicatorView = nil;
        }
        if (pageIndicatorImage) {
            if ([self.pageIndicatorView isKindOfClass:[MBPageIndicatorView class]]) {
                [self.pageIndicatorView removeFromSuperview];
                self.pageIndicatorView = nil;
            }
            
            [(UIImageView *)self.pageIndicatorView setImage:pageIndicatorImage];
            
        } else {
            if ([self.pageIndicatorView isKindOfClass:[UIImageView class]]) {
                [self.pageIndicatorView removeFromSuperview];
                self.pageIndicatorView = nil;
            }
            [self.pageIndicatorView setBackgroundColor:self.topBarBackgroundColor];
        }
    }
}

- (void)setTopBarItemsOffset:(CGFloat)topBarItemsOffset
{
    _topBarItemsOffset = topBarItemsOffset;
    _topBar.pagesContainerTopBarItemsOffset = topBarItemsOffset;
    [_topBar setNeedsLayout];
}

#pragma mark - Private

- (void)layoutSubviews
{
    if (!_isTopBarInNavigationBar) {
        self.topBar.frame = CGRectMake(0., 0., CGRectGetWidth(self.view.bounds), self.topBarHeight);
    }
    
    CGFloat x = 0.;
    for (UIViewController *viewController in self.viewControllers) {
        viewController.view.frame = CGRectMake(x, 0, CGRectGetWidth(self.scrollView.frame), self.scrollHeight);
        //        viewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        x += CGRectGetWidth(self.scrollView.frame);
    }
    self.scrollView.contentSize = CGSizeMake(x, self.scrollHeight);
    [self.scrollView setContentOffset:CGPointMake(self.selectedIndex * self.scrollWidth, 0.) animated:YES];
    
    CGRect pageIndicatorFrame = self.pageIndicatorView.frame;
    UIViewController *selectedVC = [_viewControllers objectAtIndex:_selectedIndex];
    CGSize titleSize = [selectedVC.title sizeWithFont:self.topBar.font];
    pageIndicatorFrame.size.width = titleSize.width;
    pageIndicatorFrame.size.height = PageIndicatorViewHeight;
    self.pageIndicatorView.frame = pageIndicatorFrame;
    
    self.pageIndicatorView.center = CGPointMake([self.topBar centerForSelectedItemAtIndex:self.selectedIndex].x,[self pageIndicatorCenterY]);
    self.topBar.scrollView.contentOffset = [self.topBar contentOffsetForSelectedItemAtIndex:self.selectedIndex];
    
}

- (CGFloat)pageIndicatorCenterY
{
    //    CGFloat y = CGRectGetMaxY(self.topBar.frame) - 2. + CGRectGetHeight(self.pageIndicatorView.frame) / 2.;
    CGFloat y = CGRectGetHeight(self.topBar.frame) - CGRectGetHeight(self.pageIndicatorView.frame) / 2.0;
    return y;
}

- (UIView *)pageIndicatorView
{
    if (!_pageIndicatorView) {
        if (self.pageIndicatorImage) {
            _pageIndicatorView = [[UIImageView alloc] initWithImage:self.pageIndicatorImage];
        } else {
            UIViewController *selectedVC = [_viewControllers objectAtIndex:_selectedIndex];
            CGSize titleSize = [selectedVC.title sizeWithFont:self.topBar.font];
            _pageIndicatorView = [[MBPageIndicatorView alloc] initWithFrame:CGRectMake(0.,
                                                                                       CGRectGetHeight(self.topBar.frame) - PageIndicatorViewHeight,
                                                                                       titleSize.width,
                                                                                       PageIndicatorViewHeight)];
        }
        [self.topBar.scrollView addSubview:self.pageIndicatorView];
    }
    return _pageIndicatorView;
}

- (CGFloat)scrollHeight
{
    return CGRectGetHeight(self.view.frame) - self.topBarHeight;
}

- (CGFloat)scrollWidth
{
    return CGRectGetWidth(self.scrollView.frame);
}

- (void)startObservingContentOffsetForScrollView:(UIScrollView *)scrollView
{
    [scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    self.observingScrollView = scrollView;
}

- (void)stopObservingContentOffset
{
    if (self.observingScrollView) {
        [self.observingScrollView removeObserver:self forKeyPath:@"contentOffset"];
        self.observingScrollView = nil;
    }
}

#pragma mark - MBPagesContainerTopBar delegate

- (void)itemAtIndex:(NSUInteger)index didSelectInPagesContainerTopBar:(MBPageIndicatorView *)bar
{
    [self setSelectedIndex:index animated:YES];
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    self.selectedIndex = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    _selectedIndex = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
                       context:(void *)context
{
    
    CGFloat oldX = self.selectedIndex * CGRectGetWidth(self.scrollView.frame);
    if (oldX != self.scrollView.contentOffset.x && self.shouldObserveContentOffset) {
        BOOL scrollingTowards = (self.scrollView.contentOffset.x > oldX);
        NSInteger targetIndex = (scrollingTowards) ? self.selectedIndex + 1 : self.selectedIndex - 1;
        if (targetIndex >= 0 && targetIndex < self.viewControllers.count) {
            CGFloat ratio = (self.scrollView.contentOffset.x - oldX) / CGRectGetWidth(self.scrollView.frame);
            CGFloat previousItemContentOffsetX = [self.topBar contentOffsetForSelectedItemAtIndex:self.selectedIndex].x;
            CGFloat nextItemContentOffsetX = [self.topBar contentOffsetForSelectedItemAtIndex:targetIndex].x;
            
//            CGFloat previousItemContentOffsetX = ((UIView *)(self.topBar.itemViews[self.selectedIndex])).center.x;
//            CGFloat nextItemContentOffsetX = ((UIView *)(self.topBar.itemViews[targetIndex])).center.x;
//            
//            CGFloat previousItemPageIndicatorX = [self.topBar centerForSelectedItemAtIndex:self.selectedIndex].x;
//            CGFloat nextItemPageIndicatorX = [self.topBar centerForSelectedItemAtIndex:targetIndex].x;
            
            CGFloat previousItemPageIndicatorX = ((UIView *)(self.topBar.itemViews[self.selectedIndex])).center.x;
            CGFloat nextItemPageIndicatorX = ((UIView *)(self.topBar.itemViews[targetIndex])).center.x;
            
            UIButton *previosSelectedItem = self.topBar.itemViews[self.selectedIndex];
            UIButton *nextSelectedItem = self.topBar.itemViews[targetIndex];
            
            CGFloat previosWidth = CGRectGetWidth(previosSelectedItem.frame);
            CGFloat nextWidth = CGRectGetWidth(nextSelectedItem.frame);
            CGFloat gapWidth = nextWidth - previosWidth;
            
            CGFloat absRatio = fabsf(ratio);
            
            if (_canChangePageIndicatorTextColor) {
                CGFloat red, green, blue, alpha, highlightedRed, highlightedGreen, highlightedBlue, highlightedAlpha;
                [self getRed:&red green:&green blue:&blue alpha:&alpha fromColor:[UIColor grayColor]];
                [self getRed:&highlightedRed green:&highlightedGreen blue:&highlightedBlue alpha:&highlightedAlpha fromColor:self.selectedPageItemTitleColor];
                
                UIColor *prev = [UIColor colorWithRed:red * absRatio + highlightedRed * (1 - absRatio)
                                                green:green * absRatio + highlightedGreen * (1 - absRatio)
                                                 blue:blue * absRatio + highlightedBlue  * (1 - absRatio)
                                                alpha:alpha * absRatio + highlightedAlpha  * (1 - absRatio)];
                UIColor *next = [UIColor colorWithRed:red * (1 - absRatio) + highlightedRed * absRatio
                                                green:green * (1 - absRatio) + highlightedGreen * absRatio
                                                 blue:blue * (1 - absRatio) + highlightedBlue * absRatio
                                                alpha:alpha * (1 - absRatio) + highlightedAlpha * absRatio];
                
                [previosSelectedItem setTitleColor:prev forState:UIControlStateNormal];
                [nextSelectedItem setTitleColor:next forState:UIControlStateNormal];
            }
            
            if (scrollingTowards) {
                self.topBar.scrollView.contentOffset = CGPointMake(previousItemContentOffsetX +
                                                                   (nextItemContentOffsetX - previousItemContentOffsetX) * ratio , 0.);
                self.pageIndicatorView.center = CGPointMake(previousItemPageIndicatorX +
                                                            (nextItemPageIndicatorX - previousItemPageIndicatorX) * ratio,
                                                            [self pageIndicatorCenterY]);
                
            } else {
                self.topBar.scrollView.contentOffset = CGPointMake(previousItemContentOffsetX -
                                                                   (nextItemContentOffsetX - previousItemContentOffsetX) * ratio , 0.);
                self.pageIndicatorView.center = CGPointMake(previousItemPageIndicatorX -
                                                            (nextItemPageIndicatorX - previousItemPageIndicatorX) * ratio,
                                                            [self pageIndicatorCenterY]);
            }
            
            if (_canChangePageIndicatorSize) {
                CGRect pageIndicatorFrame = self.pageIndicatorView.frame;
                pageIndicatorFrame.size.width = previosWidth + gapWidth * absRatio;
                self.pageIndicatorView.frame = pageIndicatorFrame;
            }
        }
    }
}

- (void)getRed:(CGFloat *)red green:(CGFloat *)green blue:(CGFloat *)blue alpha:(CGFloat *)alpha fromColor:(UIColor *)color
{
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    CGColorSpaceModel colorSpaceModel = CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor));
    if (colorSpaceModel == kCGColorSpaceModelRGB && CGColorGetNumberOfComponents(color.CGColor) == 4) {
        *red = components[0];
        *green = components[1];
        *blue = components[2];
        *alpha = components[3];
    } else if (colorSpaceModel == kCGColorSpaceModelMonochrome && CGColorGetNumberOfComponents(color.CGColor) == 2) {
        *red = *green = *blue = components[0];
        *alpha = components[1];
    } else {
        *red = *green = *blue = *alpha = 0;
    }
}

@end
