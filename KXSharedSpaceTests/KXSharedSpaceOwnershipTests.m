//
//  KXSharedSpaceOwnershipTests.m
//  KXSharedSpace
//
//  Created by 桜井雄介 on 2014/01/30.
//  Copyright (c) 2014年 Yusuke Sakurai. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "KXSharedSpace.h"

@interface KXSharedSpaceOwnershipTests : XCTestCase

@end

@implementation KXSharedSpaceOwnershipTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testHashTable
{
    NSHashTable *hashTable;
    hashTable = [NSHashTable weakObjectsHashTable];
    @autoreleasepool {
        NSObject *weakobj1 = [NSObject new];
        NSObject *weakobj2 = [NSObject new];
        [hashTable addObject:weakobj1];
        [hashTable addObject:weakobj2];
        [hashTable addObject:self];
        XCTAssert(hashTable.count == 3, @"コンテンツは３つのはず");
    }
    XCTAssert(hashTable.allObjects.count == 1, @"〃");
    
    XCTAssert([hashTable.anyObject isEqual:self], @"hashtableのコンテンツはselfのみのはず");
    XCTAssert([hashTable.allObjects.firstObject isEqual:hashTable.allObjects.lastObject], @"〃");
    
    for (id obj in hashTable.allObjects) {
        XCTAssert([obj isEqual:self], @"hashtableのコンテンツはselfのみのはず");
    }
    for (id obj in hashTable) {
        XCTAssert([obj isEqual:self], @"〃");
    }
    
//    XCTAssert(hashTable.count == 1, @"@autoreleasepoolから抜けているのでweakobj1/2への参照が消えているはず");
}

- (void)testOwnerShip
{
    @autoreleasepool {
        NSObject *weakOwner1, *weakOwner2;
        weakOwner1 = [NSObject new];
        weakOwner2 = [NSObject new];
        [[KXSharedSpace sharedSpace] registerSpaceWithName:@"weak_" owner:weakOwner1];
        [[[KXSharedSpace sharedSpace] spaceWithName:@"weak_"] addOwner:weakOwner2];
        [[[KXSharedSpace sharedSpace] spaceWithName:@"weak_"] addOwner:self];
        XCTAssert([[[[KXSharedSpace sharedSpace] spaceWithName:@"weak_"] owners] count] == 3, @"ownerは二人いるはず");
    }
    for (id obj in [[[KXSharedSpace sharedSpace] spaceWithName:@"weak_"] owners]) {
        XCTAssert([obj isEqual:self], );
    }
    XCTAssert([[[[KXSharedSpace sharedSpace] spaceWithName:@"weak_"] owners] containsObject:self] , @"");
}

- (void)testOwnerShip2
{
    [[KXSharedSpace sharedSpace] registerSpaceWithName:@"Owner" owner:self];
    KXSharedSpaceInstance *i = [[KXSharedSpace sharedSpace] spaceWithName:@"Owner"];
    XCTAssert([i.owners.anyObject isEqual:self], );
    [i removeOwner:self];
    XCTAssert(i.owners.count == 0, );
}
    

- (void)testOwnerShiop3
{
    XCTAssertNil([[KXSharedSpace sharedSpace] spaceWithName:@"weak_"], );
}

@end
