//
//  TouchView.m
//  yooke
//
//  Created by ming on 15/3/10.
//  Copyright (c) 2015年 mdby. All rights reserved.
//

#import "TouchView.h"

@implementation TouchView

- (id)initWithDeviceFrame
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    
    if (self) {
    }
    return self;
}

- (id)initWithActionTouchBegan:(void (^)())touchBegan
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    
    if (self) {
        self.touchBeganBlock = touchBegan;
    }
    return self;
}


#pragma mark - Override

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.touchBeganBlock) {
        self.touchBeganBlock();
    }
}

@end
