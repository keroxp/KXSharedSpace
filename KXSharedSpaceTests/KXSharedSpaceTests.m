//
//  KXSharedSpaceTests.m
//  KXSharedSpaceTests
//
//  Created by Yusuke Sakurai on 2014/01/29.
//  Copyright (c) 2014年 Yusuke Sakurai. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "KXSharedSpace.h"

@interface KXSharedSpaceTests : XCTestCase

@end

@implementation KXSharedSpaceTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    [KXSharedSpace registerSpaceWithName:@"strong" owner:self];
    NSObject *weakowner = [[NSObject alloc] init];
    [KXSharedSpace registerSpaceWithName:@"weak" owner:weakowner];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testBasic
{
    XCTAssertNil([KXSharedSpace spaceWithName:@"hoge"],);
    [KXSharedSpace registerSpaceWithName:@"test" owner:self];
    KXSharedSpace *s = [KXSharedSpace spaceWithName:@"test"];
    XCTAssert(s, );
    XCTAssert(s.dictionary, );
    XCTAssert([s.name isEqualToString:@"test"], );
    XCTAssertNil([s readDataForKey:@"data1"],);
    [s writeData:@"data1" forKey:@"data1"];
    XCTAssertThrows([s writeData:nil forKey:@"data1"], );
    XCTAssert([[s readDataForKey:@"data1"] isEqualToString:@"data1"], );
    XCTAssert([[s takeDataForKey:@"data1"] isEqualToString:@"data1"], );
    XCTAssertNil([s readDataForKey:@"data1"], );
}

- (void)testKVO
{
    KXSharedSpace *s = [KXSharedSpace spaceWithName:@"strong"];
    XCTAssert(s, @"このクラスが強参照しているからあるはず");
    XCTAssertNil([KXSharedSpace spaceWithName:@"weak"], @"オーナーが消えているからnilになってるはず");
    [s addObserver:self forKeyPath:@"test" options:NSKeyValueObservingOptionNew context:NULL];
    [s writeData:@"changed" forKey:@"test"];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == [KXSharedSpace spaceWithName:@"test"]) {
        XCTAssert([keyPath isEqualToString:@"test"], );
        id new_obj = [change objectForKey:NSKeyValueChangeNewKey];
        XCTAssert([new_obj isEqualToString:@"changed"], );
    }
}

@end
