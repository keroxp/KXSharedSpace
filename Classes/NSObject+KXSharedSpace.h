//
//  NSObject+KXSharedSpace.h
//  KXSharedSpace
//
//  Created by 桜井雄介 on 2014/01/30.
//  Copyright (c) 2014年 Yusuke Sakurai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (KXSharedSpace)

- (void)kx_writeData:(id)data toSpaceForKey:(NSString*)spaceKey valueKey:(NSString*)valueKey;
- (id)kx_readDataFromSpaceForKey:(NSString*)spaceKey valueKey:(NSString*)valueKey;
- (id)kx_takeDataFromSpaceForKey:(NSString*)spaceKey valueKey:(NSString*)valueKey;

@end