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

- (void)useBlocksKVOAspect
{
//    [self swizzleMethod:@selector(observeValueForKeyPath:ofObject:change:context:) toMethod:@selector(_observeValueForKeyPath:ofObject:change:context:)];
    Method m = class_getInstanceMethod([self class], @selector(_observeValueForKeyPath:ofObject:change:context:));
    const char * type = method_getTypeEncoding(m);
    IMP imp = method_getImplementation(m);
    class_addMethod([self class], @selector(observeValueForKeyPath:ofObject:change:context:), imp, type);
    [self swizzleMethod:@selector(respondsToSelector:) toMethod:@selector(_respondsToSelector:)];
}

- (void)swizzleMethod:(SEL)from toMethod:(SEL)to
{
    Method from_m = class_getInstanceMethod([self class],from);
    Method to_m = class_getInstanceMethod([self class], to);
    if ([self respondsToSelector:from]) {
        method_exchangeImplementations(from_m, to_m);
    }else{
        const char * type = method_getTypeEncoding(to_m);
        void (^block)() = ^{};
        IMP imp = imp_implementationWithBlock(block);
        class_addMethod([self class], from, imp, type);
        [self swizzleMethod:from toMethod:to];
    }
}

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

- (void)observeValueOnSpaceForKey:(NSString *)spaceKey valueKey:(NSString *)valueKey once:(BOOL)once handler:(KXKeyValueObservingChangeHandler)handler
{
    __bridge void * _hadler = [handler copy];
    [[KXSharedSpace spaceWithName:spaceKey]
     addObserver:self
     forKeyPath:valueKey
     options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
     context:(__bridge void *)([handler copy])];
}

- (BOOL)_respondsToSelector:(SEL)aSelector
{
    if (aSelector == @selector(observeValueForKeyPath:ofObject:change:context:)) {
        return YES;
    }
    return [self _respondsToSelector:aSelector];
}

- (void)_observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // call original method
//    [self _observeValueForKeyPath:keyPath ofObject:object change:change context:context];
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