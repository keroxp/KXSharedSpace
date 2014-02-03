//
//  NSObject+KXSharedSpace.m
//  KXSharedSpace
//
//  Created by 桜井雄介 on 2014/01/30.
//  Copyright (c) 2014年 Yusuke Sakurai. All rights reserved.
//

#import "NSObject+KXSharedSpace.h"
#import "KXSharedSpace.h"
#import <objc/runtime.h>

@implementation NSObject(KXSharedSpace)

- (KXSharedSpace*)spaceWithCommonProc:(NSString*)spaceKey
{
    // make the reciever have strong ownership even if calling this method once
    KXSharedSpace *s = [KXSharedSpace spaceWithName:spaceKey];
    if (!s) {
        [KXSharedSpace registerSpaceWithName:spaceKey owner:self];
        return [self spaceWithCommonProc:spaceKey];
    }
    if(![s.owners containsObject:self]){
        [s addOwner:self];
    }
    return s;
}

- (void)writeData:(id)data toSpaceForKey:(NSString *)spaceKey valueKey:(NSString *)valueKey
{
    [[self spaceWithCommonProc:spaceKey] writeData:data forKey:valueKey];
}

- (id)readDataFromSpaceForKey:(NSString *)spaceKey valueKey:(NSString *)valueKey
{
    return [[self spaceWithCommonProc:spaceKey] readDataForKey:valueKey];
}

- (id)takeDataFromSpaceForKey:(NSString *)spaceKey valueKey:(NSString *)valueKey
{
    return [[self spaceWithCommonProc:spaceKey] takeDataForKey:valueKey];
}

@end