//
//  TouchView.h
//  yooke
//
//  Created by ming on 15/3/10.
//  Copyright (c) 2015年 mdby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TouchView : UIView

@property (nonatomic, copy) void (^touchBeganBlock)();

- (id)initWithActionTouchBegan:(void (^)())touchBegan;
- (id)initWithDeviceFrame;

@end
