//
//  DataViewController.m
//  test
//
//  Created by ming on 15/3/4.
//  Copyright (c) 2015年 yooke. All rights reserved.
//

#import "YKDataViewController.h"

@interface YKDataViewController ()

@property (nonatomic, strong)UILabel *dataLabel;

@end

@implementation YKDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.dataLabel = [[UILabel alloc]initWithFrame:self.view.bounds];
    self.dataLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.dataLabel];
}

- (void)dealloc
{
    NSLog(@"hello....");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.dataLabel.text = [self.dataObject description];
}

@end
