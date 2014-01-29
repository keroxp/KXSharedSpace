//
//  KXSharedSpace.h
//  KXSharedSpace
//
//  Created by Yusuke Sakurai on 2014/01/29.
//  Copyright (c) 2014年 Yusuke Sakurai. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kKXSharedSpaceObserveAllKey;
@interface KXSharedSpace : NSObject

+ (void)registerSpaceWithName:(NSString*)name owner:(id)owner;
+ (void)unregisterSpaceWithName:(NSString*)name;
+ (void)writeData:(id)data toSpaceForKey:(NSString*)spaceKey valueKey:(NSString *)valueKey;
+ (id)readDataFromSpace:(NSString*)spaceKey property:(NSString *)property;
+ (id)takeDataFromSpace:(NSString*)spaceKey property:(NSString *)property;

// get space with specified key
+ (KXSharedSpace*)spaceWithName:(NSString*)name;

- (void)writeData:(id)data forKey:(NSString *)key;
- (id)readDataForKey:(NSString *)key;
- (id)takeDataForKey:(NSString *)key;

// KVO method to the reciever, actually to the dictionary object
- (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context;
- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context;

// an explicit owner object of the reciever
@property (weak, nonatomic) id owner;
// name of the reciever
@property (nonatomic, readonly) NSString *name;
// key-value-store that the reciever has
@property (nonatomic, readonly) NSDictionary *dictionary;

@end

typedef void(^KXKeyValueObservingChangeHandler)(NSKeyValueChange change, id newValue, id oldValue);

@interface NSObject (KXSharedSpace)

- (void)useSharedSpaceAspect;
- (void)writeData:(id)data toSpaceForKey:(NSString*)spaceKey valueKey:(NSString*)valueKey;
- (id)readDataFromSpaceForKey:(NSString*)spaceKey valueKey:(NSString*)valueKey;
- (id)takeDataFromSpaceForKey:(NSString*)spaceKey valueKey:(NSString*)valueKey;
- (void)observeValueOnSpaceForKey:(NSString*)spaceKey
                         valueKey:(NSString*)valueKey
                             once:(BOOL)once
                          handler:(KXKeyValueObservingChangeHandler)handler;
- (void)stopObservingToSpaceForKey:(NSString*)spaceKey valueKey:(NSString*)valueKey;

@end