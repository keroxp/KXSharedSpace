//
//  KXSharedSpaceKVOTests.m
//  KXSharedSpace
//
//  Created by 桜井雄介 on 2014/02/01.
//  Copyright (c) 2014年 Yusuke Sakurai. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSObject+KXSharedSpace.h"
#import "KXTestObject.h"

@interface KXSharedSpaceKVOTests : XCTestCase

@end

@implementation KXSharedSpaceKVOTests

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

- (void)testExample
{
    KXTestObject *owner1 = [KXTestObject new];
    XCTAssertNoThrow([owner1 useBlocksKVOAspect], @"アスペクトの使用宣言");
    [owner1 writeData:@"hoge" toSpaceForKey:@"space1" valueKey:@"data1"];
    KXTestObject *owner2 = [KXTestObject new];
    [owner2 useBlocksKVOAspect];
    XCTAssertNoThrow([owner1 observeValueOnSpaceForKey:@"space1" valueKey:@"data1" once:NO handler:^(NSKeyValueChange change, id newValue, id oldValue) {
        XCTAssert(change, );
        XCTAssert(newValue, );
        XCTAssert(oldValue, );
        if ([oldValue isEqualToString:@"hoge"]) {
            // 1回目
            XCTAssert([newValue isEqualToString:@"foo"], );
        }else if ([oldValue isEqualToString:@"foo"]){
            // 2回目
            XCTAssert([newValue isEqualToString:@"var"], );
        }
        NSLog(@"KVO handled %@",newValue);
    }], );
    [owner2 writeData:@"foo" toSpaceForKey:@"space1" valueKey:@"data1"];
    [owner1 writeData:@"var" toSpaceForKey:@"space2" valueKey:@"data1"];
}

@end
