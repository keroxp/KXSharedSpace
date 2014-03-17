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

static id sharedInstance;

@interface KXSharedSpace ()
{
    NSMapTable *_spaces;
}
@end

@implementation KXSharedSpace

#pragma mark - Class

+ (instancetype)sharedSpace
{
    @synchronized(self){
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedInstance = [[self alloc] init];
        });
    }
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    _spaces = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory valueOptions:NSMapTableWeakMemory];
    return self ?: nil;
}

- (void)registerSpaceWithName:(NSString *)name owner:(id)owner
{
    if (!owner) {
        @throw [NSException exceptionWithName:@"KXSharedSpaceNilOwnerException" reason:@"registering shared space with nil owner is forbided" userInfo:nil];
        return;
    }
    KXSharedSpaceInstance *s = [[KXSharedSpaceInstance alloc] initWithNameSpace:name owner:owner];
    // make owner have strong reference to the space
    [s addOwner:owner];
    // register space with name
    [_spaces setObject:s forKey:name];
    // console
    NSLog(@"Shared space has been registred '%@ : %@",name, _spaces);
}

- (void)unregisterSpaceWithName:(NSString *)name
{
    [_spaces removeObjectForKey:name];
}

- (KXSharedSpaceInstance *)spaceWithName:(NSString *)name
{
    return [_spaces objectForKey:name];
}

- (NSDictionary *)spaces
{
    return _spaces.dictionaryRepresentation;
}

@end

@implementation KXSharedSpaceInstance
{
    NSMutableDictionary *__dictionary;
    NSHashTable *_owners;
    NSHashTable *_allOwners;
}

- (void)addOwner:(id)owner
{
    @autoreleasepool {
        [_owners addObject:owner];
        objc_setAssociatedObject(owner, (__bridge const void *)(self), self, OBJC_ASSOCIATION_RETAIN);
    }
}

- (void)removeOwner:(id)owner
{
    @autoreleasepool {
        [_owners removeObject:owner];
        objc_setAssociatedObject(owner, (__bridge const void *)(self), nil, OBJC_ASSOCIATION_ASSIGN);
    }
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
        __dictionary = [NSMutableDictionary new];
        _name = nameSpace;
        _owners = [NSHashTable hashTableWithOptions:NSHashTableWeakMemory];
        _allOwners = [NSHashTable hashTableWithOptions:NSHashTableWeakMemory];
        [self addOwner:owner];
    }
    return self ? self : nil;
}

-(void)writeData:(id)data forKey:(NSString *)key
{
    if ([data isKindOfClass:NSClassFromString(@"NSBlock")]) {
        // copy data if blocks given
        [self setObjectToDictionary:[data copy] forKey:key];
    }else{
        [self setObjectToDictionary:data forKey:key];
    }
}

- (id)readDataForKey:(NSString *)key
{
    return [__dictionary objectForKey:key];
}

- (id)takeDataForKey:(NSString *)key
{
    id obj = [__dictionary objectForKey:key];
    [__dictionary removeObjectForKey:key];
    return obj;
}

- (NSSet *)owners
{
    return _owners.setRepresentation;
}

- (NSDictionary *)dictionary
{
    return __dictionary;
}

- (void)setObjectToDictionary:(id)object forKey:(NSString*)aKey
{
    for (id owner in _allOwners) {
        [__dictionary addObserver:owner forKeyPath:aKey options:NSKeyValueObservingOptionNew context:NULL];
    }
    [__dictionary setObject:object forKey:aKey];
}

- (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context
{
    // set primitive value if dictionary doesn't have object related to keypath
    if ([keyPath isEqualToString:kKXSharedSpaceObserveAllKey]) {
        // observe all key-values
        [_allOwners addObject:observer];
        for (NSString *key in self.dictionary.keyEnumerator) {
            [self.dictionary addObserver:observer forKeyPath:key options:options context:context];
        }
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
