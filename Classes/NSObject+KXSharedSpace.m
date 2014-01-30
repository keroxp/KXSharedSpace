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

- (KXSharedSpace*)spaceWithCommonProc:(NSString*)spaceKey
{
    // make the reciever have strong ownership even if calling this method once
    KXSharedSpace *s = [KXSharedSpace spaceWithName:spaceKey];
    if (!s) {
        [KXSharedSpace registerSpaceWithName:spaceKey owner:self];
    }else{
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