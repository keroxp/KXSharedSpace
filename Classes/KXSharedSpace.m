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
static const char *ownerKey = "me.keroxp.app.KX:KXSharedSpaceOwnerKey";
static NSMapTable *spaces;

@interface KXSharedSpace ()
{
    NSMutableDictionary *dictioinary_;
}

- (instancetype)initWithNameSpace:(NSString*)nameSpace owner:(id)owner;

@end

@implementation KXSharedSpace

#pragma mark - Class

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        spaces = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory];
    });
}

+ (void)registerSpaceWithName:(NSString *)name owner:(id)owner
{
    KXSharedSpace *s = [[self alloc] initWithNameSpace:name owner:owner];
    // make owner have strong reference to the space
    objc_setAssociatedObject(owner, ownerKey, s, OBJC_ASSOCIATION_RETAIN);
    // register space with name
    [spaces setObject:s forKey:name];
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

+ (id)readDataFromSpace:(NSString *)spaceKey property:(NSString *)property
{
    return [[spaces objectForKey:spaceKey] readDataForKey:property];
}

+ (void)writeData:(id)data toSpaceForKey:(NSString *)spaceKey valueKey:(NSString *)property
{
    [[spaces objectForKey:spaceKey] writeData:data forKey:property];
}

+ (id)takeDataFromSpace:(NSString *)spaceKey property:(NSString *)property
{
    return [[spaces objectForKey:spaceKey] takeDataForKey:property];
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
        _owner = owner;
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

@implementation NSObject(KXSharedSpace)

- (void)useSharedSpaceAspect
{
    Method from = class_getInstanceMethod([self class], @selector(observeValueForKeyPath:ofObject:change:context:));
    Method to = class_getInstanceMethod([self class], @selector(_observeValueForKeyPath:ofObject:change:context:));
    if (from) {
        method_exchangeImplementations(from, to);
    }else{
        const char * type = method_getTypeEncoding(to);
        void (^block)() = ^{};
        IMP imp = imp_implementationWithBlock(block);
        class_addMethod([self class], @selector(observeValueForKeyPath:ofObject:change:context:), imp, type);
        [self useSharedSpaceAspect];
    }
}

- (void)writeData:(id)data toSpaceForKey:(NSString *)spaceKey valueKey:(NSString *)valueKey
{
    [KXSharedSpace writeData:data toSpaceForKey:spaceKey valueKey:valueKey];
}

- (id)readDataFromSpaceForKey:(NSString *)spaceKey valueKey:(NSString *)valueKey
{
    return [KXSharedSpace readDataFromSpace:spaceKey property:valueKey];
}

- (id)takeDataFromSpaceForKey:(NSString *)spaceKey valueKey:(NSString *)valueKey
{
    return [KXSharedSpace takeDataFromSpace:spaceKey property:valueKey];
}

- (void)observeValueOnSpaceForKey:(NSString *)spaceKey valueKey:(NSString *)valueKey once:(BOOL)once handler:(KXKeyValueObservingChangeHandler)handler
{    
    [[KXSharedSpace spaceWithName:spaceKey] addObserver:self forKeyPath:valueKey options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:&handler];
}

- (void)_observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // call original method
    [self _observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    // call handler
    NSKeyValueChange kind = [[change objectForKey:NSKeyValueChangeKindKey] integerValue];;
    id new = [change objectForKey:NSKeyValueChangeNewKey];
    id old = [change objectForKey:NSKeyValueChangeOldKey];
    if (context) {
        KXKeyValueObservingChangeHandler handler = (__bridge KXKeyValueObservingChangeHandler)context;
        if (handler) {
            handler(kind,new,old);
        }
    }
}

- (void)stopObservingToSpaceForKey:(NSString *)spaceKey valueKey:(NSString *)valueKey
{
    [[KXSharedSpace spaceWithName:spaceKey] removeObserver:self forKeyPath:valueKey];
}

@end