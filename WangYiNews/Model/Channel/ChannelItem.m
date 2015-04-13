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

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p, %@>",
            [self class],
            self,
            @{@"channel name":_channelName,
              @"id":_itemId}];
}

- (NSUInteger)hash
{
    NSUInteger channelNameHash = [_channelName hash];
    NSUInteger itemIdHash = [_itemId integerValue];
    return channelNameHash ^ itemIdHash;
}

- (BOOL)isEqual:(id)object
{
    if ([self class] == [object class]) {
        return [self isEqualToChannelItem:(ChannelItem *)object];
    } else {
        return [super isEqual:object];
    }
}

- (BOOL)isEqualToChannelItem:(ChannelItem *)otherItem
{
    if (self == otherItem) {
        return YES;
    }
    if (![_channelName isEqualToString:otherItem.channelName]) {
        return NO;
    }
    if (![_itemId isEqualToString:otherItem.itemId]) {
        return NO;
    }
    return YES;
}

@end
