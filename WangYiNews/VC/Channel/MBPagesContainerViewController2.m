//
//  MBPagesContainerViewController.m
//  motan
//
//  Created by Ming on 6/12/14.
//  Copyright (c) 2014 mdby. All rights reserved.
//

#import "MBPagesContainerViewController2.h"
#import "MBPagesContainerTopBar.h"
#import "MBPageIndicatorView.h"
#import "YKDataViewController.h"
#import "YKModelController.h"
#import "ColorConst.h"

#define PageIndicatorViewHeight 2.0

// TODO 这个版本的代码有个问题：当来回快速滑动时，动画会不响应
@interface MBPagesContainerViewController2 () <MBPagesContainerTopBarDelegate, UIPageViewControllerDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (assign, nonatomic) BOOL shouldObserveContentOffset;
@property (strong, nonatomic) YKModelController *modelController;

- (void)layoutSubviews;

@end


@implementation MBPagesContainerViewController2


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
    
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle: UIPageViewControllerTransitionStyleScroll
                                                              navigationOrientation: UIPageViewControllerNavigationOrientationHorizontal
                                                                            options:nil];
    self.pageViewController.delegate = self;
    self.pageViewController.dataSource = self.modelController;
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    self.pageViewController.view.frame = CGRectMake(0.,
                                                    self.topBarHeight,
                                                    CGRectGetWidth(self.view.frame),
                                                    CGRectGetHeight(self.view.frame) - self.topBarHeight);
    [self.pageViewController didMoveToParentViewController:self];
    self.view.gestureRecognizers = self.pageViewController.gestureRecognizers;
    
    for (UIView *subView in self.pageViewController.view.subviews){
        if ([subView isKindOfClass:[UIScrollView class]]){
            self.scrollView = (UIScrollView *)subView;
            [self.scrollView addObserver:self forKeyPath:@"contentOffset" options:0 context:nil];
        }
    }

    self.topBar.backgroundColor = self.topBarBackgroundColor;
}

- (void)viewWillLayoutSubviews
{
    [self layoutSubviews];
}

- (void)dealloc
{
    [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
}

#pragma mark - Public

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated
{
    UIButton *previosSelectdItem = self.topBar.itemViews[self.selectedIndex];
    UIButton *nextSelectdItem = self.topBar.itemViews[selectedIndex];
        self.shouldObserveContentOffset = NO;
 
    __weak UIPageViewController* pvcw = self.pageViewController;
    UIViewController *selectedVC = [self.modelController viewControllerAtIndex:selectedIndex storyboard:nil];
    UIPageViewControllerNavigationDirection direction = UIPageViewControllerNavigationDirectionForward;
    if (selectedIndex < _selectedIndex) {
        direction = UIPageViewControllerNavigationDirectionReverse;
    }
    [self.pageViewController setViewControllers:@[selectedVC]
                                      direction:direction
                                       animated:YES completion:^(BOOL finished) {
                                           UIPageViewController* pvcs = pvcw;
                                           if (!pvcs) return;
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               [pvcs setViewControllers:@[selectedVC]
                                                              direction:direction
                                                               animated:NO
                                                             completion:nil];
                                           });
                                       }];
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
        self.shouldObserveContentOffset = YES;
    }];
    
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

- (void)setTitles:(NSArray *)titles
{
    if (_titles != titles) {
        _titles = titles;
        self.topBar.itemTitles = _titles;
        
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
    CGRect pageIndicatorFrame = self.pageIndicatorView.frame;
    NSString *selectedTitle = [_titles objectAtIndex:_selectedIndex];
    CGSize titleSize = [selectedTitle sizeWithFont:self.topBar.font];
    pageIndicatorFrame.size.width = titleSize.width;
    pageIndicatorFrame.size.height = PageIndicatorViewHeight;
    self.pageIndicatorView.frame = pageIndicatorFrame;
    
    self.pageIndicatorView.center = CGPointMake([self.topBar centerForSelectedItemAtIndex:self.selectedIndex].x,[self pageIndicatorCenterY]);
    self.topBar.scrollView.contentOffset = [self.topBar contentOffsetForSelectedItemAtIndex:self.selectedIndex];
    
}

- (CGFloat)pageIndicatorCenterY
{
    CGFloat y = CGRectGetHeight(self.topBar.frame) - CGRectGetHeight(self.pageIndicatorView.frame) / 2.0;
    return y;
}

- (UIView *)pageIndicatorView
{
    if (!_pageIndicatorView) {
        if (self.pageIndicatorImage) {
            _pageIndicatorView = [[UIImageView alloc] initWithImage:self.pageIndicatorImage];
        } else {
            NSString *selectedTitle = [_titles objectAtIndex:_selectedIndex];
            CGSize titleSize = [selectedTitle sizeWithFont:self.topBar.font];
            _pageIndicatorView = [[MBPageIndicatorView alloc] initWithFrame:CGRectMake(0.,
                                                                                       CGRectGetHeight(self.topBar.frame) - PageIndicatorViewHeight,
                                                                                       titleSize.width,
                                                                                       PageIndicatorViewHeight)];
        }
        [self.topBar.scrollView addSubview:self.pageIndicatorView];
    }
    return _pageIndicatorView;
}


#pragma mark - MBPagesContainerTopBar delegate

- (void)itemAtIndex:(NSUInteger)index didSelectInPagesContainerTopBar:(MBPageIndicatorView *)bar
{
    [self setSelectedIndex:index animated:YES];
}


#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
                       context:(void *)context
{
    if (!self.scrollView.isDragging && !self.scrollView.isDecelerating) {
        return;
    }
    CGFloat oldX = CGRectGetWidth(self.scrollView.frame);
    CGFloat currentOffsetX = self.scrollView.contentOffset.x;
    if (oldX != currentOffsetX && self.shouldObserveContentOffset) {
        BOOL scrollingTowards = (currentOffsetX > oldX);
        NSInteger targetIndex = (scrollingTowards) ? self.selectedIndex + 1 : self.selectedIndex - 1;
        if (targetIndex >= 0 && targetIndex < self.titles.count) {
            CGFloat ratio = (currentOffsetX - oldX) / CGRectGetWidth(self.scrollView.frame);
            CGFloat previousItemContentOffsetX = [self.topBar contentOffsetForSelectedItemAtIndex:self.selectedIndex].x;
            CGFloat nextItemContentOffsetX = [self.topBar contentOffsetForSelectedItemAtIndex:targetIndex].x;

            CGFloat previousItemPageIndicatorX = [self.topBar centerForSelectedItemAtIndex:self.selectedIndex].x;
            CGFloat nextItemPageIndicatorX = [self.topBar centerForSelectedItemAtIndex:targetIndex].x;
 
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


#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers
{
    self.shouldObserveContentOffset = YES;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed{
    YKDataViewController *currentView = [pageViewController.viewControllers objectAtIndex:0];
    NSInteger currentIndex = [_modelController indexOfViewController:currentView];
    
    UIButton *previosSelectdItem = self.topBar.itemViews[self.selectedIndex];
    UIButton *nextSelectdItem = self.topBar.itemViews[currentIndex];
    self.shouldObserveContentOffset = NO;
    
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        if (_canChangePageIndicatorSize) {
            CGRect pageIndicatorFrame = self.pageIndicatorView.frame;
            UIButton *nextSelectedItem = self.topBar.itemViews[currentIndex];
            pageIndicatorFrame.size.width = CGRectGetWidth(nextSelectedItem.frame);
            self.pageIndicatorView.frame = pageIndicatorFrame;
        }
        self.pageIndicatorView.center = CGPointMake([self.topBar centerForSelectedItemAtIndex:currentIndex].x,
                                                    [self pageIndicatorCenterY]);
        self.topBar.scrollView.contentOffset = [self.topBar contentOffsetForSelectedItemAtIndex:currentIndex];
        if (_canChangePageIndicatorTextColor) {
            [previosSelectdItem setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [nextSelectdItem setTitleColor:self.selectedPageItemTitleColor forState:UIControlStateNormal];
        }
    } completion:NULL];
    
    _selectedIndex = currentIndex;
    self.shouldObserveContentOffset = NO;
}


#pragma mark -

- (YKModelController *)modelController {
    // Return the model controller object, creating it if necessary.
    // In more complex implementations, the model controller may be passed to the view controller.
    if (!_modelController) {
        _modelController = [[YKModelController alloc] init];
    }
    return _modelController;
}



@end
