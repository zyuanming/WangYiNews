//
//  Const.h
//  WangYiNews
//
//  Created by ming on 15/3/13.
//  Copyright (c) 2015年 yooke. All rights reserved.
//

#ifndef WangYiNews_Const_h
#define WangYiNews_Const_h

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

#endif
