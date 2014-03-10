//
//  KXSharedSpaceAspectTests.m
//  KXSharedSpace
//
//  Created by 桜井雄介 on 2014/01/30.
//  Copyright (c) 2014年 Yusuke Sakurai. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "KXSharedSpace.h"
#import "NSObject+KXSharedSpace.h"

@interface KXSharedSpaceAspectTests : XCTestCase

@end

@implementation KXSharedSpaceAspectTests

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

- (void)testBasic
{
    XCTAssertNil([self kx_readDataFromSpaceForKey:@"nil" valueKey:@"nil"], @"まだ登録されてない");
    [self kx_writeData:@"data1" toSpaceForKey:@"test1" valueKey:@"data1"];
    XCTAssertNotNil([[KXSharedSpace sharedSpace] spaceWithName:@"test1"], @"登録済み");
    NSString *data1 = [self kx_readDataFromSpaceForKey:@"test1" valueKey:@"data1"];
    XCTAssert(data1, );
    XCTAssert([data1 isEqualToString:@"data1"], );
    data1 = [self kx_takeDataFromSpaceForKey:@"test1" valueKey:@"data1"];
    XCTAssertNil([[[KXSharedSpace sharedSpace] spaceWithName:@"test1"] readDataForKey:@"data1"],);
    XCTAssert([data1 isEqualToString:@"data1"], );
}

@end
