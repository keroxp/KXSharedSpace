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
    [[KXSharedSpace sharedSpace] registerSpaceWithName:@"strong" owner:self];
    NSObject *weakowner = [[NSObject alloc] init];
    [[KXSharedSpace sharedSpace] registerSpaceWithName:@"weak" owner:weakowner];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testBlocks
{
    void (^block)() = ^{NSLog(@"i am blocks");};
    id blockref = block;
    NSLog(@"%@",blockref);
    NSLog(@"%@",[blockref class]);
    XCTAssert([blockref isKindOfClass:[NSObject class]], );
    Class c = [blockref class];
    while (c) {
        NSLog(@"%@",NSStringFromClass(c));
        c = [c superclass];
    }
    XCTAssertNoThrow([blockref class], @"???");
}

- (void)testBasic
{
    XCTAssertNil([[KXSharedSpace sharedSpace] spaceWithName:@"hoge"],);
    XCTAssertThrows([[KXSharedSpace sharedSpace] registerSpaceWithName:@"nil" owner:nil], @"nilでregisterしたら例外出す");
    [[KXSharedSpace sharedSpace] registerSpaceWithName:@"test" owner:self];
    KXSharedSpaceInstance *s = [[KXSharedSpace sharedSpace] spaceWithName:@"test"];
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

- (void)testWrite
{
    KXSharedSpaceInstance *s = [[KXSharedSpace sharedSpace] spaceWithName:@"strong"];
    void (^block)() = ^{ NSLog(@"block invoked!"); };
    XCTAssertNoThrow([s writeData:block forKey:@"block"], @"");
    block = [s readDataForKey:@"block"];
    XCTAssert(block, );
    XCTAssertNoThrow(block(), );
}

- (void)testKVO
{
    KXSharedSpaceInstance *s = [[KXSharedSpace sharedSpace] spaceWithName:@"strong"];
    XCTAssert(s, @"このクラスが強参照しているからあるはず");
    XCTAssertNil([[KXSharedSpace sharedSpace] spaceWithName:@"weak"], @"オーナーが消えているからnilになってるはず");
    [s addObserver:self forKeyPath:@"test" options:NSKeyValueObservingOptionNew context:NULL];
    [s writeData:@"changed" forKey:@"test"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == [[KXSharedSpace sharedSpace] spaceWithName:@"test"]) {
        XCTAssert([keyPath isEqualToString:@"test"], );
        id new_obj = [change objectForKey:NSKeyValueChangeNewKey];
        XCTAssert([new_obj isEqualToString:@"changed"], );
    }
}



@end
