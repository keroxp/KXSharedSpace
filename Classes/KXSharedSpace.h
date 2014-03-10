//
//  KXSharedSpace.h
//  KXSharedSpace
//
//  Created by Yusuke Sakurai on 2014/01/29.
//  Copyright (c) 2014年 Yusuke Sakurai. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kKXSharedSpaceObserveAllKey;

@class KXSharedSpaceInstance;

@interface KXSharedSpace : NSObject

+ (instancetype)sharedSpace;

// register shared space with primtive owner
- (void)registerSpaceWithName:(NSString*)name owner:(id)owner;
- (void)unregisterSpaceWithName:(NSString*)name;

// get space with specified key
- (KXSharedSpaceInstance*)spaceWithName:(NSString*)name;

@end

@interface KXSharedSpaceInstance : NSObject

- (instancetype)initWithNameSpace:(NSString *)nameSpace owner:(id)owner;

- (void)writeData:(id)data forKey:(NSString *)key;
- (id)readDataForKey:(NSString *)key;
- (id)takeDataForKey:(NSString *)key;
- (void)addOwner:(id)owner;
- (void)removeOwner:(id)owner;

// KVO method to the reciever, actually to the dictionary object
- (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context;
- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context;

// owner objects of the reciever
@property (nonatomic, readonly) NSSet *owners;
// name of the reciever
@property (nonatomic, readonly) NSString *name;
// key-value-store that the reciever has
@property (nonatomic, readonly) NSDictionary *dictionary;


@end
