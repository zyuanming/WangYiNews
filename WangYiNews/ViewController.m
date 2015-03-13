//
//  ViewController.m
//  WangYiNews
//
//  Created by ming on 15/3/12.
//  Copyright (c) 2015年 yooke. All rights reserved.
//

#import "ViewController.h"
#import "YKChannelEditViewController.h"
#import "TouchView.h"
#import "ChannelHeaderCollectionReusableView.h"
#import "ChannelItem.h"
#import "MBPagesContainerViewController3.h"
#import "ColorConst.h"
#import "Const.h"

@interface ViewController ()

@property (nonatomic, strong) TouchView *touchView;
@property (nonatomic, strong) YKChannelEditViewController *channelEditViewController;
@property (nonatomic, strong) ChannelHeaderCollectionReusableView *channelHeaderView;
@property (nonatomic, copy) NSArray *usingChannelList;
@property (nonatomic, strong) ChannelItem *currentSelectedChannel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"顺企汇";
    
    self.pagesContainer = [[MBPagesContainerViewController3 alloc] init];
    self.pagesContainer.topBarHeight = SectionViewHeight;
    [self.pagesContainer willMoveToParentViewController:self];
    [self addChildViewController:self.pagesContainer];
    self.pagesContainer.view.frame = self.view.bounds;
    self.pagesContainer.view.backgroundColor = kColorCommonViewBg;
    self.pagesContainer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.pagesContainer.view];
    [self.pagesContainer didMoveToParentViewController:self];
    self.pagesContainer.topBar.frame = CGRectMake(0.,
                                                  0.,
                                                  CGRectGetWidth(self.view.frame)-40,
                                                  self.pagesContainer.topBarHeight);
    
    NSMutableArray *usingList = [[NSMutableArray alloc] initWithArray:@[@"电影",@"数码",@"时尚",@"奇葩"]];
    NSMutableArray *leftList = [[NSMutableArray alloc] initWithArray:@[@"游戏",@"旅游",@"育儿",@"减肥",]];
    
    NSData *tmpData = [[NSUserDefaults standardUserDefaults]objectForKey:UsingChannelListCacheKey];
    self.usingChannelList = [NSKeyedUnarchiver unarchiveObjectWithData:tmpData];
    if (!self.usingChannelList) {
        NSMutableArray *tmpArray = [NSMutableArray array];
        for (int i = 0; i < usingList.count; i++) {
            ChannelItem *item = [[ChannelItem alloc]init];
            item.channelName = usingList[i];
            item.itemId = [NSString stringWithFormat:@"%@", @(i)];
            [tmpArray addObject:item];
        }
        self.usingChannelList = [NSArray arrayWithArray:tmpArray];
        tmpData = [NSKeyedArchiver archivedDataWithRootObject:self.usingChannelList];
        [[NSUserDefaults standardUserDefaults]setObject:tmpData forKey:UsingChannelListCacheKey];
    }
    self.pagesContainer.channelList = self.usingChannelList;
    
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:LeftChannelListCacheKey]) {
        NSMutableArray *tmpArray = [NSMutableArray array];
        for (NSInteger i = 0; i < leftList.count; i++) {
            ChannelItem *item = [[ChannelItem alloc]init];
            item.channelName = leftList[i];
            item.itemId = [NSString stringWithFormat:@"%@", @(i + usingList.count)];
            [tmpArray addObject:item];
        }
        tmpData = [NSKeyedArchiver archivedDataWithRootObject:tmpArray];
        [[NSUserDefaults standardUserDefaults] setObject:tmpData forKey:LeftChannelListCacheKey];
    }
    
    self.pagesContainer.channelList = _usingChannelList;
    
    /// 打开编辑菜单按钮
    UIButton *arrowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    arrowButton.frame = CGRectMake(CGRectGetWidth(self.view.frame)-40, 0, 40, self.pagesContainer.topBarHeight);
    [arrowButton setImage:[UIImage imageNamed:@"channel_nav_arrow"] forState:UIControlStateNormal];
    arrowButton.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:arrowButton];
    [arrowButton addTarget:self action:@selector(toggleChannelEdit:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Action

- (void)toggleChannelEdit:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    /// 关闭编辑视图
    
    if (self.channelHeaderView.alpha == 1.0) {
        [UIView animateWithDuration:0.5 animations:^{
            button.imageView.transform = CGAffineTransformMakeRotation(2*M_PI);
        }];
        NSArray *tmpArray = [self.channelEditViewController getSelectedChannel];
        if (![self channelList:tmpArray isEqualTo:self.usingChannelList]) {
            self.pagesContainer.channelList = tmpArray;
            self.usingChannelList = [NSArray arrayWithArray:tmpArray];
            NSInteger currentIndex = [self getCurrentIndexWithCurrentChannel:self.currentSelectedChannel];
            [self.pagesContainer setSelectedIndex:currentIndex];
        }
        [self hideChannelEditVC];
        return;
    }
    
    /// 打开编辑视图
    
    self.currentSelectedChannel = self.usingChannelList[self.pagesContainer.selectedIndex];
    /// 构造背景触摸视图，这里是留出了上面的navigation bar 的高度，点击上面可以收回订阅编辑视图
    if (self.touchView) {
        [self.touchView removeFromSuperview];
    }
    self.touchView = [[TouchView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 64.0)];
    [self.navigationController.view addSubview:self.touchView];
    __weak typeof(self) weakSelf = self;
    self.touchView.touchBeganBlock = ^(void) {
        [weakSelf hideChannelEditVC];
    };
    
    /// 延迟加载订阅编辑视图
    if (!_channelEditViewController) {
        self.channelEditViewController = [[YKChannelEditViewController alloc]init];
        [self.channelEditViewController willMoveToParentViewController:self.pagesContainer];
        [self.pagesContainer addChildViewController:self.channelEditViewController];
        self.channelEditViewController.view.frame = CGRectMake(0, -CGRectGetHeight(self.view.frame)+self.pagesContainer.topBarHeight, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-self.pagesContainer.topBarHeight);
        [self.pagesContainer.view insertSubview:self.channelEditViewController.view belowSubview:self.pagesContainer.topBar];
        [self.channelEditViewController didMoveToParentViewController:self.pagesContainer];
    }
    
    /// 构造编辑视图显示时上面的头部视图
    if (!_channelHeaderView) {
        self.channelHeaderView = [[NSBundle mainBundle]loadNibNamed:@"ChannelHeaderCollectionReusableView" owner:self options:0][0];
        self.channelHeaderView.alpha = 0.0;
        self.channelHeaderView.leftLabel.text = @"已添加标签";
        self.channelHeaderView.tipsLabel.text = @"(点击删除)";
        self.channelHeaderView.frame = self.pagesContainer.topBar.bounds;
        [self.view addSubview:self.channelHeaderView];
    }
    
    /// 以动画形式展示订阅编辑视图
    [UIView animateWithDuration:0.5 animations:^{
        self.channelHeaderView.alpha = 1.0;
        self.channelEditViewController.view.frame = CGRectMake(0, self.pagesContainer.topBarHeight, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-self.pagesContainer.topBarHeight);
    } completion:NULL];
    
    [UIView animateWithDuration:0.5 animations:^{
        button.imageView.transform = CGAffineTransformMakeRotation(M_PI);
    }];
}

- (void)hideChannelEditVC
{
    [UIView animateWithDuration:0.5 animations:^{
        self.channelEditViewController.view.frame = CGRectMake(0, -CGRectGetHeight(self.view.frame)+self.pagesContainer.topBarHeight, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
        self.channelHeaderView.alpha = 0.0;
        self.touchView.hidden = YES;
    } completion:NULL];
}


#pragma mark -

- (NSInteger)getCurrentIndexWithCurrentChannel:(ChannelItem *)currentItem
{
    for (int i = 0 ; i < self.usingChannelList.count; i++) {
        ChannelItem *item = self.usingChannelList[i];
        if (item.itemId == currentItem.itemId) {
            return i;
        }
    }
    return 0;
}

- (BOOL)channelList:(NSArray *)toList isEqualTo:(NSArray *)fromList
{
    if (toList.count != fromList.count) {
        return NO;
    }
    for (int i = 0; i < toList.count; i++) {
        ChannelItem *toItem = toList[i];
        ChannelItem *fromItem  = fromList[i];
        if (toItem.itemId != fromItem.itemId) {
            return NO;
        }
    }
    return YES;
}

@end

