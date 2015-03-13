//
//  ChannelItem.m
//  yooke
//
//  Created by ming on 15/3/11.
//  Copyright (c) 2015年 mdby. All rights reserved.
//

#import "ChannelItem.h"

static NSString * ItemIdKey = @"itemId";
static NSString * ChannelNameKey = @"channelName";

@implementation ChannelItem

- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]){
        _itemId = [aDecoder decodeObjectForKey:ItemIdKey];
        _channelName = [aDecoder decodeObjectForKey:ChannelNameKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_itemId forKey:ItemIdKey];
    [aCoder encodeObject:_channelName forKey:ChannelNameKey];
}

@end
