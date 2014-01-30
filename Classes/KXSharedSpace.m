//
//  KXSharedSpace.m
//  KXSharedSpace
//
//  Created by Yusuke Sakurai on 2014/01/29.
//  Copyright (c) 2014年 Yusuke Sakurai. All rights reserved.
//

#import "KXSharedSpace.h"
#import <objc/runtime.h>

NSString*const kKXSharedSpaceObserveAllKey = @"me.keroxp.app.KX:KXSharedSpaceWatchAllKey";
static NSString *ownerKey = @"me.keroxp.app.KX:KXSharedSpaceOwnerKey";
static NSMapTable *spaces;

@interface KXSharedSpace ()
{
    NSMutableDictionary *dictioinary_;
    NSHashTable *_owners;
}

- (instancetype)initWithNameSpace:(NSString*)nameSpace owner:(id)owner;

@end

@implementation KXSharedSpace

#pragma mark - Class

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        spaces = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory valueOptions:NSMapTableWeakMemory];
    });
}

+ (void)registerSpaceWithName:(NSString *)name owner:(id)owner
{
    if (!owner) {
        @throw [NSException exceptionWithName:@"KXSharedSpaceNilOwnerException" reason:@"registering shared space with nil owner is forbided" userInfo:nil];
        return;
    }
    KXSharedSpace *s = [[self alloc] initWithNameSpace:name owner:owner];
    // register space with name
    [spaces setObject:s forKey:name];
    // make owner have strong reference to the space
    [s addOwner:owner];
}

- (void)addOwner:(id)owner
{
    @autoreleasepool {
        KXSharedSpace *s = [[self class] spaceWithName:self.name];
        [_owners addObject:owner];
        const char * key = [[self.name stringByAppendingString:ownerKey] cStringUsingEncoding:NSUTF8StringEncoding];
        objc_setAssociatedObject(owner, key, s, OBJC_ASSOCIATION_RETAIN);
    }
}

- (void)removeOwner:(id)owner
{
    @autoreleasepool {
        const char * key = [[self.name stringByAppendingString:ownerKey] cStringUsingEncoding:NSUTF8StringEncoding];
        [_owners removeObject:owner];
        objc_setAssociatedObject(owner, key, nil, OBJC_ASSOCIATION_ASSIGN);
    }
}

+ (void)unregisterSpaceWithName:(NSString *)name
{
    [spaces removeObjectForKey:name];
}

+ (KXSharedSpace *)spaceWithName:(NSString *)name
{
    KXSharedSpace *s = [spaces objectForKey:name];
    return s;
}

#pragma mark - Instance

- (id)init
{
    // forbid manual instantiation
    @throw [NSException exceptionWithName:@"KXSharedSpaceInvalidInitializationException" reason:@"" userInfo:nil];
    return nil;
}

- (instancetype)initWithNameSpace:(NSString *)nameSpace owner:(id)owner
{
    if (self = [super init]) {
        dictioinary_ = [NSMutableDictionary new];
        _name = nameSpace;
        _owners = [NSHashTable hashTableWithOptions:NSHashTableWeakMemory];
        [_owners addObject:owner];
    }
    return self ? self : nil;
}

-(void)writeData:(id)data forKey:(NSString *)key
{
    [dictioinary_ setObject:data forKey:key];
}

- (id)readDataForKey:(NSString *)key
{
    return [dictioinary_ objectForKey:key];
}

- (id)takeDataForKey:(NSString *)key
{
    id obj = [dictioinary_ objectForKey:key];
    [dictioinary_ removeObjectForKey:key];
    return obj;
}

- (NSDictionary *)dictionary
{
    return dictioinary_;
}

- (NSSet *)owners
{
    return (NSSet*)_owners;
}

- (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context
{
    if ([keyPath isEqualToString:kKXSharedSpaceObserveAllKey]) {
        // observe all key-values
        [self.dictionary enumerateKeysAndObjectsUsingBlock:^(NSString* key, id obj, BOOL *stop) {
            [self.dictionary addObserver:observer forKeyPath:key options:options context:context];
        }];
    }else{
        [self.dictionary addObserver:observer forKeyPath:keyPath options:options context:NULL];
    }
}

- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context
{
    if ([keyPath isEqualToString:kKXSharedSpaceObserveAllKey]) {
        [self.dictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
            [self.dictionary removeObserver:observer forKeyPath:key];
        }];
    }else{
        [self.dictionary removeObserver:observer forKeyPath:keyPath context:NULL];
    }
}

@end
