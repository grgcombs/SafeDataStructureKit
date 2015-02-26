//
//  SafeDataStructureKitTests.m
//  SafeDataStructureKitTests
//
//  Copyright (C) 2015 Gregory Combs [gcombs at gmail]
//  See LICENSE.txt for details.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
@import SafeDataStructureKit.SafeOrderedDictionary;

@interface SafeDataStructureKitTests : XCTestCase
@property (nonatomic,copy) NSMutableDictionary *mutableData;
@property (nonatomic,copy) NSDictionary *immutableData;
@end

@implementation SafeDataStructureKitTests

- (void)setUp
{
    [super setUp];

    _immutableData = @{
                       @"aDict": @{
                               @"bArray": @[
                                       @{@"cItem": @"String"}
                                       ]
                               }
                       };

    _mutableData = [@{
                      @"aDict": [@{
                                   @"bArray": [@[
                                                 [@{
                                                    @"cItem": [@"String" mutableCopy]
                                                    } mutableCopy]
                                                 ] mutableCopy]
                                   } mutableCopy]
                      } mutableCopy];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testInstantiation
{
    NSDictionary *data = [_immutableData copy];

    SafeOrderedDictionary *safeDict = [[SafeOrderedDictionary new] modify:^(id<SafeMutableOrderedDictionary> dict) {
        dict[@"root"] = data;
        dict[@"aDict"] = data[@"aDict"];
        dict[@"bArray"] = data[@"aDict"][@"bArray"];
    }];

    XCTAssertNotNil(safeDict[@"root"], @"Should have root node");
    XCTAssertNotNil(safeDict[@"aDict"], @"Should have aDict node");
    XCTAssertTrue([safeDict[@"aDict"] isKindOfClass:[NSDictionary class]], @"Should be a dictionary");
}

- (void)testForbidsShallowMutation
{
    NSDictionary *immutableData = [_immutableData copy];

    SafeOrderedDictionary *safeDict = [[SafeOrderedDictionary new] modify:^(id<SafeMutableOrderedDictionary> dict) {
        dict[@"root"] = immutableData;
        dict[@"aDict"] = immutableData[@"aDict"];
        dict[@"bArray"] = immutableData[@"aDict"][@"bArray"];
    }];

    XCTAssertThrows([safeDict[@"aDict"] setObject:@"Shouldn't Work" forKey:@"failure"], @"Failed to prohibit unsafe shallow mutation.");
}

- (void)testForbitsNestedMutation
{
    NSMutableDictionary *mutableData = [_mutableData mutableCopy];

    SafeOrderedDictionary *safeDict = [[SafeOrderedDictionary new] modify:^(id<SafeMutableOrderedDictionary> dict) {
        dict[@"root"] = mutableData;
        dict[@"aDict"] = mutableData[@"aDict"];
        dict[@"bArray"] = mutableData[@"aDict"][@"bArray"];
    }];

    XCTAssertThrows([safeDict[@"aDict"][@"bArray"] addObject:@"Shouldn't Work"], @"Failed to prohibit unsafe nested mutation.");
}

- (void)testAllowsSafeShallowMutation
{
    NSDictionary *immutableData = [_immutableData copy];

    SafeOrderedDictionary *safeDict = [[SafeOrderedDictionary new] modify:^(id<SafeMutableOrderedDictionary> dict) {
        dict[@"root"] = immutableData;
        dict[@"aDict"] = immutableData[@"aDict"];
        dict[@"bArray"] = immutableData[@"aDict"][@"bArray"];
    }];

    XCTAssertEqualObjects(immutableData, safeDict[@"root"], @"Should have matching input/output root nodes");

    SafeOrderedDictionary *newDictionary = [safeDict modify:^(id<SafeMutableOrderedDictionary> dict) {
        dict[@"root"] = @"New Root";
    }];

    XCTAssertNotEqualObjects(newDictionary[@"root"], immutableData, @"Root node should no longer match initial input after mutation");

    XCTAssertEqualObjects(newDictionary[@"root"], @"New Root", @"Root node should match the new input");

    XCTAssertNotEqual(safeDict, newDictionary, @"Safe Dictionaries should not match");
}

- (void)testEquality
{
    NSDictionary *immutableData = [_immutableData copy];

    SafeOrderedDictionary *dict1 = [[SafeOrderedDictionary new] modify:^(id<SafeMutableOrderedDictionary> dict) {
        dict[@"aDict"] = immutableData[@"aDict"];
    }];

    XCTAssertNotEqualObjects(dict1, immutableData, @"A SafeOrderedDictionary is not the same thing as NSDictionary");

    SafeOrderedDictionary *dict2 = [[SafeOrderedDictionary new] modify:^(id<SafeMutableOrderedDictionary> dict) {
        dict[@"aDict"] = immutableData[@"aDict"];
    }];

    XCTAssertEqualObjects(dict1[@"aDict"], dict2[@"aDict"], @"Identical contents should be equal");

    XCTAssertEqualObjects(dict1, dict2, @"Identical safe dictionaries should be equal");
}

/*
- (void)testPerformanceExample
{
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}
*/

@end
